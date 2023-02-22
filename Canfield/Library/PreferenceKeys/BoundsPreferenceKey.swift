//
//  BoundsPreferenceKey.swift
//  Canfield
//
//  Created by David Geere on 2/22/23.
//

import Foundation
import SwiftUI

struct BoundsPreferenceKey: PreferenceKey {
    
    typealias Value = CGRect
    
    static var defaultValue: Self.Value = .zero
    
    static func reduce(value: inout Self.Value, nextValue: () -> Self.Value) { }
    
}
