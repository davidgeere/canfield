//
//  TableSpaceView.swift
//  Canfield
//
//  Created by David Geere on 2/2/23.
//

import SwiftUI

struct PlacementView: View {
    
    @EnvironmentObject private var game: Game
    
    private let placement: Placement
    
    init(for placement: Placement) {
        
        self.placement = placement
    }
    
    var body: some View {
        Group {
            switch self.placement {
            case .waste, .none, .ready:
                VectorImage("depot/blank")
            case .stock:
                VectorImage("depot/reload")
            case .tableau:
                VectorImage("depot/open")
            case .foundation(let suite):
                VectorImage("depot/\(suite.name)")
            }
        }
        .foregroundColor(.white.opacity(0.4))
    }
}

struct TableSpaceView_Previews: PreviewProvider {
    static var previews: some View {
        HStack (spacing: 16) {
            PlacementView(for: .stock)
                .environmentObject(Game.preview)
            PlacementView(for: .foundation(.clubs))
                .environmentObject(Game.preview)

        }
        .padding()
        .size(for: .full)
        .background(GLOBALS.TABLE.COLOR)
    }
}
