//
//  StockPile.swift
//  Canfield
//
//  Created by David Geere on 2/21/23.
//

import Foundation

class StockPile: Pile {
    
    var cards: [Card]
    
    var topCard: Card? {
        return self.cards.last
    }
    
    init(cards: [Card]) {
        self.cards = cards
    }
    
    func add(card: Card) {
        self.cards.append(card)
    }
    
    func removeTopCard() -> Card? {
        return self.cards.popLast()
    }
    
    func flipLastCardFaceUp() {}
    
    func canAdd(card: Card) -> Bool {
        return false
    }
}
