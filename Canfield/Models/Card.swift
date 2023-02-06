//
//  Card.swift
//  Canfield
//
//  Created by David Geere on 2/2/23.
//

import Foundation

class Card: Identifiable, Equatable, ObservableObject {
    
    var id:Int {
        return ((suite.value - 1) * Rank.count) + rank.value
    }
    
    static func == (lhs: Card, rhs: Card) -> Bool {
        return lhs.id == rhs.id
    }
    
    var symbol: String {
        return self.suite.symbol + self.rank.symbol
    }
    
    let suite: Suite
    let rank: Rank
    var placement: Placement {
        didSet {
            
            if let child = self.child {
                child.placement = self.placement
            }
            
            self.refresh()
        }
    }
    var face: Face
    var available: Bool {
        didSet {
            self.refresh()
        }
    }
    
    var order: Int {
        didSet {
            
            if let child = self.child {
                child.order = self.order + 1
            }
            
            self.refresh()
        }
    }
    
    var moving: Bool {
        didSet {
            
            if let child = self.child {
                child.moving = self.moving
            }
            
            self.refresh()
            
        }
    }
    
    var bounds: CGRect {
        didSet {
            
            if let child = self.child {
                child.offset = self.offset
                child.bounds = CGRect(origin: CGPoint(x: self.bounds.origin.x, y: self.bounds.origin.y + Globals.CARD.OFFSET.UP), size: self.bounds.size)
            }
            
            self.refresh()
        }
    }
    
    var offset: CGSize {
        didSet {
            
            if let child = self.child {
                child.offset = self.offset
            }
            
            self.refresh()
        }
    }
    
    var location: CGRect {
        didSet {
            
            if let child = self.child {
                child.location = self.location
            }
            
            self.refresh()
        }
    }
    
    var zindex: Double {
        if self.moving {
            return Double(self.order * 10 )
        }
        
        return Double(self.order)
    }
    
    var match: Bool {
        didSet {
            if let child = self.child {
                child.match = self.match
            }
        }
    }
    
    var parent: Card?
    var child: Card?
    
    init(suite: Suite, rank: Rank, placement:Placement = .none, face: Face = .down, available: Bool = false, moving: Bool = false, order: Int = 0, bounds: CGRect = Globals.CARD.BOUNDS, offset: CGSize = .zero, location: CGRect = .zero) {
        self.suite = suite
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
                  self.suite == placement.suite else { return false }
            
            return true
            
        default:
            
            return false
        }
    }
    
    public func valid(for target: Card) -> Bool {
        switch target.placement {
        case .tableau:
            
            guard target.suite.pair != self.suite.pair,
                  target.rank.previous != nil,
                  target.rank.previous == self.rank else { return false }
            
            return true
            
        case .foundation:
            
            guard target.suite.pair == self.suite.pair,
                  target.rank.next != nil,
                  target.rank.next == self.rank else { return false }
            
            return true
            
        default:
            return false
        }
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
