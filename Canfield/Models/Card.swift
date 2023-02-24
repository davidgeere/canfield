//
//  Card.swift
//  Canfield
//
//  Created by David Geere on 2/2/23.
//

import Foundation

class Card: Identifiable, Equatable, ObservableObject {
    
    var id:Int {
        return ((suit.value - 1) * Rank.count) + rank.value
    }
    
    static func == (left: Card, right: Card) -> Bool {
        return left.id == right.id
    }
    
    var symbol: String {
        return self.suit.symbol + self.rank.symbol
    }
    
    let suit: Suit
    let rank: Rank
    
    public /*private (set)*/ var placement: Placement {
        didSet {
            
            self.rebuild()
            
            if let child {
                child.placement = self.placement
            }
            
            self.refresh()
        }
    }
    
    var face: Face {
        didSet {
            self.refresh()
        }
    }
    
    var available: Bool {
        didSet {
            self.refresh()
        }
    }
    
    var order: Int {
         didSet {
            
            if let child {
                child.order = self.order + 1
            }
            
            self.refresh()
        }
    }
    
    var moving: Bool {
        didSet {
            
            if let child {
                child.moving = self.moving
            }
            
            self.refresh()
            
        }
    }
    
    var bounds: CGRect {
        didSet {
            
            if let child {
                child.offset = self.offset
                
                child.rebuild()
            }
            
            self.refresh()
        }
    }
    
    var offset: CGSize {
        didSet {
            
            if let child {
                child.offset = self.offset
            }
            
            if self.offset == .zero {
                self.moving = false
            } else {
                self.moving = true
            }
            
            self.refresh()
        }
    }
    
    var location: CGRect {
        didSet {
            
            if let child {
                child.location = self.location
            }
            
            self.refresh()
        }
    }
    
    var zindex: Double {
        if self.moving {
            return Double(self.placement.order + self.order) * 10
        } else {
            return Double(self.placement.order + self.order)
        }
    }
    
    var match: Bool {
        didSet {
            if let child = self.child {
                child.match = self.match
            }
        }
    }
    
    var revealed: Bool
    var last: Bool
    
    var parent: Card?
    
    var child: Card?
    
    init(suite: Suit, rank: Rank, placement:Placement = .none, face: Face = .down, available: Bool = false, moving: Bool = false, order: Int = 0, bounds: CGRect = .zero, offset: CGSize = .zero, location: CGRect = .zero) {
        self.suit = suite
        self.rank = rank
        self.placement = placement
        self.face = face
        self.available = available
        self.moving = moving
        self.order = order
        self.bounds = bounds
        self.offset = offset
        self.location = location
        self.match = false
        self.revealed = false
        self.last = false
    }
    
    public func reveal() {
        self.revealed = true
    }
    
    public func hide() {
        self.revealed = false
    }
    
    public func refresh() {
        objectWillChange.send()
    }
    
    public func valid(for placement: Placement) -> Bool {
        switch placement {
        case .tableau:
            
            guard self.rank == .king else { return false }
            
            return true
            
        case .foundation:
            
            guard self.rank == .ace,
                  self.suit == placement.suite else { return false }
            
            return true
            
        default:
            
            return false
        }
    }
    
    public func valid(for target: Card) -> Bool {
        switch target.placement {
        case .tableau:
            
            guard target.suit.pair != self.suit.pair,
                  target.rank.previous != nil,
                  target.rank.previous == self.rank else { return false }
            
            return true
            
        case .foundation:
            
            guard target.suit.pair == self.suit.pair,
                  target.rank.next != nil,
                  target.rank.next == self.rank else { return false }
            
            return true
            
        default:
            return false
        }
    }
    
    public func moving(_ data: CardEventData) {
        
        data.card.offset = data.offset
        data.card.location = data.location
        data.card.moving = data.moving
        data.card.refresh()
        
    }
    
    public func reset() {
        
        self.order = 1
        self.placement = .ready
        self.available = false
        self.revealed = true
        self.moving = true
        self.face = .up
        self.parent = nil
        self.child = nil
        self.offset = .zero
        self.match = false
        
        self.refresh()
    }
    
    public func place(on placement: Placement, order: Int = 1, last: Bool = false) {
        
        self.order = order
        self.placement = placement
        self.offset = .zero
        self.moving = false
        self.match = false
        
        switch placement {
        case .stock: self.onStock()
        case .waste: self.onWaste()
        case .foundation: self.onFoundation()
        case .tableau: self.onTableau(last: last)
        case .ready: self.onReady()
        case .none: self.onNone()
        }
        
        self.refresh()
        
    }
    
    public func detach() {
        
        guard let parent = self.parent else { return }
        
        parent.available = true
        parent.child = nil
        parent.refresh()
        
        self.parent = nil
        
    }
    
    public func place(on target: Card) {
        
        self.parent = target

        if let parent {
            
            parent.available = false
            parent.child = self
            parent.refresh()
            
            self.order = parent.order + 1
            self.placement = parent.placement
            self.available = self.child == nil
            self.offset = .zero
        }
        
        self.refresh()
    }
    
    public func rebuild() {
        
        var stagger: CGFloat = .zero
        
        let stagger_size = (Deck.instance.size.height * GLOBALS.CARD.STAGGER)
        var area: CGRect = .zero
        
        if let parent {
            stagger = parent.face == .up ? stagger_size : stagger_size / 2
            area = parent.bounds
            
        } else {
            stagger = CGFloat(self.order - 1) * (stagger_size / 2)
            area = Table.instance[placement]
        }
        
        switch self.placement {
        case .none, .ready:
            self.bounds = CGRect(x: area.midX, y: area.maxY + Deck.instance.size.height, width: Deck.instance.size.width, height: Deck.instance.size.height)
        case .tableau:
            self.bounds = CGRect(x: area.minX, y: area.minY + stagger, width: Deck.instance.size.width, height: Deck.instance.size.height)
        case .foundation, .waste, .stock:
            self.bounds = CGRect(x: area.minX, y: area.minY, width: Deck.instance.size.width, height: Deck.instance.size.height)
        }
    }
    
    public func onWaste() {
        
        self.available = false
        self.face = .up
        self.parent = nil
        self.child = nil
        self.revealed = true
        
    }
    
    public func onStock() {

        self.available = false
        self.face = .down
        self.parent = nil
        self.child = nil
        
    }
    
    public func onFoundation() {
        
        self.available = true
        self.face = .up
        self.parent = nil
        self.child = nil
        self.revealed = true
        
    }
    
    public func onTableau(last: Bool = false) {
        
        self.last = last
        self.available = false
        
        if self.last {
            self.revealed = true
            self.available = true
            self.face = .up
        }
        
    }
    
    public func onReady() {
        
        self.available = false
        self.face = .down
        self.revealed = false
        
    }
    
    public func onNone() {
        
        self.available = false
        self.face = .down
        self.revealed = false
        
    }
    
#if DEBUG
    public func debug(_ method:String = .empty) {
        
        var parent_name = "none"
        var child_name = "none"
        
        if let child = self.child {
            child_name = child.symbol
        }
        
        if let parent = self.parent {
            parent_name = parent.symbol
        }
        
        print(method, "card:", self.symbol, " | ", self.placement.name, " | ", self.available, " | ", self.face, " | ", parent_name, " | ", child_name, " | ", self.bounds.origin, " | ", self.offset)
    }
#endif
    
}
