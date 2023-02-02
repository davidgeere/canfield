//
//  PlacementPreferenceKey.swift
//  Canfield
//
//  Created by David Geere on 2/2/23.
//

import Foundation
import SwiftUI

struct PlacementPreferenceKey: PreferenceKey {
    
    typealias Value = [PlacementData]
    
    static var defaultValue: Value = []
    
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value.append(contentsOf: nextValue())
    }
    
}
