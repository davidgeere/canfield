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
        
        card.detach()
        
        if let target {
            card.place(on: target)
        } else {
            
            let order = self.count(for: placement) + 1
            
            card.place(on: placement, order: order, last: card.child == nil)
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
        
        switch move.card.placement {
        case .stock:
            move.card.face = .down
        case .waste:
            move.card.face = .up
        default: break
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
        
        if let target = self.available(for: placement) {
            
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
    
    private func available(for placement: Placement) -> Card? {
        return self.cards.filter( { return $0.placement == placement && $0.available } ).sorted(by: { $0.order < $1.order } ).last
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
        
        self.cards.forEach { $0.reset() }
        
        self.cards.shuffle()
        
        self.cards.enumerated().forEach { $1.place(on: .ready, order: $0 + 1) }
        
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
        
        self.cards.forEach { $0.place(on: .none) }
        
        self.refresh()
        
        self.cards.forEach { $0.place(on: .ready) }
        
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
                
                card.place(on: .tableau(column), order: i + 1, last: column.count == i )
                
                self.refresh()
            }
        }
        
        self.cards.filter({ return $0.placement == .ready }).enumerated().forEach { $1.place(on: .stock, order: $0 + 1) }
        
        self.refresh()
        
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
        card.place(on: .stock, order: self.order(for: .stock) + 1)
    }
    
    public func waste(_ card: Card) {
        
        let revealed_state = MoveState(from: card.revealed, to: true)
        let placement_state = MoveState(from: card.placement, to: .waste)
        
        card.place(on: .waste, order: self.order(for: .waste) + 1)
        
        self.move(card, placement: placement_state, revealed: revealed_state)
        
        self.refresh()
    }
    
    public func waste(_ data: CardEventData) {
        
        data.card.moving(data)
        
        self.waste(data.card)
        
    }
    
    public func place(_ data: CardEventData) {
        
        guard data.event == .tap else { return }
        
        data.card.moving(data)
        
        self.place(data.card)
        
        self.refresh()
    }
    
    public func drop(_ data: CardEventData) {
        
        guard data.event == .drop else { return }
        
        data.card.moving(data)
        
        if let placement = self.placement(depot: data.location) {
            self.drop(data, on: placement)
        }
        
        self.refresh()
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
