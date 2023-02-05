//
//  View.swift
//  Canfield
//
//  Created by David Geere on 2/2/23.
//

import Foundation
import SwiftUI

extension View {
    
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
    
    func track(bounds: @escaping (CGRect) -> Void) -> some View {
        modifier(TrackBoundsModifier(receive: bounds))
    }
    
    func size(for size: ViewSize) -> some View {
        modifier(ViewSizeModifier(size: size))
    }
    
    func playable(_ card: Binding<Card>, onTap: ((CardEventData) -> Void)? = nil, onDrag: ((CardEventData) -> Void)? = nil, onDrop: ((CardEventData) -> Void)? = nil, onReset: ((CardEventData) -> Void)? = nil) -> some View {
        modifier(PlayableCardModifier(card, onTap: onTap, onDrag: onDrag, onDrop: onDrop, onReset: onReset))
    }
}
