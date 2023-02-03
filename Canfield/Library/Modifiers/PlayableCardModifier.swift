//
//  PlayableCardModifier.swift
//  Canfield
//
//  Created by David Geere on 2/2/23.
//

import Foundation
import SwiftUI

struct PlayableCardModifier : ViewModifier {
    
    @State private var position: CGSize = CGSize.zero
    @State private var location: CGPoint = CGPoint.zero
    
    private var tap: ((CardEventData) -> Void)? = nil
    private var drop: ((CardEventData) -> Void)? = nil
    private var drag: ((CardEventData) -> Void)? = nil

    @Binding public var card: Card

    init(_ card: Binding<Card>, onTap: ((CardEventData) -> Void)? = nil, onDrag: ((CardEventData) -> Void)? = nil, onDrop: ((CardEventData) -> Void)? = nil) {
        self._card = card
        
        self.tap = onTap
        self.drag = onDrag
        self.drop = onDrop
    }
    
    func body(content: Content) -> some View {
        content
            .offset(x: self.position.width, y: self.position.height)
            .simultaneousGesture(DragGesture(minimumDistance: 0, coordinateSpace: .named(Globals.TABLE.NAME))
                .onChanged { value in
                    guard card.available || card.face == .up else { return }
                    
                    withAnimation(.spring()) {
                        self.position = value.translation
                        self.location = value.location
                        
                        if let drag = self.drag {
                            drag(CardEventData(event: .drag, card: card, location: self.location))
                        }
                    }
                }
                .onEnded { value in
                    
                    guard card.available || card.face == .up else { return }
                    
                    withAnimation(.spring()) {
                        if let drop = self.drop {
                            drop(CardEventData(event: .drop, card: card, location: self.location))
                        }
                        
                        self.position = .zero
                        self.location = .zero
                    }
                })
            .highPriorityGesture(TapGesture().onEnded{
                if let tap = self.tap {
                    tap(CardEventData(event: .tap, card: card, location: .zero))
                }
            })
    }
}
