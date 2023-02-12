//
//  PlayableCardModifier.swift
//  Canfield
//
//  Created by David Geere on 2/2/23.
//

import Foundation
import SwiftUI

struct PlayableCardModifier : ViewModifier {
    
    @State private var offset: CGSize
    @State private var location: CGRect
    
    private var tap: ((CardEventData) -> Void)? = nil
    private var drop: ((CardEventData) -> Void)? = nil
    private var drag: ((CardEventData) -> Void)? = nil
    private var reset: ((CardEventData) -> Void)? = nil

    @Binding public var card: Card

    init(_ card: Binding<Card>, onTap: ((CardEventData) -> Void)? = nil, onDrag: ((CardEventData) -> Void)? = nil, onDrop: ((CardEventData) -> Void)? = nil, onReset: ((CardEventData) -> Void)? = nil) {
        self._card = card
        
        self.offset = CGSize.zero
        self.location = CGRect.zero
        
        self.tap = onTap
        self.drag = onDrag
        self.drop = onDrop
        self.reset = onReset
        
        self.location = self.card.bounds
    }
    
    func body(content: Content) -> some View {
        content
            .simultaneousGesture(DragGesture(minimumDistance: 0, coordinateSpace: .named(GLOBALS.TABLE.NAME))
                .onChanged { value in
                    guard card.available || card.face == .up else { return }
                    
                    self.offset = value.translation
                      self.location = CGRect(x: (self.card.bounds.minX + self.offset.width), y: (self.card.bounds.minY + self.offset.height), width: self.card.bounds.width, height: self.card.bounds.height)
                    
                    if let drag = self.drag {
                        drag(CardEventData(event: .drag, card: card, location: self.location, offset: self.offset, moving: true))
                    }
                }
                .onEnded { value in
                    
                    if let drop = self.drop {
                        drop(CardEventData(event: .drop, card: card, location: self.location, offset: self.offset, moving: true))
                    }
                    
                    self.offset = .zero
                    self.location = self.card.bounds
                    
                    if let reset = self.reset {
                        reset(CardEventData(event: .reset, card: self.card, location: self.location, offset: self.offset, moving: false))
                    }
                })
            .highPriorityGesture(TapGesture().onEnded {
                if let tap = self.tap {
                    tap(CardEventData(event: .tap, card: self.card, location: self.card.bounds, offset: .zero, moving: true))
                }
                
                if let reset = self.reset {
                    reset(CardEventData(event: .reset, card: self.card, location: self.location, offset: self.offset, moving: false))
                }
            })
    }
}
