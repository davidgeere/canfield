//
//  TrackBoundsModifier.swift
//  Canfield
//
//  Created by David Geere on 2/2/23.
//

import Foundation
import SwiftUI

struct TrackBoundsModifier: ViewModifier {
    
    private var receive: (CGRect) -> Void
    
    init(receive: @escaping (CGRect) -> Void ) {
        self.receive = receive
    }
    
    func body(content: Content) -> some View {
        content
            .background(GeometryReader { geometry in
                Color.clear.preference(
                    key: TrackBoundsPreferenceKey.self,
                    value: geometry.frame(in: .named(GLOBALS.TABLE.NAME)))
            })
            .onPreferenceChange(TrackBoundsPreferenceKey.self){ value in
                DispatchQueue.main.async {
                    self.receive(value)
                }
            }
    }
}
