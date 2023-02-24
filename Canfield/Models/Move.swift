//
//  Move.swift
//  Canfield
//
//  Created by David Geere on 2/7/23.
//

import Foundation

struct MoveState<T> {
    let from: T
    let to: T
}


struct Move: Command {
    
    func execute() {
        
    }
    
    func undo() {
        
    }
    
    func redo() {
        
    }
    
    
    let id: Int
    let card: Card
    let placement: MoveState<Placement>
    let parent: MoveState<Card?>
    let revealed: MoveState<Bool>
    let at: Date
    
    init(id: Int, card: Card, placement: MoveState<Placement>, revealed: MoveState<Bool>, parent: MoveState<Card?>) {
        self.id = id
        self.card = card
        self.placement = placement
        self.parent = parent
        self.revealed = revealed
        self.at = Date()
    }
    
    #if DEBUG
    func debug() {
        
//        let placement_from_debug = placement.from.name
//        let placement_to_debug = placement.to.name
//        
//        var parent_from_debug = "none"
//        var parent_to_debug = "none"
//        
//        if let pf = parent.from { parent_from_debug = pf.symbol }
//        if let pf = parent.to { parent_to_debug = pf.symbol }
//        
//        let revealed_from_debug = revealed.from ? "true" : "false"
//        let revealed_to_debug = revealed.to ? "true" : "false"
//        
//        print("id:", id, "card:", card.symbol,
//              "placement:", "from:", placement_from_debug, "to:", placement_to_debug,
//              "parent:", "from:", parent_from_debug, "to:", parent_to_debug,
//              "revealed:", "from:", revealed_from_debug, "to:", revealed_to_debug)
    }
    #endif
}
