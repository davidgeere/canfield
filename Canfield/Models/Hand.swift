//
//  Hand.swift
//  Canfield
//
//  Created by David Geere on 2/22/23.
//

import Foundation

class Hand {
    
    private var cards: [Card]

    init(cards: [Card]) {
        self.cards = cards
    }

    func getCards() -> [Card] {
        return cards
    }

    func addCard(card: Card) {
        self.cards.append(card)
    }

    func removeCard(at index: Int) -> Card {
        return self.cards.remove(at: index)
    }
    
}
