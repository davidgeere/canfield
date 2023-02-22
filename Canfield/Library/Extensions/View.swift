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
    
    func bounds(_ changed: @escaping (CGRect) -> Void) -> some View {
        background( GeometryReader { Color.clear.preference(key: BoundsPreferenceKey.self, value: $0.frame(in: .named(GLOBALS.TABLE.NAME)) ) } )
            .onPreferenceChange(BoundsPreferenceKey.self) { bounds in
                main {
                    changed(bounds)
                }
            }
    }
    
    func size(_ change: @escaping (CGSize) -> Void) -> some View {
        background( GeometryReader { Color.clear.preference(key: SizePreferenceKey.self, value: $0.size) } )
            .onPreferenceChange(SizePreferenceKey.self, perform: change)
    }
    
    func size(for size: ViewSize) -> some View {
        modifier(ViewSizeModifier(layout: size))
    }
    
    func hide(_ hide: Bool = true, remove: Bool = true) -> some View {
        modifier( VisibilityModifier( hide: hide, remove: remove ) )
    }
    
    func playable(_ card: Binding<Card>, onTap: ((CardEventData) -> Void)? = nil, onDrag: ((CardEventData) -> Void)? = nil, onDrop: ((CardEventData) -> Void)? = nil, onReset: ((CardEventData) -> Void)? = nil) -> some View {
        modifier(PlayableCardModifier(card, onTap: onTap, onDrag: onDrag, onDrop: onDrop, onReset: onReset))
    }
    
    /// Calls the completion handler whenever an animation on the given value completes.
    /// - Parameters:
    ///   - value: The value to observe for animations.
    ///   - completion: The completion callback to call once the animation completes.
    /// - Returns: A modified `View` instance with the observer attached.
    func onAnimationCompleted<Value: VectorArithmetic>(for value: Value, completion: @escaping () -> Void) -> ModifiedContent<Self, AnimationCompletionObserverModifier<Value>> {
        return modifier(AnimationCompletionObserverModifier(observedValue: value, completion: completion))
    }
    
    public func font(size:CGFloat, _ weight: Font.Brand.Weight = .regular, _ style: Font.Brand.Style = .regular) -> some View {
        return self.font(Font.Brand.custom(size, weight, style))
    }
    
    public func font(_ named:Font.Brand.Named) -> some View {
        switch(named){
        case let .largeTitle(weight, style):
            return self.font(Font.Brand.largeTitle(weight, style: style))
        case let .title(weight, style):
            return self.font(Font.Brand.title(weight, style: style))
        case let .title2(weight, style):
            return self.font(Font.Brand.title2(weight, style: style))
        case let .title3(weight, style):
            return self.font(Font.Brand.title3(weight, style: style))
        case let .headline(weight, style):
            return self.font(Font.Brand.headline(weight, style: style))
        case let .body(weight, style):
            return self.font(Font.Brand.body(weight, style: style))
        case let .callout(weight, style):
            return self.font(Font.Brand.callout(weight, style: style))
        case let .subheadline(weight, style):
            return self.font(Font.Brand.subheadline(weight, style: style))
        case let .footnote(weight, style):
            return self.font(Font.Brand.footnote(weight, style: style))
        case let .caption(weight, style):
            return self.font(Font.Brand.caption(weight, style: style))
        case let .caption2(weight, style):
            return self.font(Font.Brand.caption2(weight, style: style))
        }
    }
}
