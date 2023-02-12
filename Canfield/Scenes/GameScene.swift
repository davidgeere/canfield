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
    
    let card = CardNode(card: Deck.instance.cards.last!)
    
    override func didMove(to view: SKView) {
        
        for placement in Placement.allCases {
            let depot = DepotNode(placement: placement)
            
            let midX = Table.instance[placement].midX
            let midY = Table.instance[placement].midY
            
            depot.position = CGPoint(x: midX, y: size.height - midY)
            
            addChild(depot)
        }
        
        card.position = CGPoint(x: (card.size.width / 2), y: size.height - (card.size.height / 2) )
        
        addChild(card)
        
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let box = SKSpriteNode(color: .red, size: CGSize(width: 50, height: 50))
        box.position = location
        box.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 50, height: 50))
        addChild(box)
    }
    
        
}
