//
//  CardViewModifier.swift
//  Canfield
//
//  Created by David Geere on 2/2/23.
//

import Foundation
import SwiftUI

struct ViewSizeModifier: ViewModifier {
    
    let size: ViewSize
    
    func body(content: Content) -> some View {
        switch size {
        case .card:
            content.frame(width: Globals.CARD.WIDTH, height: Globals.CARD.HEIGHT)
        case .full:
            content.frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
