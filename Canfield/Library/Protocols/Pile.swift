//
//  Pile.swift
//  Canfield
//
//  Created by David Geere on 2/21/23.
//

import Foundation

protocol Pile {
    
    var cards: [Card] { get set }
    
    var topCard: Card? { get }
    
    func add(card: Card)
    
    func removeTopCard() -> Card?
    
    func flipLastCardFaceUp()
    
    func canAdd(card: Card) -> Bool
}
