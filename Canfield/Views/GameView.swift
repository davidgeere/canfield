//
//  TableView.swift
//  Canfield
//
//  Created by David Geere on 1/26/23.
//

import SwiftUI

struct GameView: View {
    
    @EnvironmentObject private var game: Game
    
    var body: some View {
        VStack {
            HeaderView()
            ZStack(alignment: .top) {
                TableView()
                    .environmentObject(self.game)
                
                ZStack {
                    ForEach(self.$game.cards) { card in
                        CardView(card)
                            .playable(
                                card,
                                onTap: {
                                    switch $0.card.placement {
                                    case .stock: self.game.waste($0)
                                    case .waste: self.game.place($0)
                                    case .foundation: return
                                    case .tableau: self.game.place($0)
                                    default: return
                                    }
                                },
                                onDrag: {
                                    self.game.drag($0)
                                    self.game.dragger = $0.location
                                },
                                onDrop: {
                                    self.game.drop($0)
                                },
                                onReset: {
                                    self.game.regroup($0)
                                    self.game.dragger = $0.location
                                })
                    }
                }
                .size(for: .full)
                
//                LayoutDebugView()
//                    .environmentObject(self.game)
                
//                VStack( alignment: .leading) {
//                    DebugRowView("X", values: [self.game.dragger.minX.round(precision: 0), self.game.dragger.midX.round(precision: 0), self.game.dragger.maxX.round(precision: 0)] )
//                    DebugRowView("Y", values: [self.game.dragger.minY.round(precision: 0), self.game.dragger.midY.round(precision: 0), self.game.dragger.maxY.round(precision: 0)] )
//                    Spacer()
//                }
//                .frame(width: self.game.dragger.width, height: self.game.dragger.height)
//                .background(.clear)
//                .border(.red, width: 2)
//                .position(x: self.game.dragger.midX, y: self.game.dragger.midY)
            }
            .size(for: .full)
        }
        .size(for: .full)
        .background(Globals.TABLE.COLOR)
    }
}

struct TableView_Previews: PreviewProvider {
    static var previews: some View {
        GameView()
            .environmentObject(Game.preview)
    }
}
