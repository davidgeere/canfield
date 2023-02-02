//
//  Face.swift
//  Canfield
//
//  Created by David Geere on 2/2/23.
//

import Foundation

enum Face {
    case up
    case down
    
    var name: String {
        switch self {
        case .up: return "up"
        case .down: return "down"
        }
    }
}
