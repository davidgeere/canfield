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
        VStack(alignment: .trailing, spacing: 0) {
            VStack(spacing: (self.game.card_size.width * (34/130))) {
                HStack(alignment: .top, spacing: (self.game.card_size.width * (36/130))) {
                    PlacementView(for: .stock)
                        .aspectRatio(Globals.CARD.RATIO, contentMode: .fit)
                        .frame(maxWidth: .infinity)
//                        .track(bounds: {
//                            self.game.table[.stock] = $0
//                        })
                        .onTapGesture {
                            self.game.restock()
                        }
                    
                    Color.clear
                        .aspectRatio(Globals.CARD.RATIO, contentMode: .fit)
                        .frame(maxWidth: .infinity)
//                        .track(bounds: { self.game.table[.waste] = $0 })
                    
                    Color.clear
                        .aspectRatio(Globals.CARD.RATIO, contentMode: .fit)
                        .frame(maxWidth: .infinity)
                        .track(bounds: { self.game.relayout($0) })
                    
                    ForEach(Suite.allCases) { suite in
                        PlacementView(for: .foundation(suite))
                            .aspectRatio(Globals.CARD.RATIO, contentMode: .fit)
                            .frame(maxWidth: .infinity)
//                            .track(bounds: { self.game.table[.foundation(suite)] = $0 })
                    }
                }
                
                HStack(spacing: 0) {
                    Spacer(minLength: 0)
                    HStack(alignment: .top, spacing: (self.game.card_size.width * (36/130))) {
                        ForEach(Column.allCases) { column in
                            PlacementView(for: .tableau(column))
                                .aspectRatio(Globals.CARD.RATIO, contentMode: .fit)
                                .frame(maxWidth: .infinity)
//                                .track(bounds: { self.game.table[.tableau(column)] = $0 })
                        }
                    }
                }
                Spacer()
            }
            .padding((self.game.card_size.width * (34/130)))
            .size(for: .full)
        }
        .size(for: .full)
        .background(Globals.TABLE.COLOR)
        .coordinateSpace(name: Globals.TABLE.NAME)
        .track(bounds: {
            
            self.game.table[.none] = $0
            self.game.table[.ready] = $0
            
            if self.game.state == .none {
                self.game.state = .ready
            }
        })
    }
}

struct TableLayoutView_Previews: PreviewProvider {
    static var previews: some View {
        TableView()
            .environmentObject(Game.preview)
    }
}
