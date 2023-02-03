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
    
    public func refresh() {
        self.objectWillChange.send()
    }
    
    public func restart() {
        
        for card in self.cards {
            card.available = false
            card.moving = true
            card.face = .up
            card.placement = .ready
            card.bounds = self.position(card)
            card.parent = nil
            card.child = nil
            
            self.refresh()
        }
        
        self.cards.shuffle()
        
        var order = 1
        
        for card in self.cards {
            card.face = .down
            card.placement = .ready
            card.moving = false
            card.order = order
            
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
            card.bounds = self.position(card)
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
                card.bounds = self.position(card, extra: CGPoint(x: 0, y: i * 20))
                
                self.refresh()
            }
        }
        
        var order = 1
        
        while let card = self.cards.first(where: { return $0.placement == .ready }) {
            card.placement = .stock
            card.bounds = self.position(card)
            card.order = order
            
            order += 1
            
            self.refresh()
        }
        
        self.state = .dealt
    }
    
    public func moving(_ data: CardEventData) {
        
        guard !data.card.moving else { return }
        
        data.card.moving = true
        
        if let child = data.card.child {
            child.moving = true
        }
        
        self.refresh()
    }
    

    private func drop_on_card(_ card: Card, placement:Placement, available: Card? = nil) -> Bool {
        
        guard self.valid_drop_on_card(card, placement: placement, available: available) else { return false }
        
        if card.placement == .waste {
            
            let wasted = self.cards.filter( { return $0.placement == .waste } ).count
            
            if wasted <= 0 {
                
                if let stock = self.cards.first(where: { return $0.placement == .stock }) {
                    self.waste(stock)
                }
                
            }
            
        } else {
            if let previous = self.cards.first(where: { return $0.placement == card.placement && $0.order == card.order - 1 }) {
                
                previous.available = true
                previous.face = .up
                previous.refresh()
                
            }
        }
        
        if let parent = card.parent {
            
            card.parent = nil
            parent.child = nil
            parent.refresh()
            
        }
        
        var pique: CGFloat = .zero
        var bounds: CGRect = .zero
        
        if let available = available {
            
            pique = available.placement.is_foundation ? 0.0 : 40.0
            
            bounds = available.bounds
            
            card.bounds = CGRect(x: bounds.minX, y: bounds.minY + pique, width: card.bounds.width, height: card.bounds.height)
            
            available.available = false
            available.child = card
            
            card.placement = available.placement
            card.order = available.order + 1
            card.parent = available
            
            available.refresh()
            
        } else {
            
            bounds = self.table[placement]
            
            card.bounds = CGRect(x: bounds.midX, y: bounds.midY + pique, width: card.bounds.width, height: card.bounds.height)
            
            card.placement = placement
            card.order = 1
            card.parent = nil
            
        }
        
        card.moving = false
        
        card.refresh()
        
        self.refresh()
        
        return true
    }
    
    private func valid_tableau_drop(_ card: Card, placement: Placement, available: Card? = nil) -> Bool {
        
        if let available = available {
            
            guard available.suite.pair != card.suite.pair  else { return false }
            
            guard available.rank.previous != nil else { return false }
            
            guard available.rank.previous == card.rank else { return false }
            
        } else {
            
            guard card.rank == .king else { return false }
            
        }
        
        return true
    }
    
    private func valid_foundation_drop(_ card: Card, placement: Placement, available: Card? = nil) -> Bool {
        
        if let available = available {
        
            guard available.suite.pair == card.suite.pair  else { return false }
            
            guard available.rank.next != nil else { return false }
            
            guard available.rank.next == card.rank else { return false }
            
        } else {
            
            guard card.rank == .ace else { return false }
            
            guard card.suite == placement.suite else { return false }
            
        }
        
        return true
    }
    
    private func valid_drop_on_card(_ card: Card, placement: Placement, available: Card? = nil) -> Bool {
        
        if placement.is_tableau {
            
            guard self.valid_tableau_drop(card, placement: placement, available: available) else { return false }
            
        } else if placement.is_foundation {
            
            guard self.valid_foundation_drop(card, placement: placement, available: available) else { return false }
            
        } else {
            
            return false
            
        }
        
        return true
    }
    
    private func drop_in_bounds(location: CGPoint, area: CGRect) -> Bool {
        
        let in_width = abs(area.origin.x - location.x) < area.width
        let in_height = abs(area.origin.y - location.y) < area.height
        
        guard in_height && in_width else { return false }
        
        return true
    }
    
    private func drop_on_cards(_ data: CardEventData) -> Bool {
        
        let card = data.card
        let event = data.event
        let location = data.location
        
        for available in self.cards.filter({ return $0.available && $0.id != card.id && ($0.placement != .waste || $0.placement != .stock) }) {
            
            
            if event == .drop {
                
                let bounds = available.bounds
                
                guard drop_in_bounds(location: location, area: bounds) else { continue }
                
            }
            
            guard self.drop_on_card(card, placement: available.placement, available: available) else { continue }
            
            return true
        }
        
        return false
        
    }
    
    private func drop_on_tableau(_ data: CardEventData) -> Bool {
        
        let card = data.card
        let event = data.event
        let location = data.location
        
        for column in Column.allCases {

            let placement:Placement = .tableau(column)

            guard data.card.placement != placement else { continue }

            if event == .drop {
                
                let bounds = self.table[placement]
                
                guard drop_in_bounds(location: location, area: bounds) else { continue }
            }
            
            if let available = self.cards.first( where: { return $0.placement == placement && $0.available } ) {
                
                guard self.drop_on_card(card, placement: placement, available: available) else { continue }
                
                return true
                
            }
            
            guard self.drop_on_card(card, placement: placement) else { continue }
            
            return true
        }
        
        return false
        
    }
    
    private func drop_on_foundation(_ data: CardEventData) -> Bool {
        
        let card = data.card
        let event = data.event
        let location = data.location
        
        for suite in Suite.allCases {
            
            let placement:Placement = .foundation(suite)
            
            if event == .drop {
                
                let bounds = self.table[placement]
                
                guard drop_in_bounds(location: location, area: bounds) else { continue }
            }
            
            if let available = self.cards.first( where: { return $0.placement == placement && $0.available } ) {
                
                guard self.drop_on_card(card, placement: placement, available: available) else { continue }
                
                return true
                
            }
            
            guard self.drop_on_card(card, placement: placement) else { continue }
            
            return true
        }
        
        return false
        
    }
    
    public func waste(_ card: Card) {
        
        let wasted = self.cards.filter( { return $0.placement == .waste } ).count
        
        if wasted > 0 {
            
            for stocked in self.cards.filter( { return $0.placement == .stock } ) {
                
                stocked.order = stocked.order + wasted
                
                stocked.refresh()
            }
            
        }
        
        var order = 1
        
        for wasted in self.cards.filter( { return $0.placement == .waste } ) {
        
            let bounds = self.table[.stock]
            
            wasted.placement = .stock
            wasted.bounds = CGRect(x: bounds.midX, y: bounds.midY, width: card.bounds.width, height: card.bounds.height)
            wasted.moving = false
            wasted.order = order
            wasted.face = .down
            
            wasted.refresh()
            
            order += 1

        }
        
        let bounds = self.table[.waste]
        
        card.bounds = CGRect(x: bounds.midX, y: bounds.midY, width: card.bounds.width, height: card.bounds.height)
        
        card.placement = .waste
        card.face = .up
        card.order = 1
        card.parent = nil
        card.child = nil
        
        card.moving = false
        
        card.refresh()
        
        self.refresh()
        
    }
    
    public func waste(_ data: CardEventData) {
        
        self.waste(data.card)
        
    }
    
    public func place(_ data: CardEventData) {
        
        guard data.event == .tap else { return }
        
        guard !drop_on_cards(data) else { return }
        
        guard !drop_on_tableau(data) else { return }
        
        guard !drop_on_foundation(data) else { return }
        
    }
    
    public func drop(_ data: CardEventData) {
        
        guard data.event == .drop else { return }
        
        guard !drop_on_cards(data) else { return }
        
        guard !drop_on_tableau(data) else { return }
        
        guard !drop_on_foundation(data) else { return }

    }
    
    public func position(_ card:Card, extra:CGPoint = .zero) -> CGRect {
        if card.placement == .none || card.placement == .ready {
            
            let x = self.table.bounds.midX
            let y = self.table.bounds.maxY + Globals.CARD.HEIGHT
            
            return CGRect(x: x, y: y, width: Globals.CARD.WIDTH, height: Globals.CARD.HEIGHT)
            
        } else {
            
            let x = self.table[card.placement].origin.x + (self.table[card.placement].width / 2) + extra.x
            let y = self.table[card.placement].origin.y + (self.table[card.placement].height / 2) + extra.y
            
            return CGRect(x: x, y: y, width: Globals.CARD.WIDTH, height: Globals.CARD.HEIGHT)
        }
    }
}
