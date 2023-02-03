//
//  Constants.swift
//  Canfield
//
//  Created by David Geere on 2/2/23.
//

import Foundation
import SwiftUI

struct Globals {
    
    typealias GlobalTable = (NAME: String, COLOR: Color)
    typealias GlobalCard = (X: CGFloat, Y: CGFloat, WIDTH: CGFloat, HEIGHT: CGFloat, BOUNDS: CGRect)
    
    public static let TABLE: GlobalTable = GlobalTable(NAME: "table", COLOR: Color("table"))
    public static let CARD: GlobalCard = GlobalCard(X: .zero, Y: .zero,WIDTH: 130, HEIGHT: 182, BOUNDS: CGRect(x: CARD.WIDTH * -1, y: CARD.HEIGHT * -1, width: CARD.WIDTH, height: CARD.HEIGHT))
}
