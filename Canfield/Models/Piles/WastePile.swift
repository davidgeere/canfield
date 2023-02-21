//
//  WastePile.swift
//  Canfield
//
//  Created by David Geere on 2/21/23.
//

import Foundation

class WastePile: Pile {
    
    var cards: [Card] = []
    
    var topCard: Card? {
        return self.cards.last
    }
    
    func add(card: Card) {
        self.cards.append(card)
    }
    
    func removeTopCard() -> Card? {
        return self.cards.popLast()
    }
    
    func flipLastCardFaceUp() {
        self.topCard?.face = .up
    }
    
    func canAdd(card: Card) -> Bool {
        return true
    }
}
