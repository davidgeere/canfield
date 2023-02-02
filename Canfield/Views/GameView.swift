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
        ZStack(alignment: .top) {
            TableView()
                .environmentObject(self.game)
            
            ZStack {
                ForEach(self.$game.cards) { card in
                    CardView(card)
                        .environmentObject(self.game)
                }
            }
            .fullscreen()
        }
        .fullscreen()
    }
}

struct TableView_Previews: PreviewProvider {
    static var previews: some View {
        GameView()
            .environmentObject(Game.preview)
    }
}
