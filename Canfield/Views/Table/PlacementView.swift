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
        HStack {
            Spacer()
            Group {
                switch self.placement {
                case .waste, .none, .ready:
                    Image("icons/large/empty")
                        .resizable()
                        .scaledToFit()
                case .stock:
                    Image("icons/large/refresh")
                        .resizable()
                        .scaledToFit()
                case .tableau:
                    Image("icons/large/open")
                        .resizable()
                        .scaledToFit()
                case .foundation(let suite):
                    Image("icons/large/\(suite.name)")
                        .resizable()
                        .scaledToFit()
                }
            }
            .frame(maxWidth: .infinity)
            .foregroundColor(.white.opacity(0.4))
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.white.opacity(0.2))
        .background(RoundedRectangle(cornerRadius: (self.game.card_size.width * (10 / 130) )  ).stroke(.white.opacity(0.4), lineWidth: 4))
        .clipShape(RoundedRectangle(cornerRadius: (self.game.card_size.width * (10 / 130) )  ))
        .track(bounds: {
            self.game.table[self.placement] = $0
        })
        
    }
}

struct TableSpaceView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            PlacementView(for: .stock)
                .environmentObject(Game.preview)
        }
        .size(for: .full)
        .background(Globals.TABLE.COLOR)
    }
}
