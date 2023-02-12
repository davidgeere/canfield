//
//  Constants.swift
//  Canfield
//
//  Created by David Geere on 2/2/23.
//

import Foundation
import SwiftUI

struct GLOBALS {
    struct TABLE {
        static let NAME: String     = "table"
        static let COLOR: Color     = Color("table")
        static let SIZE: CGSize     = CGSize(width: WIDTH, height: HEIGHT)
        static let WIDTH: CGFloat   = 1194.0
        static let HEIGHT: CGFloat  = 834.0
        static let MARGIN: CGFloat  = 34.0
        static let SPACING: CGFloat = 36.0
        
        private init() {}
    }
    
    struct CARD {
        static let WIDTH: CGFloat   = 130.0
        static let HEIGHT: CGFloat  = 182.0
        static let SIZE: CGSize  = CGSize(width: WIDTH, height: HEIGHT)
        static let RATIO: CGFloat   = WIDTH / HEIGHT
        static let STAGGER: CGFloat = 50.0 / HEIGHT
        
        private init() {}
    }
    
    private init() {}
}
