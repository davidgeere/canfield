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
            VStack(spacing: ( Deck.instance.size.width * ( GLOBALS.TABLE.MARGIN / GLOBALS.CARD.WIDTH ))) {
                HStack(alignment: .top, spacing: ( Deck.instance.size.width * ( GLOBALS.TABLE.SPACING / GLOBALS.CARD.WIDTH ))) {
                    PlacementView(for: .stock)
                        .aspectRatio(GLOBALS.CARD.RATIO, contentMode: .fit)
                        .frame(maxWidth: .infinity)
                        .track(bounds: { Table.instance[.stock] = $0 })
                        .onTapGesture {
                            self.game.restock()
                        }
                    
                    Color.clear
                        .aspectRatio(GLOBALS.CARD.RATIO, contentMode: .fit)
                        .frame(maxWidth: .infinity)
                        .track(bounds: { Table.instance[.waste] = $0 })
                    
                    Color.clear
                        .aspectRatio(GLOBALS.CARD.RATIO, contentMode: .fit)
                        .frame(maxWidth: .infinity)
                        .track(bounds: { self.game.relayout($0) })
                    
                    ForEach(Suit.allCases) { suite in
                        PlacementView(for: .foundation(suite))
                            .aspectRatio(GLOBALS.CARD.RATIO, contentMode: .fit)
                            .frame(maxWidth: .infinity)
                            .track(bounds: { Table.instance[.foundation(suite)] = $0 })
                    }
                }
                
                HStack(spacing: 0) {
                    Spacer(minLength: 0)
                    HStack(alignment: .top, spacing: ( Deck.instance.size.width * ( GLOBALS.TABLE.SPACING / GLOBALS.CARD.WIDTH )) ) {
                        ForEach(Column.allCases) { column in
                            PlacementView(for: .tableau(column))
                                .aspectRatio(GLOBALS.CARD.RATIO, contentMode: .fit)
                                .frame(maxWidth: .infinity)
                                .track(bounds: { Table.instance[.tableau(column)] = $0 })
                        }
                    }
                }
                Spacer()
            }
            .padding((Deck.instance.size.width * ( GLOBALS.TABLE.MARGIN / GLOBALS.CARD.WIDTH )))
            .size(for: .full)
        }
        .size(for: .full)
        .background(GLOBALS.TABLE.COLOR)
        .coordinateSpace(name: GLOBALS.TABLE.NAME)
        .track(bounds: {
            
            Table.instance[.none] = $0
            Table.instance[.ready] = $0
            
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
