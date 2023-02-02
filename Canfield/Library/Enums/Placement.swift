//
//  Placement.swift
//  Canfield
//
//  Created by David Geere on 2/2/23.
//

import Foundation

enum Placement: Equatable, Hashable {
    
    case none
    case stock
    case waste
    case foundation( _ suite: Suite )
    case tableau( _ column: Column )
    
}
