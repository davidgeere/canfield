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
                            .playable(card) { data in
                                
                                switch data.card.placement {
                                case .stock:
                                    self.game.waste(data)
                                default:
                                    self.game.place(data)
                                }
                            } onDrag: { data in
                                self.game.moving(data)
                                
                            } onDrop: { data in
                                
                                self.game.drop(data)
                            }
                    }
                }
                .size(for: .full)
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
