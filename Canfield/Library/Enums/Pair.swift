//
//  Pair.swift
//  Canfield
//
//  Created by David Geere on 2/2/23.
//

import Foundation

enum Pair {
    case odd
    case even
    
    public func toggle() -> Pair {
        switch self {
        case .odd: return .even
        case .even: return .odd
        }
    }
}
