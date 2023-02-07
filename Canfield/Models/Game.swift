//
//  Game.swift
//  Canfield
//
//  Created by David Geere on 2/2/23.
//

import Foundation
import SwiftUI
import Combine

class Game: ObservableObject {

    public static let preview:Game = Game()
    
    @Published public var dragger: CGRect = .zero
    
    @Published public var cards: [Card]
    @Published public var state: GameState {
        didSet {
            if self.state == .ready {
                self.setup()
            }
        }
    }
    
    @Published public var moves: [Move]
    
    public var table: Table
    
    init() {
        
        self.state = .none
        self.table = Table()
        self.cards = Deck.draw
        self.moves = []
        
    }
    
    //MARK: Private Methods 

    private func place(_ card: Card) {
        
        switch card.rank {
        case .ace:
            self.place(card, on: .foundation( card.suite ))
        case .king:
            if let target = self.target(card, for: .foundation(card.suite)) {
                self.place(card, on: target)
            } else {
                for column in Column.allCases {
                    guard self.empty(tableau: column) else { continue }
                    
                    self.place(card, on: .tableau( column ))
                    
                    return
                }
            }
        default:
            if let target = self.target(card, for: .foundation(card.suite)) {
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
        
        let from_placement = card.placement
        let from_parent = card.parent

        self.detach_from_previous_parent(card: card)
        
        if let target = target {
            self.place_card_on_card(child: card, parent: target)
        } else {
            self.place_card_on_depot(card: card, placement: placement)
        }
        
        self.move(card, placement: (from: from_placement, to: placement), parent: (from: from_parent, to: target))
        
        if from_placement == .waste {
            self.redeal_stock()
        } else {
            self.flip_over_previous_card(placement: from_placement)
        }
        
        self.refresh()
    }
    
    private func redeal_stock() {
        
        let wasted = self.cards.filter( { return $0.placement == .waste } ).count
        
        guard wasted <= 0 else { return }
            
        guard let stock = self.cards.first(where: { return $0.placement == .stock }) else { return }
        
        self.waste(stock)
    }
    
    private func flip_back_previous_card(placement: Placement) {
        
        guard let previous = self.cards.last(where: { return $0.placement == placement }) else { return }
        
        previous.available = false
        previous.face = .down
        previous.refresh()
        
    }
    
    private func flip_over_previous_card(placement: Placement) {
        
        guard let previous = self.cards.first(where: { return $0.placement == placement }) else { return }
        
        previous.available = true
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
        
        card.order = 1
        card.bounds = self.position(card, in: placement)
        card.placement = placement
        card.available = card.child == nil
        card.offset = .zero
        
    }
    
    private func place_card_on_card(child: Card, parent: Card) {
        
        parent.available = false
        parent.child = child
        parent.refresh()
        
        child.order = parent.order + 1
        
        child.bounds = self.position(child, in: parent.placement, on: parent)
        
        child.placement = parent.placement
        child.parent = parent
        child.offset = .zero
        
        child.available = child.child == nil

        child.refresh()
    }
    
    private func order_cards() {
        
        self.cards.sort { left, right in
            return left.placement.order > right.placement.order
        }
        
        self.cards.sort { left, right in
            return left.placement.order == right.placement.order && left.order > right.order
        }
        
        for placement in Placement.allCases {
            self.table[placement] = stacked_placement_bounds(placement: placement)
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
                        
            let collision = depot.overlap(area: self.table[placement])
            
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
                return self.table[placement]
            }
            
            let left = first.bounds.minX
            let top = first.bounds.minY
            
            let bottom = last.bounds.maxY
            let right = last.bounds.maxX
            
            let bounds = CGRect(x: left, y: top, width: right - left, height: bottom - top)
            
            return bounds
            
        default:
            return self.table[placement]
        }
        
    }
    
    private func target(_ card: Card, for placement: Placement) -> Card? {
        return self.cards.last( where: { $0.placement == placement && $0.available && card.valid(for: $0) } )
    }
    
    private func empty(foundation suite: Suite) -> Bool {
        return self.empty(for: .foundation(suite))
    }
    
    private func empty(tableau column: Column) -> Bool {
        return self.empty(for: .tableau(column))
    }
    
    private func empty(for placement: Placement, with face: Face? = nil) -> Bool {
        if let face = face {
            return self.cards.filter({ $0.placement == placement && $0.face == face }).isEmpty
        } else {
            return self.cards.filter({ $0.placement == placement }).isEmpty
        }
    }
    
    private func last(for placement: Placement) -> Card? {
        return self.cards.last(where: { $0.placement == placement })
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

    private func position(_ card: Card, in placement: Placement, on target: Card? = nil) -> CGRect {
        
        var bounds: CGRect = .zero
        var stagger: CGFloat = .zero
        var location: CGPoint = .zero
        
        if let target = target {
            
            stagger = target.face == .up ? Globals.CARD.OFFSET.UP : Globals.CARD.OFFSET.DOWN
            
            bounds = target.bounds
            
        } else {
            
            stagger = CGFloat(card.order - 1) * Globals.CARD.OFFSET.DOWN
            
            bounds = self.table[placement]
        }
        
        switch placement {
        case .none, .ready:
            
            location = CGPoint(x: bounds.midX, y: bounds.maxY + Globals.CARD.HEIGHT)
            
        case .tableau:
            
            location = CGPoint(x: bounds.minX, y: bounds.minY + stagger)
            
        case .foundation, .waste, .stock:
            
            location = CGPoint(x: bounds.minX, y: bounds.minY)
            
        }
        
        return CGRect(x: location.x, y: location.y, width: Globals.CARD.WIDTH, height: Globals.CARD.HEIGHT)
    }
    
    struct Move {
        let id: Int
        let card: Card
        let placement: (from: Placement, to: Placement)
        let parent: (from: Card?, to: Card?)
        let at: Date
        
        init(id: Int, card: Card, placement: (from: Placement, to: Placement), parent: (from: Card?, to: Card?)) {
            self.id = id
            self.card = card
            self.placement = placement
            self.parent = parent
            self.at = Date()
        }
    }
    
    private func move(_ card: Card, placement: (from: Placement, to: Placement)) {
        self.move(card, placement: placement, parent: (from: nil as Card?, to: nil as Card?))
    }
    
    private func move(_ card: Card, placement: (from: Placement, to: Placement), parent: (from: Card?, to: Card?)) {
        
        let move = Move(id: self.moves.endIndex + 1, card: card, placement: placement, parent: parent)
        
        self.moves.append(move)
        
        var from_parent = "none"
        var to_parent = "none"
        
        if let parent_from = parent.from {
            from_parent = parent_from.symbol
        }
        
        if let parent_to = parent.to {
            to_parent = parent_to.symbol
        }
        
        print("id:", move.id, "card:", card.symbol, "placement: ","from:", placement.from.name, "to:", placement.to.name, "parent:","from:", from_parent, "to:", to_parent)
        
    }
    
    //MARK: Public Methods
    
    public func refresh() {
        
        self.order_cards()
        
        self.objectWillChange.send()
        
    }
    
    public func undo() {
        if let move = self.moves.popLast() {
            self.undo(move)
        }
    }
    
    private func undo(_ move: Move) {
        
        // Reattach to previous parent
        if let parent = move.parent.from {
            
            parent.available = false
            parent.child = move.card
            parent.refresh()
            
            move.card.parent = parent
            
        } else {
            // if there was no previous parent
            if move.placement.from == .waste {
                ///self.redeal_stock() next to figure this out
            } else {
                self.flip_back_previous_card(placement: move.placement.from)
            }
        }

        if let target = move.parent.to {
            
            // Detach from new parent
            target.available = true
            target.child = nil
            target.refresh()

            // move back to previous place
            move.card.order = self.order(for: move.placement.from) + 1

            move.card.bounds = self.position(move.card, in: move.placement.from, on: move.parent.from)

            move.card.placement = move.placement.from
            move.card.parent = move.parent.from
            move.card.offset = .zero

            move.card.available = move.card.child == nil

            move.card.refresh()
            
        } else {
            move.card.order = 1
            move.card.bounds = self.position(move.card, in: move.placement.from)
            move.card.placement = move.placement.from
            move.card.available = move.card.child == nil
            move.card.offset = .zero
        }



        self.refresh()
    }
    
    public func restart() {
        
        for card in self.cards {
            card.available = false
            card.moving = true
            card.face = .up
            card.placement = .ready
            card.bounds = self.position(card, in: .ready)
            card.parent = nil
            card.child = nil
            card.offset = .zero
            
            self.refresh()
        }
        
        self.cards.shuffle()
        
        var order = 1
        
        for card in self.cards {
            card.face = .down
            card.placement = .ready
            card.moving = false
            card.order = order
            card.offset = .zero
            
            order += 1
        }
        
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
            card.bounds = self.position(card, in: .none)
            card.offset = .zero
        }
        
        self.refresh()
        
        for card in self.cards {
            card.placement = .ready
        }
        
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
                    card.face = .up
                }
                card.order = i + 1
                card.placement = .tableau(column)
                card.bounds = self.position(card, in: .tableau(column))
                card.offset = .zero

                self.refresh()
            }
        }

        var order = 1

        while let card = self.cards.first(where: { return $0.placement == .ready }) {
            card.placement = .stock
            card.bounds = self.position(card, in: .stock)
            card.order = order
            card.offset = .zero

            order += 1

            self.refresh()
        }

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
        
        var order = 1
        
        for card in self.cards.filter( { return $0.placement == .waste } ) {
            
            card.placement = .stock
            card.bounds = self.position(card, in: .stock)
            card.available = false
            card.order = order
            card.face = .down
            card.moving = false
            card.parent = nil
            card.child = nil
            card.offset = .zero
            
            card.refresh()
            
            order += 1
            
        }
        
        self.refresh()
        
    }
    
    public func waste(_ card: Card) {
        
        let wasted = self.count(for: .waste)
        
        card.placement = .waste
        card.bounds = self.position(card, in: .waste)
        
        card.face = .up
        card.order = wasted + 1
        card.parent = nil
        card.child = nil
        card.offset = .zero
        
        card.refresh()
        
        self.move(card, placement: (from: .stock, to: .waste))
        
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
        
//        if data.card.moving {
//            data.card.moving = false
//        }
        
        self.refresh()
    }
}
