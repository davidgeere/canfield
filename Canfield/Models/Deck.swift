//
//  Deck.swift
//  Canfield
//
//  Created by David Geere on 2/2/23.
//

import Foundation

class Deck {
    
    public static let instance = Deck()
    
    @Published public private(set) var cards:[Card]
    
    public private(set) var size: CGSize
    
    private init() {
        var _cards:[Card] = []
        
        for suite in Suite.allCases {
            for rank in Rank.allCases {
                
                let card = Card(suite: suite, rank: rank)
                
                if _cards.contains(where: { return $0.id == card.id }) { continue }
                
                _cards.append(card)
            }
        }
        
        _cards.shuffle()
        
        self.cards = _cards
        
        self.size = GLOBALS.CARD.SIZE
    }
    
    public func resize(_ value: CGSize) {
        self.size = value
    }
    
    public func resized(_ value: CGSize) -> CGSize {
        self.resize(value)
        
        return self.size
    }
}
