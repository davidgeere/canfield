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
    
    let suite: Suite
    let rank: Rank
    var placement: Placement
    var face: Face
    var available: Bool
    
    var order: Int {  didSet { self.refresh() } }
    var moving: Bool { didSet { self.refresh() } }
    var bounds: CGRect { didSet { self.refresh() } }
    
    var parent: Card?
    var child: Card?
    
    init(suite: Suite, rank: Rank, placement:Placement = .none, face: Face = .down, available: Bool = false, moving: Bool = false, order: Int = 0, bounds: CGRect = Globals.CARD.BOUNDS) {
        self.suite = suite
        self.rank = rank
        self.placement = placement
        self.face = face
        self.available = available
        self.moving = moving
        self.order = order
        self.bounds = bounds
    }
    
    public func refresh() {
        objectWillChange.send()
    }
    
    #if DEBUG
    public func debug() {
        print("card:", self.suite.symbol + self.rank.symbol, " | ", self.placement, " | ", self.available, " | ", self.face, " | ", self.bounds.origin)
    }
    #endif
    
}
