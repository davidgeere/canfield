//
//  Deck.swift
//  Canfield
//
//  Created by David Geere on 2/2/23.
//

import Foundation

struct Deck {
    
    public static let draw:[Card] = Deck().cards
    
    private let cards:[Card]
    
    private init() {
        var _cards:[Card] = []
        
        for suite in Suite.allCases {
            for rank in Rank.allCases {
                
                let card = Card(suite: suite, rank: rank)
                
                if _cards.contains(where: { return $0.id == card.id }) { continue }
                
                _cards.append(card)
            }
        }
        
        self.cards = _cards.shuffled()
    }
}
