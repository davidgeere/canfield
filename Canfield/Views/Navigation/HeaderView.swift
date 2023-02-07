//
//  HeaderView.swift
//  Canfield
//
//  Created by David Geere on 2/2/23.
//

import SwiftUI

struct HeaderView: View {
    
    @EnvironmentObject private var game: Game
    
    var body: some View {
        HStack {
            
            ActionView(name: "settings")
            
            Spacer()
            
            StatusView(name: "time", value: .constant(0))
            StatusView(name: "moves", value: self.$game.moves)
            StatusView(name: "score", value: .constant(0))
            
            Spacer()
            
            ActionView(name: "leaderboard")
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.black.opacity(0.2).blendMode(.multiply))
    }
}

struct HeaderView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            HeaderView()
                .environmentObject(Game.preview)
        }
        .size(for: .full)
        .background(Globals.TABLE.COLOR)
    }
}
