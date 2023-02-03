//
//  Placement.swift
//  Canfield
//
//  Created by David Geere on 2/2/23.
//

import Foundation

enum Placement: Equatable, Hashable {
    
    case none
    case ready
    case stock
    case waste
    case foundation( _ suite: Suite )
    case tableau( _ column: Column )
    
    var is_foundation: Bool {
        switch self {
        case .foundation(.clubs), .foundation(.hearts), .foundation(.spades), .foundation(.diamonds): return true
        default: return false
        }
    }
    
    var is_tableau: Bool {
        switch self {
        case .tableau(.one), .tableau(.two), .tableau(.three), .tableau(.four), .tableau(.five), .tableau(.six), .tableau(.seven): return true
        default: return false
        }
    }
    
}
