//
//  Suite.swift
//  Canfield
//
//  Created by David Geere on 2/2/23.
//

import Foundation

enum Suite: Int, CaseIterable, Identifiable, Codable {
    
    case diamonds = 1
    case spades = 2
    case hearts = 3
    case clubs = 4
    
    var id: Int {
        return rawValue
    }
    
    var value: Int {
        return rawValue
    }
    
    var name: String {
        switch self {
        case .clubs: return "clubs"
        case .hearts: return "hearts"
        case .diamonds: return "diamonds"
        case .spades: return "spades"
        }
    }
    
    var symbol: String {
        switch self {
        case .clubs: return "♣"
        case .hearts: return "♥"
        case .diamonds: return "♦"
        case .spades: return "♠"
        }
    }

    var order: Int {
        return self.rawValue * 100
    }
    
    var pair: Pair {
        switch self {
        case .diamonds, .hearts:
            return .odd
        case .spades, .clubs:
            return .even
        }
    }
}
