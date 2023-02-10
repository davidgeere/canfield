//
//  Constants.swift
//  Canfield
//
//  Created by David Geere on 2/2/23.
//

import Foundation
import SwiftUI

struct Globals {
    
    typealias GlobalTable = (NAME: String, COLOR: Color, WIDTH: CGFloat, HEIGHT: CGFloat, MARGIN: CGFloat, SPACING: CGFloat)
    typealias GlobalCard = (WIDTH: CGFloat, HEIGHT: CGFloat, RATIO: CGFloat)
    
//    typealias GlobalCard = (X: CGFloat, Y: CGFloat, /*WIDTH: CGFloat, HEIGHT: CGFloat*/, BOUNDS: CGRect, OFFSET: (UP: CGFloat, DOWN: CGFloat), MAX: (WIDTH: CGFloat, HEIGHT: CGFloat), MIN: (WIDTH: CGFloat, HEIGHT: CGFloat))
    
    public static let TABLE: GlobalTable = GlobalTable( NAME: "table",
                                                        COLOR: Color("table"),
                                                        WIDTH: 1194.0,
                                                        HEIGHT: 834.0,
                                                        MARGIN: 34.0,
                                                        SPACING: 36.0)
    
    public static let CARD: GlobalCard = GlobalCard( WIDTH: 130.0,
                                                     HEIGHT: 182.0,
                                                     RATIO: 750/1050)
    
//    public static let CARD: GlobalCard = GlobalCard( X: .zero,
//                                                     Y: .zero,
//                                                     WIDTH: CARD.MAX.WIDTH,
//                                                     HEIGHT: CARD.MAX.WIDTH,
//                                                     BOUNDS: CGRect(x: CARD.WIDTH * -1,
//                                                                    y: CARD.HEIGHT * -1,
//                                                                    width: CARD.WIDTH,
//                                                                    height: CARD.HEIGHT),
//                                                     OFFSET: ( UP: 40,
//                                                               DOWN: 20
//                                                             ),
//                                                     MAX: (WIDTH: 55, HEIGHT: 77),
//                                                     MIN: (WIDTH: 130, HEIGHT: 182))
}
