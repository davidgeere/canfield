//
//  GameStatus.swift
//  Canfield
//
//  Created by David Geere on 2/7/23.
//

import Foundation

enum GameStatus: String {
    
    case moves = "moves"
    case score = "score"
    case time = "time"
    
    var value: String {
        return self.rawValue
    }
}
