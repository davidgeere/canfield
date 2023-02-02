//
//  PlacementSender.swift
//  Canfield
//
//  Created by David Geere on 2/2/23.
//

import Foundation
import SwiftUI

struct PlacementSenderModifier: ViewModifier {
    
    @State private var bounds: CGRect = CGRect.zero
    
    private let placement: Placement
    
    init(_ placement: Placement) {
        self.placement = placement
    }
    
    func body(content: Content) -> some View {
        content
            .background(GeometryReader { geometry in
                Color.clear.preference(
                    key: PlacementPreferenceKey.self,
                    value: [PlacementData(self.placement, bounds: geometry.frame(in: .named(Globals.TABLE.NAME)))])
                .task {
                    self.bounds = geometry.frame(in: .named(Globals.TABLE.NAME))
                }
            })
    }
}
