//
//  MoveCommand.swift
//  Canfield
//
//  Created by David Geere on 2/21/23.
//

import Foundation

// Command for moving a card
class MoveCommand: UndoableCommand {
    let game: Game
    let card: Card
    let fromPile: Pile
    let toPile: Pile
    
    init(game: Game, card: Card, fromPile: Pile, toPile: Pile) {
        self.game = game
        self.card = card
        self.fromPile = fromPile
        self.toPile = toPile
    }
    
    func execute() {
        game.move(card: card, from: fromPile, to: toPile, recordCommand: false)
    }
    
    func undo() {
        game.move(card: card, from: toPile, to: fromPile, recordCommand: false)
    }
}
