//
//  CardViewModifier.swift
//  Canfield
//
//  Created by David Geere on 2/2/23.
//

import Foundation
import SwiftUI

struct ViewSizeModifier: ViewModifier {
    
    let layout: ViewSize
    @State private var origin: CGSize
    
    private var size: CGSize
    
    init(layout: ViewSize) {
        self.size = CGSize(width: 750, height: 1050)
        self.layout = layout
        self.origin = CGSize(width: size.width, height: size.width / size.ratio)
    }
    
    func body(content: Content) -> some View {
        switch self.layout {
        case .card:
            content
                .aspectRatio(self.size, contentMode: .fit)
                .frame(maxWidth: .infinity)
        case .full:
            content.frame(maxWidth: .infinity, maxHeight: .infinity)
        case .vertical:
            content.frame(maxHeight: .infinity)
        case .horizontal:
            content.frame(maxWidth: .infinity)
        }
    }
}
