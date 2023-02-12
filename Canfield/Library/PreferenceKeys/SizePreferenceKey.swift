//
//  SizePreferenceKey.swift
//  Canfield
//
//  Created by David Geere on 2/10/23.
//

import Foundation
import SwiftUI

struct SizePreferenceKey: PreferenceKey {
    
    typealias Value = CGSize
    
    static var defaultValue: Self.Value = .zero
    
    static func reduce(value: inout Self.Value, nextValue: () -> Self.Value) { }

}
