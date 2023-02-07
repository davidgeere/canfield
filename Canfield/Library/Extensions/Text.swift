//
//  Text.swift
//  Canfield
//
//  Created by David Geere on 2/6/23.
//

import Foundation
import SwiftUI

extension Text {
    public func font(size:CGFloat, _ weight: Font.Brand.Weight = .regular, _ style: Font.Brand.Style = .regular) -> Text {
        return self.font(Font.Brand.custom(size, weight, style))
    }
    
    public func font(_ named:Font.Brand.Named) -> Text {
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
