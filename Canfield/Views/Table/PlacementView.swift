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
        VStack {
            switch self.placement {
            case .stock, .waste, .none:
                EmptyView()
            case .tableau:
                Circle()
                    .background(RoundedRectangle(cornerRadius: .infinity).stroke(.white.opacity(0.4), lineWidth: 2))
                    .frame(width: 59, height: 59)
                    .foregroundColor(.clear)
            case .foundation(let suite):
                Image("suites/\(suite.name)")
                    .resizable()
                    .frame(width: 59, height: 59)
                    .foregroundColor(.white.opacity(0.4))
            }
        }
        .frame(width: Globals.CARD.WIDTH, height: Globals.CARD.HEIGHT)
        .background(.white.opacity(0.2))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .background(RoundedRectangle(cornerRadius: 10).stroke(.white.opacity(0.4), lineWidth: 2))
        .track(bounds: { data in
            self.game.table[self.placement] = data
        })
    }
}

struct TableSpaceView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            PlacementView(for: .stock)
        }
        .fullscreen()
        .background(Globals.TABLE.COLOR)
    }
}
