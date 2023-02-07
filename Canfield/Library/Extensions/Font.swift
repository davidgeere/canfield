//
//  Font.swift
//  Canfield
//
//  Created by David Geere on 2/6/23.
//

import Foundation
import SwiftUI

extension Font {
    public struct Brand {
        
        public enum Weight {
            case ultraLight
            case thin
            case light
            case regular
            case medium
            case semiBold
            case bold
            case extraBold
            case heavy
            case black
        }
        
        public enum Style {
            case italic
            case regular
        }
        
        public enum Named {
            case largeTitle(_ weight: Brand.Weight = .regular, style: Brand.Style = .regular)
            case title(_ weight: Brand.Weight = .regular, style: Brand.Style = .regular)
            case title2(_ weight: Brand.Weight = .regular, style: Brand.Style = .regular)
            case title3(_ weight: Brand.Weight = .regular, style: Brand.Style = .regular)
            case headline(_ weight: Brand.Weight = .semiBold, style: Brand.Style = .regular)
            case body(_ weight: Brand.Weight = .regular, style: Brand.Style = .regular)
            case callout(_ weight: Brand.Weight = .regular, style: Brand.Style = .regular)
            case subheadline(_ weight: Brand.Weight = .regular, style: Brand.Style = .regular)
            case footnote(_ weight: Brand.Weight = .regular, style: Brand.Style = .regular)
            case caption(_ weight: Brand.Weight = .regular, style: Brand.Style = .regular)
            case caption2(_ weight: Brand.Weight = .regular, style: Brand.Style = .regular)
        }
        
        public static func name(weight: Brand.Weight = .regular, style: Brand.Style = .regular) -> String {
            var name: String = "Gilroy"
            
            switch(weight) {
            case .ultraLight :
                name += "-UltraLight"
            case .thin :
                name += "-Thin"
            case .light :
                name += "-Light"
            case .regular :
                name += "-Regular"
            case .medium :
                name += "-Medium"
            case .semiBold :
                name += "-SemiBold"
            case .bold :
                name += "-Bold"
            case .extraBold :
                name += "-ExtraBold"
            case .heavy :
                name += "-Heavy"
            case .black :
                name += "-Black"
            }
            
            if style == .italic {
                name += "Italic"
            }
            
            return name
        }
        
        public static func custom(_ size:CGFloat, _ weight: Brand.Weight = .regular, _ style: Brand.Style = .regular) -> Font {
            return .custom(name(weight: weight, style: style), size: size)
        }
        
        public static func largeTitle(_ weight: Brand.Weight = .regular, style: Brand.Style = .regular) -> Font {
            return .custom(name(weight: weight, style: style), size: 34, relativeTo: .largeTitle)
        }
        
        public static func title(_ weight: Brand.Weight = .regular, style: Brand.Style = .regular) -> Font {
            return .custom(name(weight: weight, style: style), size: 28, relativeTo: .title)
        }
        
        public static func title2(_ weight: Brand.Weight = .regular, style: Brand.Style = .regular) -> Font {
            return .custom(name(weight: weight, style: style), size: 22, relativeTo: .title2)
        }
        
        public static func title3(_ weight: Brand.Weight = .regular, style: Brand.Style = .regular) -> Font {
            return .custom(name(weight: weight, style: style), size: 20, relativeTo: .title3)
        }
        
        public static func headline(_ weight: Brand.Weight = .semiBold, style: Brand.Style = .regular) -> Font {
            return .custom(name(weight: weight, style: style), size: 17, relativeTo: .headline)
        }
        
        public static func body(_ weight: Brand.Weight = .regular, style: Brand.Style = .regular) -> Font {
            return .custom(name(weight: weight, style: style), size: 17, relativeTo: .body)
        }
        
        public static func callout(_ weight: Brand.Weight = .regular, style: Brand.Style = .regular) -> Font {
            return .custom(name(weight: weight, style: style), size: 16, relativeTo: .callout)
        }
        
        public static func subheadline(_ weight: Brand.Weight = .regular, style: Brand.Style = .regular) -> Font {
            return .custom(name(weight: weight, style: style), size: 15, relativeTo: .subheadline)
        }
        
        public static func footnote(_ weight: Brand.Weight = .regular, style: Brand.Style = .regular) -> Font {
            return .custom(name(weight: weight, style: style), size: 13, relativeTo: .footnote)
        }
        
        public static func caption(_ weight: Brand.Weight = .regular, style: Brand.Style = .regular) -> Font {
            return .custom(name(weight: weight, style: style), size: 12, relativeTo: .caption)
        }
        
        public static func caption2(_ weight: Brand.Weight = .regular, style: Brand.Style = .regular) -> Font {
            return .custom(name(weight: weight, style: style), size: 11, relativeTo: .caption2)
        }
    }
}
