//
//  GameScene.swift
//  Canfield
//
//  Created by David Geere on 2/10/23.
//

import Foundation
import Combine
import SwiftUI
import SpriteKit

class GameScene: SKScene, ObservableObject {
    
    override init(size: CGSize) {
        super.init(size: size)
        
        self.backgroundColor = UIColor(GLOBALS.TABLE.COLOR)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }
    
    override func didMove(to view: SKView) {

        for placement in Placement.allCases {
            let depot = DepotNode(placement: placement)
            
            let midX = Table.instance[placement].midX
            let midY = Table.instance[placement].midY
            
            depot.position = CGPoint(x: midX, y: size.height - midY)
            
            addChild(depot)
        }
        
        for card in Game.instance.cards {
            
            let card_node = CardNode(card: card)
            
            let midX = card.bounds.midX
            let midY = card.bounds.midY
            
            card_node.position = CGPoint(x: midX, y: size.height - midY)
            
            addChild(card_node)
            
//            let card = CardNode(card: Deck.instance.cards.last!)
//
//            card.position = CGPoint(x: (card.size.width / 2), y: size.height - (card.size.height / 2) )
        }

        
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
      for touch in touches {
        let location = touch.location(in: self)           // 1
        if let card = atPoint(location) as? CardNode {        // 2
          card.position = location
        }
      }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
}
