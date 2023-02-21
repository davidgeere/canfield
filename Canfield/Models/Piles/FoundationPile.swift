//
//  FoundationPile.swift
//  Canfield
//
//  Created by David Geere on 2/21/23.
//

import Foundation

class FoundationPile: Pile {
    
    var cards: [Card] = []
    
    var topCard: Card? {
        return self.cards.last
    }
    
    let suit: Suit
    
    init(suit: Suit) {
        self.suit = suit
    }
    
    func add(card: Card) {
        self.cards.append(card)
    }
    
    func removeTopCard() -> Card? {
        return self.cards.popLast()
    }
    
    func flipLastCardFaceUp() {}
    
    func canAdd(card: Card) -> Bool {
        return self.cards.isEmpty && card.rank == .ace ||
               self.topCard?.nextRank() == card.rank &&
               self.topCard?.suit == card.suit
    }
}
