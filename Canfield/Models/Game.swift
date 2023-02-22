//
//  Game.swift
//  Canfield
//
//  Created by David Geere on 2/2/23.
//

import Foundation
import SwiftUI
import Combine

struct Status: Identifiable {
    
    let key: GameStatus
    
    let value: Int
    
    var id: GameStatus {
        return self.key
    }
    
    var display: String {
        switch self.key {
        case .time:
            let minutes = String(format: "%02d", self.value / 60)
            let seconds = String(format: "%02d", self.value % 60)
            
            return minutes + ":" + seconds
        default:
            return String(format: "%03d", self.value)
        }
    }
    
    var order: Int {
        switch self.key {
        case .time: return 1
        case .moves: return 2
        case .score: return 3
        }
    }
}

class Game: ObservableObject {
    
    public static let instance:Game = Game()
    public static let preview:Game = Game()
    
    @Published public var cards: [Card]
    @Published public var state: GameState {
        didSet {
            if self.state == .ready {
                self.setup()
            }
        }
    }
    
    @Published public var undo_moves: [Move]
    
    @Published public var autocompletable: Bool
    
    @Published public var status: [Status]
    
    private var moves: Int {
        didSet {
            
            if oldValue == 0 && self.moves == 1 {
                self.start()
            }
            
            self.status(for: .moves, value: self.moves)
        }
    }
    
    private var elapsed: Int{
        didSet {
            self.status(for: .time, value: self.elapsed)
        }
    }
    
    private var score: Int{
        didSet {
            self.status(for: .score, value: self.score)
        }
    }
    
    private var timer: Timer
    
    init() {
        
        self.state = .none
        self.cards = Deck.instance.cards
        
        self.timer = Timer()
        self.undo_moves = []
        self.autocompletable = false
        
        self.status = []
        
        self.elapsed = 0
        self.moves = 0
        self.score = 0
        
    }
    
    //MARK: Private Methods
    public func relayout(_ bounds: CGRect) {
        
        Deck.instance.resize(bounds.size)
        
        self.cards.forEach( { $0.rebuild() } )
        
        self.refresh()
    }
    
    private func status(for key: GameStatus, value: Int) {
        
        if let index = self.status.firstIndex(where: { $0.key == key }) {
            self.status[index] = Status(key: key, value: value)
        } else {
            self.status.append(Status(key: key, value: value))
        }
        
    }
    
    private func place(_ card: Card) {
        
        switch card.rank {
        case .ace:
            self.place(card, on: .foundation( card.suit ))
        case .king:
            if let target = self.target(card, for: .foundation(card.suit)) {
                self.place(card, on: target)
            } else {
                for column in Column.allCases {
                    guard self.empty(tableau: column) else { continue }
                    
                    self.place(card, on: .tableau( column ))
                    
                    return
                }
            }
        default:
            if let target = self.target(card, for: .foundation(card.suit)) {
                self.place(card, on: target)
            } else {
                for column in Column.allCases {
                    guard let target = self.target(card, for: .tableau(column)) else { continue }
                    
                    self.place(card, on: target)
                    
                    return
                }
            }
        }
    }
    
    private func place(_ card: Card, on placement:Placement) {
        self.place(card, placement: placement)
    }
    
    private func place(_ card: Card, on target: Card) {
        self.place(card, placement: target.placement, target: target)
    }
    
    private func place(_ card: Card, placement: Placement, target: Card? = nil) {
        
        if let target = target {
            guard card.valid(for: target) else { return }
        } else {
            guard card.valid(for: placement) else { return }
        }
        
        let revealed_state = MoveState(from: card.revealed, to: true)
        let placement_state = MoveState(from: card.placement, to: placement)
        let parent_state = MoveState(from: card.parent, to: target)
        
        self.detach_from_previous_parent(card: card)
        
        if let target {
            card.place(on: target)
        } else {
            card.place(on: placement)
        }
        
        self.move(card, placement: placement_state, revealed: revealed_state, parent: parent_state)
        
        if placement_state.from == .waste {
            self.redeal_stock()
        } else {
            self.flip_over_previous_card(placement: placement_state.from)
        }
        
        self.refresh()
    }
    
    private func undo(_ move: Move) {

        // if there was no previous parent
        if move.placement.from == .waste {
            if let last = self.last(for: .waste) {
                self.restock(last)
            }
        } else {
            self.flip_back_previous_card(placement: move.placement.from)
        }

        // Reattach to previous parent
        if let parent = move.parent.from {

            parent.available = false
            parent.child = move.card
            parent.refresh()

            move.card.parent = parent

        }

        if let target = move.parent.to {

            // Detach from new parent
            target.available = true
            target.child = nil
            target.refresh()

            // move back to previous place
            move.card.order = self.order(for: move.placement.from) + 1

            move.card.parent = move.parent.from
            move.card.offset = .zero
            move.card.revealed = move.revealed.from
            move.card.available = move.card.child == nil
            move.card.placement = move.placement.from

            move.card.refresh()

        } else {

            move.card.order = self.order(for: move.placement.from) + 1
            move.card.available = move.card.child == nil
            move.card.offset = .zero
            move.card.placement = move.placement.from

        }

        self.moves += 1
        self.score -= 10

        self.refresh()
    }
    
    private func redeal_stock() {
        
        let wasted = self.cards.filter( { return $0.placement == .waste } ).count
        
        guard wasted <= 0 else { return }
        
        guard let stock = self.cards.first(where: { return $0.placement == .stock }) else { return }
        
        self.waste(stock)
    }
    
    private func flip_back_previous_card(placement: Placement) {
        
        guard let previous = self.last(for: placement) else { return }
        
        previous.available = false
        previous.revealed = false
        previous.face = .down
        previous.refresh()
        
    }
    
    private func flip_over_previous_card(placement: Placement) {
        
        guard let previous = self.last(for: placement) else { return }
        
        previous.available = true
        previous.revealed = true
        previous.face = .up
        previous.refresh()
        
    }
    
    private func detach_from_previous_parent(card: Card) {
        
        guard let parent = card.parent else { return }
        
        parent.available = true
        parent.child = nil
        parent.refresh()
        
        card.parent = nil
        
    }
    
    private func place_card_on_depot(card: Card, placement: Placement) {
        card.place(on: placement)
    }
    
    private func place_card_on_card(child: Card, parent: Card) {
        
        child.place(on: parent)
    }
    
    private func order_cards() {
        
        self.cards.sort { left, right in
            return left.placement.order > right.placement.order
        }
        
        self.cards.sort { left, right in
            return left.placement.order == right.placement.order && left.order > right.order
        }
        
        for placement in Placement.allCases {
            Table.instance[placement] = stacked_placement_bounds(placement: placement)
        }
        
    }
    
    private func drop(_ data: CardEventData, on placement: Placement) {
        
        if let target = self.cards.last( where: { return $0.placement == placement && $0.available } ) {
            
            self.place(data.card, on: target)
            
        } else {
            
            self.place(data.card, on: placement)
            
        }
    }
    
    private func placement(depot: CGRect) -> Placement? {
        
        var captured: Placement?
        var overlapped = 0.0
        
        for placement in Placement.allCases {
            
            let collision = depot.overlap(area: Table.instance[placement])
            
            guard collision.rounded() > overlapped else { continue }
            
            overlapped = collision.rounded()
            captured = placement
        }
        
        return captured
    }
    
    private func stacked_placement_bounds(placement: Placement) -> CGRect {
        
        switch placement {
        case .tableau:
            
            let items = self.cards.filter({ return $0.placement == placement }).sorted( by: { return $0.order < $1.order } )
            
            guard !self.empty(for: placement),
                  let first = items.first,
                  let last = items.last
            else {
                return Table.instance[placement]
            }
            
            let left = first.bounds.minX
            let top = first.bounds.minY
            
            let bottom = last.bounds.maxY
            let right = last.bounds.maxX
            
            let bounds = CGRect(x: left, y: top, width: right - left, height: bottom - top)
            
            return bounds
            
        default:
            return Table.instance[placement]
        }
        
    }
    
    private func target(_ card: Card, for placement: Placement) -> Card? {
        return self.cards.last( where: { return $0.placement == placement && $0.available && card.valid(for: $0) } )
    }
    
    private func empty_tableaus() -> [Placement] {
        return Placement.allTableaus.filter({ return self.empty(tableau: $0.column! )})
    }
    
    public func empty(foundation suite: Suit) -> Bool {
        return self.empty(for: .foundation(suite))
    }
    
    public func empty(tableau column: Column) -> Bool {
        return self.empty(for: .tableau(column))
    }
    
    public func empty(for placement: Placement, with face: Face? = nil) -> Bool {
        if let face = face {
            return self.cards.filter({ return $0.placement == placement && $0.face == face }).isEmpty
        } else {
            return self.cards.filter({ return $0.placement == placement }).isEmpty
        }
    }
    
    private func last(for placement: Placement) -> Card? {
        return self.cards.filter( { return $0.placement == placement } ).sorted(by: { $0.order < $1.order } ).last
    }
    
    private func receiveable(for placement: Placement) -> Card? {
        return self.cards.filter( { return $0.placement.tableau && $0.available } ).last
    }
    
    private func receiveable(for card: Card) -> Card? {
        return self.cards.filter( { return $0.placement.tableau && $0.available && card.valid(for: $0) } ).last
    }
    
    private func receiveables(for card: Card) -> [Card] {
        return self.cards.filter( { return $0.placement.tableau && $0.available && card.valid(for: $0) } )
    }
    
    private func receiveables() -> [Card] {
        return self.cards.filter( { return $0.placement.tableau && $0.available } )
    }
    
    private func moveable(for placement: Placement) -> Card? {
        return self.cards.filter( { return $0.placement == placement && $0.revealed } ).sorted(by: { $0.order < $1.order } ).first
    }
    
    private func moveables() -> [Card] {
        
        var moveables: [Card] = []
        
        for placement in Placement.allTableaus {
            guard let moveable = self.moveable(for: placement) else { continue }
            
            moveables.append(moveable)
        }
        
        return moveables
        
    }
    
    private func playables() -> [Card] {
        
        let receiveables = self.receiveables()
        let moveables = self.moveables()
        
        return moveables.union(with: receiveables)
        
    }
    
    
    
    private func order(for placement: Placement) -> Int {
        if let card = self.last(for: placement) {
            return card.order
        }
        
        return 0
    }
    
    private func count(for placement: Placement, with face: Face? = nil) -> Int {
        if let face = face {
            return self.cards.filter({ $0.placement == placement && $0.face == face }).count
        } else {
            return self.cards.filter({ $0.placement == placement }).count
        }
    }
    
    private func revealed() -> Bool {
        
        let count = self.cards.filter({ $0.revealed }).count
        
        let revealed = count >= 52
        
        return revealed
        
    }
    
    private func completed() -> Bool {
        
        var completed: [Suit: Bool] = [:]
        
        for suite in Suit.allCases {
            if let card = self.last(for: .foundation(suite)) {
                completed[suite] = card.rank == .king
            } else {
                completed[suite] = false
            }
        }
        
        return completed.allSatisfy { return $1 }
        
    }
    
    private func read(all placement: Placement) -> [Card] {
        return self.cards.filter({ $0.placement == placement }).sorted(by: { $0.order < $1.order })
    }
    
    //    private func position(_ card: Card, in placement: Placement, on target: Card? = nil) -> CGRect {
    //
    //        var bounds: CGRect = .zero
    //        var stagger: CGFloat = .zero
    //        var location: CGPoint = .zero
    //        let stagger_size = (self.card_size.height * (40/182))
    //
    //        if let target = target {
    //
    //            stagger = target.face == .up ? stagger_size : stagger_size / 2
    //
    //            bounds = target.bounds
    //
    //        } else {
    //
    //            stagger = CGFloat(card.order - 1) * (stagger_size / 2)
    //
    //            bounds = Table.instance[placement]
    //        }
    //
    //        switch placement {
    //        case .none, .ready:
    //            location = CGPoint(x: bounds.midX, y: bounds.maxY + self.card_size.height)
    //        case .tableau:
    //            location = CGPoint(x: bounds.minX, y: bounds.minY + stagger)
    //        case .foundation, .waste, .stock:
    //            location = CGPoint(x: bounds.minX, y: bounds.minY)
    //        }
    //
    //        return CGRect(x: location.x, y: location.y, width: self.card_size.width, height: self.card_size.height)
    //
    //    }
    
    private func move(_ card: Card, placement: MoveState<Placement>, revealed: MoveState<Bool>) {
        self.move(card, placement: placement, revealed: revealed, parent: MoveState<Card?>(from: nil, to: nil ))
    }
    
    private func move(_ card: Card, placement: MoveState<Placement>, revealed: MoveState<Bool>, parent: MoveState<Card?>) {
        
        let move = Move(id: self.undo_moves.endIndex + 1, card: card, placement: placement, revealed: revealed, parent: parent)
        
        self.undo_moves.append(move)
        
        move.debug()
        
        self.moves += 1
        
        if revealed.from != revealed.to {
            self.score += 10
        }
        
        if card.placement.foundation {
            if card.rank == .ace {
                self.score += 50
            } else {
                self.score += 10
            }
        }
        
        if card.placement.tableau {
            if card.rank == .king && card.order == 1 {
                self.score += 20
            }
        }
        
        if placement.from != placement.to {
            if placement.from.foundation {
                if card.rank == .ace {
                    self.score -= 30
                } else {
                    self.score -= 10
                }
            }
        }
        
        self.refresh()
        
    }
    
    //MARK: Public Methods
    
    public func start() {
        self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.elapsed += 1
        }
    }
    
    public func stop() {
        self.timer.invalidate()
    }
    
    public func reset() {
        self.elapsed = 0
        self.timer.invalidate()
    }
    
    public func refresh() {
        
        self.order_cards()
        self.autocompletable = self.revealed()
        
        self.objectWillChange.send()
        
    }

    public func undo() {
        if let move = self.undo_moves.popLast() {
            self.undo(move)
        }
    }
    
    public func restart() {
        
        for card in self.cards {
            card.available = false
            card.revealed = true
            card.moving = true
            card.face = .up
            card.parent = nil
            card.child = nil
            card.offset = .zero
            card.placement = .ready
            
            self.refresh()
        }
        
        self.cards.shuffle()
        
        var order = 1
        
        for card in self.cards {
            card.face = .down
            card.moving = false
            card.order = order
            card.offset = .zero
            card.revealed = false
            card.placement = .ready
            
            order += 1
        }
        
        self.stop()
        self.undo_moves = []
        
        self.elapsed = 0
        self.moves = 0
        self.score = 0
        
        self.state = .setup
        
        self.refresh()
        
        self.deal()
        
    }
    
    public func setup() {
        guard self.state == .ready else { return }
        
        for card in self.cards {
            card.available = false
            card.face = .down
            card.placement = .none
            card.offset = .zero
        }
        
        self.refresh()
        
        for card in self.cards {
            card.placement = .ready
        }
        
        self.elapsed = 0
        self.moves = 0
        self.score = 0
        
        self.state = .setup
        
        self.refresh()
    }
    
    public func deal() {
        
        guard self.state == .setup else { return }
        
        for column in Column.allCases {
            for i in 0...column.count {
                guard let card = self.cards.first(where: { return $0.placement == .ready }) else { break }
                
                if column.count == i {
                    card.available = true
                    card.revealed = true
                    card.face = .up
                }
                card.order = i + 1
                card.placement = .tableau(column)
                card.offset = .zero
                
                self.refresh()
            }
        }
        
        var order = 1
        
        while let card = self.cards.first(where: { return $0.placement == .ready }) {
            card.order = order
            card.offset = .zero
            card.placement = .stock
            
            order += 1
            
            self.refresh()
        }
        
        self.elapsed = 0
        self.moves = 0
        self.score = 0
        
        self.state = .dealt
    }
    
    public func regroup(_ data: CardEventData) {
        
        guard data.event == .reset else { return }
        
        data.card.offset = data.offset
        data.card.location = data.location
        data.card.moving = data.moving
        data.card.refresh()
        
        self.refresh()
    }
    
    public func drag(_ data: CardEventData) {
        
        guard data.event == .drag else { return }
        
        data.card.offset = data.offset
        data.card.location = data.location
        data.card.moving = data.moving
        data.card.refresh()
        
        self.refresh()
    }
    
    public func restock() {
        
        for card in self.cards.filter( { return $0.placement == .waste } ) {
            self.restock(card)
        }
        
        self.refresh()
    }
    
    public func restock(_ card: Card) {
        
        card.available = false
        card.order = self.order(for: .stock) + 1
        card.face = .down
        card.moving = false
        card.parent = nil
        card.child = nil
        card.offset = .zero
        card.placement = .stock
        
        card.refresh()
    }
    
    public func waste(_ card: Card) {
        
        let wasted = self.count(for: .waste)
        
        let revealed_state = MoveState(from: card.revealed, to: true)
        let placement_state = MoveState(from: card.placement, to: .waste)
        
        
        card.face = .up
        card.order = wasted + 1
        card.parent = nil
        card.revealed = true
        card.child = nil
        card.offset = .zero
        card.placement = .waste
        
        card.refresh()
        
        self.move(card, placement: placement_state, revealed: revealed_state)
        
        self.refresh()
    }
    
    public func waste(_ data: CardEventData) {
        
        data.card.offset = data.offset
        data.card.location = data.location
        data.card.moving = data.moving
        data.card.refresh()
        
        self.waste(data.card)
        
    }
    
    public func place(_ data: CardEventData) {
        
        guard data.event == .tap else { return }
        
        data.card.offset = data.offset
        data.card.location = data.location
        data.card.moving = data.moving
        data.card.refresh()
        
        self.place(data.card)
        
        self.refresh()
    }
    
    public func drop(_ data: CardEventData) {
        
        guard data.event == .drop else { return }
        
        data.card.offset = data.offset
        data.card.location = data.location
        data.card.moving = data.moving
        data.card.refresh()
        
        if let placement = self.placement(depot: data.location) {
            self.drop(data, on: placement)
        }
        
        self.refresh()
    }
    
    private func card(_ suite: Suit, _ rank: Rank) -> Card {
        let card = self.cards.first(where: { return $0.suit == suite && $0.rank == rank })!
        
        card.placement = .waste
        card.revealed = true
        card.available = true
        card.face = .up
        
        return card
    }
    
    public func test_setup() {
        
        // Waste
        
        let diamonds_two = self.card(.diamonds, .two)
        let clubs_eight = self.card(.clubs, .eight)
        let diamonds_three = self.card(.diamonds, .three)
        let spades_five = self.card(.spades, .five)
        let spades_four = self.card(.spades, .four)
        let diamonds_four = self.card(.diamonds, .four)
        let spades_three = self.card(.spades, .three)
        
        self.waste(diamonds_two)
        self.waste(clubs_eight)
        self.waste(diamonds_three)
        self.waste(spades_five)
        self.waste(spades_four)
        self.waste(diamonds_four)
        self.waste(spades_three)
        
        // Stock
        
        let hearts_six = self.card(.hearts, .six)
        let diamonds_five = self.card(.diamonds, .five)
        let diamonds_seven = self.card(.diamonds, .seven)
        let hearts_three = self.card(.hearts, .three)
        let spades_two = self.card(.spades, .two)
        let spades_ten = self.card(.spades, .ten)
        let hearts_nine = self.card(.hearts, .nine)
        let clubs_four = self.card(.clubs, .four)
        let clubs_six = self.card(.clubs, .six)
        
        self.restock(hearts_six)
        self.restock(diamonds_five)
        self.restock(diamonds_seven)
        self.restock(hearts_three)
        self.restock(spades_two)
        self.restock(spades_ten)
        self.restock(hearts_nine)
        self.restock(clubs_four)
        self.restock(clubs_six)
        
        // Tableau One
        let hearts_king = self.card(.hearts, .king)
        let spades_queen = self.card(.spades, .queen)
        let diamonds_jack = self.card(.diamonds, .jack)
        
        self.place(hearts_king, on: .tableau(.one))
        self.place(spades_queen, on: hearts_king)
        self.place(diamonds_jack, on: spades_queen)
        
        // Tableau Two
        let diamonds_ten = self.card(.diamonds, .ten)
        let spades_nine = self.card(.spades, .nine)
        let hearts_eight = self.card(.hearts, .eight)
        let spades_seven = self.card(.spades, .seven)
        let diamonds_six = self.card(.diamonds, .six)
        let clubs_five = self.card(.clubs, .five)
        let hearts_four = self.card(.hearts, .four)
        let clubs_three = self.card(.clubs, .three)
        let hearts_two = self.card(.hearts, .two)
        let spades_ace = self.card(.spades, .ace)
        
        self.place(diamonds_ten, on: .tableau(.two))
        self.place(spades_nine, on: diamonds_ten)
        self.place(hearts_eight, on: spades_nine)
        self.place(spades_seven, on: hearts_eight)
        self.place(diamonds_six, on: spades_seven)
        self.place(clubs_five, on: diamonds_six)
        self.place(hearts_four, on: clubs_five)
        self.place(clubs_three, on: hearts_four)
        self.place(hearts_two, on: clubs_three)
        self.place(spades_ace, on: hearts_two)
        
        // Tableau Three
        let spades_king = self.card(.spades, .king)
        let hearts_queen = self.card(.hearts, .queen)
        let clubs_jack = self.card(.clubs, .jack)
        let hearts_ten = self.card(.hearts, .ten)
        let clubs_nine = self.card(.clubs, .nine)
        let diamonds_eight = self.card(.diamonds, .eight)
        let clubs_seven = self.card(.clubs, .seven)
        
        self.place(spades_king, on: .tableau(.three))
        self.place(hearts_queen, on: spades_king)
        self.place(clubs_jack, on: hearts_queen)
        self.place(hearts_ten, on: clubs_jack)
        self.place(clubs_nine, on: hearts_ten)
        self.place(diamonds_eight, on: clubs_nine)
        self.place(clubs_seven, on: diamonds_eight)
        
        // Tableau Four
        let clubs_king = self.card(.clubs, .king)
        let diamonds_queen = self.card(.diamonds, .queen)
        let spades_jack = self.card(.spades, .jack)
        
        self.place(clubs_king, on: .tableau(.four))
        self.place(diamonds_queen, on: clubs_king)
        self.place(spades_jack, on: diamonds_queen)
        
        // Tableau Five
        let diamonds_king = self.card(.diamonds, .king)
        let clubs_queen = self.card(.clubs, .queen)
        let hearts_jack = self.card(.hearts, .jack)
        let clubs_ten = self.card(.clubs, .ten)
        let diamonds_nine = self.card(.diamonds, .nine)
        let spades_eight = self.card(.spades, .eight)
        let hearts_seven = self.card(.hearts, .seven)
        let spades_six = self.card(.spades, .six)
        let hearts_five = self.card(.hearts, .five)
        
        self.place(diamonds_king, on: .tableau(.five))
        self.place(clubs_queen, on: diamonds_king)
        self.place(hearts_jack, on: clubs_queen)
        self.place(clubs_ten, on: hearts_jack)
        self.place(diamonds_nine, on: clubs_ten)
        self.place(spades_eight, on: diamonds_nine)
        self.place(hearts_seven, on: spades_eight)
        self.place(spades_six, on: hearts_seven)
        self.place(hearts_five, on: spades_six)
        
        // Tableau Six
        
        // Tableau Seven
        
        // Foundation Diamonds
        let diamonds_ace = self.card(.diamonds, .ace)
        
        self.place(diamonds_ace, on: .foundation(.diamonds))
        
        // Foundation Spades
        
        // Foundation Hearts
        let hearts_ace = self.card(.hearts, .ace)
        
        self.place(hearts_ace, on: .foundation(.hearts))
        
        // Foundation Clubs
        let clubs_ace = self.card(.clubs, .ace)
        let clubs_two = self.card(.clubs, .two)
        
        self.place(clubs_ace, on: .foundation(.clubs))
        self.place(clubs_two, on: clubs_ace)
        
    }
    
    private func refill_waste() {
        if self.empty(for: .waste) {
            if let stock = self.last(for: .stock) {
                self.waste(stock)
            }
        }
    }
    
    private func tableau_aces_to_foundation() {
        let tableau_aces = self.cards.filter( { return $0.placement.tableau && $0.available && $0.rank == .ace } )
        
        for tableau_ace in tableau_aces {
            self.card_ace_to_foundation(tableau_ace)
        }
    }
    
    private func waste_ace_to_foundation() -> Bool {
        
        self.refill_waste()
        
        guard let waste = self.cards.last( where: { return $0.placement == .waste && $0.rank == .ace } ) else { return false }
        
        return self.card_ace_to_foundation(waste)
    }
    
    private func waste_king_to_tableau() -> Bool {
        
        self.refill_waste()
        
        guard let waste = self.cards.last( where: { return $0.placement == .waste && $0.rank == .king } ) else { return false }
        
        return self.card_king_to_tableau(waste)
    }
    
    private func card_king_to_tableau(_ card: Card) -> Bool {
        
        guard card.rank == .king else { return false }
        
        guard card.order > 1 else { return false }
        
        guard let placement = self.empty_tableaus().first else { return false }
        
        self.place(card, on: placement)
        
        return true
        
    }
    
    private func card_ace_to_foundation(_ card: Card) -> Bool {
        
        guard card.rank == .ace else { return false }
        
        self.place(card, on: .foundation(card.suit))
        
        return true
        
    }
    
    public func autoplay() {
        
        Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { timer in
            
            if self.completed() {
                timer.invalidate()
            }
            
            if self.empty(for: .stock) {
                self.restock()
            }
            
            if let stock = self.last(for: .stock) {
                self.waste(stock)
            }
            
            self.waste_ace_to_foundation()
            
            self.tableau_aces_to_foundation()
            
            // go over each tableau column to find matches (we need to figure out if there are any more moves available)
            
            let playables = self.playables()
            
            for playable in playables {
                
                guard !self.card_ace_to_foundation(playable) else { continue }
                
                guard !self.card_king_to_tableau(playable) else { continue }
                
                guard let receivable = self.receiveable(for: playable) else { continue }
                
                if let parent = playable.parent {
                    guard receivable.rank != parent.rank else { continue }
                }
                
                self.place(playable, on: receivable)
                
            }
            
            self.refill_waste()
            
            if let waste = self.cards.filter( { return $0.placement == .waste } ).sorted(by: { return $0.order < $1.order }).last {
                
                guard !self.card_king_to_tableau(waste) else { return }
                
                guard let match = self.receiveable(for: waste) else { return }
                
                self.place(waste, on: match)
            }
        }
    }
    
    public func autocomplete() {
        
        var suite = Suit.diamonds
        
        Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { timer in
            
            if self.completed() {
                timer.invalidate()
            }
            
            if self.empty(for: .stock) {
                self.restock()
            }
            
            if let stock = self.last(for: .stock) {
                self.waste(stock)
            }
            
            let waste = self.cards.filter( { return $0.placement == .waste && $0.suit == suite } )
            let foundations = self.cards.filter( { return $0.placement.tableau && $0.available && $0.suit == suite } )
            
            let available = waste + foundations
            
            for card in available {
                
                if let foundation = self.last(for: .foundation(suite)) {
                    
                    guard card.rank == foundation.rank.next else { continue }
                    
                    self.place(card, on: foundation)
                    
                } else {
                    
                    guard card.rank == .ace else { continue }
                    
                    self.place(card, on: .foundation(suite))
                }
            }
            
            suite = suite.next
        }
    }
    
    public func moves_available() -> Bool {
        
        let receiveables = self.receiveables()
        
        let playables = self.playables()
        
        for playable in playables {
            
            guard receiveables.last(where: { return playable.valid(for: $0) }) != nil else { continue }
            
            return true
            
        }
        
        return false
    }
}
