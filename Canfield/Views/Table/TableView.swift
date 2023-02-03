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
                    PlacementView(for: .stock).track(bounds: { self.game.table[.stock] = $0 })
                    
                    Color.clear.size(for: .card).track(bounds: { self.game.table[.waste] = $0 })
                    
                    Spacer()
                    ForEach(Suite.allCases) { suite in
                        PlacementView(for: .foundation(suite))
                            .track(bounds: { self.game.table[.foundation(suite)] = $0 })
                    }
                }
                
                HStack {
                    Spacer()
                    HStack(alignment: .top, spacing: 24) {
                        ForEach(Column.allCases) { column in
                            PlacementView(for: .tableau(column)).track(bounds: { self.game.table[.tableau(column)] = $0 })
                        }
                    }
                }
                Spacer()
            }
            .padding(32)
            .size(for: .full)
        }
        .size(for: .full)
        .background(Globals.TABLE.COLOR)
        .coordinateSpace(name: Globals.TABLE.NAME)
        .track(bounds: {
            self.game.table.bounds = $0
            self.game.state = .ready
        })
    }
}

struct TableLayoutView_Previews: PreviewProvider {
    static var previews: some View {
        TableView()
            .environmentObject(Game.preview)
    }
}
