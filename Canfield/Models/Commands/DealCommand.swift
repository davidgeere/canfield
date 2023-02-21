//
//  DealCommand.swift
//  Canfield
//
//  Created by David Geere on 2/21/23.
//

import Foundation

// Command for dealing a card
class DealCommand: UndoableCommand {
    let game: Game
    
    init(game: Game) {
        self.game = game
    }
    
    func execute() {
        game.deal()
    }
    
    func undo() {
        game.undoDeal()
    }
}
