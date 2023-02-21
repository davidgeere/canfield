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
        
        self.size = GLOBALS.CARD.SIZE
        
        self.cards = []
        
        self.cards = self.sorted()
        
        self.cards.shuffle()
        
    }
    
    public func sorted() -> [Card] {
        
        var _cards:[Card] = []
        
        for suite in Suit.allCases {
            for rank in Rank.allCases {
                
                let card = Card(suite: suite, rank: rank)
                
                if _cards.contains(where: { return $0.id == card.id }) { continue }
                
                _cards.append(card)
            }
        }
        
        return _cards
        
    }
    
    public func resize(_ value: CGSize) {
        self.size = value
    }
    
    public func resized(_ value: CGSize) -> CGSize {
        self.resize(value)
        
        return self.size
    }
}
