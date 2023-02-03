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
    

    private func drop_on_card(_ card: Card, available: Card) {
        
        if let previous = self.cards.first(where: { return $0.placement == card.placement && $0.order == card.order - 1 }) {
            previous.available = true
            previous.face = .up
            previous.refresh()
        }
        
        if let parent = card.parent {
            card.parent = nil
            parent.child = nil
            parent.refresh()
        }
        
        available.available = false
        
        card.moving = false
        
        card.placement = available.placement
        
        card.bounds = CGRect(x: available.bounds.minX, y: available.bounds.minY + 40, width: card.bounds.width, height: card.bounds.height)
        card.order = available.order + 1
        card.parent = available
        
        available.child = card
        
        card.refresh()
        available.refresh()
        
        self.refresh()
        
    }
    
    private func valid_tableau_drop(_ card: Card, available: Card) -> Bool {
        guard available.suite.pair != card.suite.pair  else { return false }
        
        guard available.rank.previous != nil else { return false }
        
        guard available.rank.previous == card.rank else { return false }
        
        return true
    }
    
    private func valid_foundation_drop(_ card: Card, available: Card) -> Bool {
        guard available.suite.pair == card.suite.pair  else { return false }
        
        guard available.rank.next != nil else { return false }
        
        guard available.rank.next == card.rank else { return false }
        
        return true
    }
    
    private func valid_drop_on_card(_ card: Card, available: Card) -> Bool {
        
        if available.placement.is_tableau {
            
            guard self.valid_tableau_drop(card, available: available) else { return false }
            
        } else if available.placement.is_foundation {
            
            guard self.valid_foundation_drop(card, available: available) else { return false }
            
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
    
    public func over(_ data: CardEventData) {
            
        let card = data.card
        let event = data.event
        let location = data.location
        
        for available in self.cards.filter({ return $0.available && $0.id != card.id && ($0.placement != .waste || $0.placement != .stock) }) {
            
            let bounds = available.bounds
            
            guard drop_in_bounds(location: location, area: available.bounds) && event == .drop else { continue }
            
            guard self.valid_drop_on_card(card, available: available) else { continue }
            
            self.drop_on_card(card, available: available)
            
            return
        }
        
        for column in Column.allCases {

            let placement:Placement = .tableau(column)

            guard data.card.placement != placement else { continue }

            let bounds = self.table[placement]

            guard drop_in_bounds(location: data.location, area: bounds) && data.event == .drop else { continue }

            card.moving = false
            card.bounds = CGRect(x: bounds.midX, y: bounds.midY, width: card.bounds.width, height: card.bounds.height)

            self.refresh()

            return
        }
        
//        for suite in Suite.allCases {
//
//            let placement:Placement = .foundation(suite)
//
//            let bounds = self.table[placement]
//
//            guard bounds.contains(location) && event == .drop else { continue }
//
//            card.moving = false
//            card.bounds = CGRect(x: bounds.midX, y: bounds.midY, width: card.bounds.width, height: card.bounds.height)
//
//            self.refresh()
//
//            return
//        }
        
        //// -------
        
        //
        //        for data in self.foundation_data {
        //            if data.bounds.contains(event_data.location) {
        //                let layout = self.to_layout(event_data.card.placement)
        //
        //                if self.deck.valid_drag_build_up(event_data.card, suite: data.suite, layout: layout) {
        //
        //                    event_data.card.matched = true
        //
        //                    if event_data.event == .drop {
        //                        if self.deck.drag_build_up(event_data.card, suite: data.suite, layout: layout) {
        //                            event_data.card.matched = false
        //                            return
        //                        }
        //                    }
        //                }
        //            }
        //        }
        //
        //        for data in self.tableau_data {
        //            if data.bounds.contains(event_data.position) {
        //                let layout = self.to_layout(event_data.card.placement)
        //
        //                if self.deck.valid_drag_build_down(event_data.card, column: data.column, layout: layout) {
        //
        //                    print("tableau")
        //
        //                    event_data.card.matched = true
        //
        //                    if event_data.event == .drop {
        //                        if self.deck.drag_build_down(event_data.card, column: data.column, layout: layout) {
        //                            event_data.card.matched = false
        //                            return
        //                        }
        //                    }
        //                }
        //            }
        //        }
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
