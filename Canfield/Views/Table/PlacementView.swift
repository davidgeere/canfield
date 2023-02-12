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
                Image("depot/blank")
                    .resizable()
                    .scaledToFit()
            case .stock:
                Image("depot/reload")
                    .resizable()
                    .scaledToFit()
            case .tableau:
                Image("depot/open")
                    .resizable()
                    .scaledToFit()
            case .foundation(let suite):
                Image("depot/\(suite.name)")
                    .resizable()
                    .scaledToFit()
            }
        }
        .foregroundColor(.white.opacity(0.4))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
