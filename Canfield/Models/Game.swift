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
    
    public var table: Table
    
    init() {
        
        self.state = .none
        self.table = Table()
        self.cards = Deck.draw
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
        
        if card.placement == .waste {
            self.redeal_stock()
        } else {
            self.flip_over_previous_card(card: card)
        }
        
        self.detach_from_previous_parent(card: card)
        
        if let target = target {
            self.place_card_on_card(child: card, parent: target)
        } else {
            self.place_card_on_depot(card: card, placement: placement)
        }
        
        self.refresh()
    }
    
    private func redeal_stock() {
        
        let wasted = self.cards.filter( { return $0.placement == .waste } ).count
        
        guard wasted <= 0 else { return }
            
        guard let stock = self.cards.first(where: { return $0.placement == .stock }) else { return }
        
        self.waste(stock)
    }
    
    private func flip_over_previous_card(card: Card) {
        
        guard let previous = self.cards.first(where: { return $0.placement == card.placement && $0.order == card.order - 1 }) else { return }
        
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
        
        card.placement = placement
        card.order = 1
        card.offset = .zero
        card.available = card.child == nil
        
        card.bounds = self.position(card, in: placement)
    }
    
    private func place_card_on_card(child: Card, parent: Card) {
        
        parent.available = false
        parent.child = child
        parent.refresh()
        
        child.placement = parent.placement
        child.order = parent.order + 1
        child.parent = parent
        child.offset = .zero
        
        child.available = child.child == nil
        
        child.bounds = self.position(child, in: parent.placement, on: parent)
        
        child.moving = false
        
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
    
    //MARK: Public Methods
    
    public func refresh() {
        
        self.order_cards()
        
        self.objectWillChange.send()
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
        data.card.moving = false
        
        self.refresh()
    }
    
    public func drag(_ data: CardEventData) {
        
        guard data.event == .drag else { return }
        
        data.card.offset = data.offset
        data.card.location = data.location
        data.card.moving = true
        
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
        
        card.moving = false
        
        card.refresh()
        
        self.refresh()
    }
    
    public func waste(_ data: CardEventData) {
        
        self.waste(data.card)
        
    }
    
    public func place(_ data: CardEventData) {
        
        guard data.event == .tap else { return }
        
        data.card.moving = false
        
        self.place(data.card)
        
        self.refresh()
    }
    
    public func drop(_ data: CardEventData) {
        
        guard data.event == .drop else { return }
        
        data.card.offset = data.offset
        data.card.moving = false
        
        if let placement = self.placement(depot: data.location) {
            self.drop(data, on: placement)
        }
        
        self.refresh()
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
    
    private func count(for placement: Placement, with face: Face? = nil) -> Int {
        if let face = face {
            return self.cards.filter({ $0.placement == placement && $0.face == face }).count
        } else {
            return self.cards.filter({ $0.placement == placement }).count
        }
    }
    
    public func position(_ card: Card, in placement: Placement, on target: Card? = nil) -> CGRect {
        
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
}
