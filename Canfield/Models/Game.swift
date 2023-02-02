//
//  Game.swift
//  Canfield
//
//  Created by David Geere on 2/2/23.
//

import Foundation

class Game: ObservableObject {
    
    public static let preview:Game = Game()
    
    @Published public var cards:[Card]
    
    public var table: Table
    
    init() {
        
        self.table = Table()
        self.cards = Deck.draw
        
    }
}
