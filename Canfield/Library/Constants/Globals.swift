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
    typealias GlobalCard = (WIDTH: CGFloat, HEIGHT: CGFloat)
    
    public static let TABLE: GlobalTable = GlobalTable(NAME: "table", COLOR: Color("table"))
    public static let CARD: GlobalCard = GlobalCard(WIDTH: 130, HEIGHT: 182)
}
