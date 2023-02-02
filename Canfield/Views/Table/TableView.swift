//
//  TableLayoutView.swift
//  Canfield
//
//  Created by David Geere on 2/2/23.
//

import SwiftUI

struct TableView: View {
    
    @EnvironmentObject private var game: Game
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 32) {
                HStack(alignment: .top, spacing: 24) {
                    PlacementView(for: .stock) // Stock
                        .environmentObject(self.game)
                    
                    PlacementView(for: .waste) // Waste
                        .environmentObject(self.game)
                    
                    Spacer()
                    ForEach(Suite.allCases) { suite in // Foundation
                        PlacementView(for: .foundation(suite))
                            .environmentObject(self.game)
                    }
                }
                
                HStack {
                    Spacer()
                    HStack(alignment: .top, spacing: 24) { // Tableau
                        ForEach(Column.allCases) { column in
                            PlacementView(for: .tableau(column))
                                .environmentObject(self.game)
                        }
                    }
                }
                Spacer()
            }
            .padding(32)
            .fullscreen()
        }
        .fullscreen()
        .background(Globals.TABLE.COLOR)
        .coordinateSpace(name: Globals.TABLE.NAME)
        .track(bounds: { data in
            self.game.table.bounds = data
        })
    }
}

struct TableLayoutView_Previews: PreviewProvider {
    static var previews: some View {
        TableView()
            .environmentObject(Game.preview)
    }
}
