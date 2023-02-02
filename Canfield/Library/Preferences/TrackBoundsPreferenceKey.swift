//
//  TrackBoundsPreferenceKey.swift
//  Canfield
//
//  Created by David Geere on 2/2/23.
//

import Foundation
import SwiftUI

struct TrackBoundsPreferenceKey: PreferenceKey {
    
    typealias Value = CGRect
    
    static var defaultValue: Self.Value = .zero
    
    static func reduce(value: inout Self.Value, nextValue: () -> Self.Value) { }
    
}
