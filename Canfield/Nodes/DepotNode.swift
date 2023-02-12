//
//  DepotNode.swift
//  Canfield
//
//  Created by David Geere on 2/10/23.
//

import Foundation
import SpriteKit

class DepotNode : SKSpriteNode {
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    init(placement: Placement) {
        
        var imageName = ""
        
        switch placement {
        case .waste, .none, .ready:
            imageName = "depot/blank"
        case .stock:
            imageName = "depot/reload"
        case .tableau:
            imageName = "depot/open"
        case .foundation(let suite):
            imageName = "depot/\(suite.name)"
        }
        
        let texture = SKTexture(imageNamed: imageName)
        
        super.init(texture: texture, color: .clear, size: Deck.instance.size)
    }
}
