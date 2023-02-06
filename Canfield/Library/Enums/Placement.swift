//
//  Placement.swift
//  Canfield
//
//  Created by David Geere on 2/2/23.
//

import Foundation

enum Placement: Equatable, Hashable, CaseIterable, Identifiable {
    
    case none
    case ready
    case stock
    case waste
    case foundation( _ suite: Suite )
    case tableau( _ column: Column )
    
    static var allTableaus: [Placement] {
        return [.tableau(.one), .tableau(.two), .tableau(.three), .tableau(.four), .tableau(.five), .tableau(.six), .tableau(.seven)]
    }
    
    static var allFoundations: [Placement] {
        return [.foundation(.hearts), .foundation(.spades), .foundation(.diamonds), .foundation(.clubs)]
    }
    
    static var allPlayable: [Placement] {
        return allFoundations + allTableaus
    }
    
    static var allCases: [Placement] {
        return [.stock, .waste] + allPlayable
    }
    
    var playable: Bool {
        switch self {
        case .foundation, .tableau : return true
        default: return false
        }
    }
    
    var suite: Suite? {
        switch self {
        case .foundation(let suite) : return suite
        default: return nil
        }
    }
    
    var column: Column? {
        switch self {
        case .tableau(let column) : return column
        default: return nil
        }
    }

    var order: Int {
        switch self {
        case .none: return 0
        case .ready: return 1000
        case .stock: return 2000
        case .waste: return 3000
        case .foundation(let suite): return 4000 + suite.order
        case .tableau(let column): return 5000 + column.order
        }
    }
    
//    var is_foundation: Bool {
//        switch self {
//        case .foundation(.clubs), .foundation(.hearts), .foundation(.spades), .foundation(.diamonds): return true
//        default: return false
//        }
//    }
//    
//    var is_tableau: Bool {
//        switch self {
//        case .tableau(.one), .tableau(.two), .tableau(.three), .tableau(.four), .tableau(.five), .tableau(.six), .tableau(.seven): return true
//        default: return false
//        }
//    }
    
    var id: String {
        return self.name
    }
    
    var name: String {
        switch self {
        case .none: return "none"
        case .ready: return "ready"
        case .stock: return "stock"
        case .waste: return "waste"
        case .foundation(let suite): return "foundation " + suite.symbol
        case .tableau(let column): return "tableau " + column.name
        }
    }
    
}
