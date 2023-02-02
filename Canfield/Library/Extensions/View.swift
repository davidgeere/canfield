//
//  View.swift
//  Canfield
//
//  Created by David Geere on 2/2/23.
//

import Foundation
import SwiftUI

extension View {
    func placement(receive: @escaping ([PlacementData]) -> Void) -> some View {
        modifier(PlacementReceiverModifier(receive: receive))
    }
    
    func placement(for placement: Placement) -> some View {
        modifier(PlacementSenderModifier(placement))
    }
    
    func track(bounds: @escaping (CGRect) -> Void) -> some View {
        modifier(TrackBoundsModifier(receive: bounds))
    }
    
    func fullscreen() -> some View {
        modifier(FullScreenModifier())
    }
    
    func playable(_ card: Card, onTap: ((CardEventData) -> Void)? = nil, onDrag: ((CardEventData) -> Void)? = nil, onDrop: ((CardEventData) -> Void)? = nil) -> some View {
        modifier(PlayableCardModifier(card, onTap: onTap, onDrag: onDrag, onDrop: onDrop))
    }
}
