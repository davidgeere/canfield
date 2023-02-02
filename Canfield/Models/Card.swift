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
    var matched: Bool
    
    var bounds: CGRect
    
    var association: Card?
    
    init(suite: Suite, rank: Rank, placement:Placement = .none, face: Face = .down, available: Bool = false, matched: Bool = false) {
        self.suite = suite
        self.rank = rank
        self.placement = placement
        self.face = face
        self.available = available
        self.matched = matched
        self.bounds = CGRect(x: .zero, y: .zero, width: Globals.CARD.WIDTH, height: Globals.CARD.HEIGHT)
    }
    
}
