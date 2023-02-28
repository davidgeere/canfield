//
//  ScalableImage.swift
//  Canfield
//
//  Created by David Geere on 2/24/23.
//

import Foundation
import SwiftUI

struct VectorImage: View {
    var name: String
    
    public init(name: String) {
        self.init(name)
    }
    
    public init(_ name: String) {
        self.name = name
    }
    
    var body: some View {
        
        Image(self.name)
            .resizable()
            .scaledToFit()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        
    }
}
