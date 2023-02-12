//
//  CardNode.swift
//  Canfield
//
//  Created by David Geere on 2/10/23.
//

import Foundation
import SpriteKit

class CardNode : SKSpriteNode {
    let frontTexture :SKTexture
    let backTexture :SKTexture
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    init(card: Card) {
        
        var front = UIImage(named: "decks/chunky/\(card.suite.name)/\(card.rank.name)")!
        var back = UIImage(named: "decks/chunky/back")!
    
//            .frame(width: card.bounds.width, height: card.bounds.height)
        
        backTexture = SKTexture(image: back)
        frontTexture = SKTexture(image: front)
        
        
        
        super.init(texture: frontTexture, color: .clear, size: card.bounds.size)
    }
}
