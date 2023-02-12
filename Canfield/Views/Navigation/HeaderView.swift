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
            
            
            
            Spacer()
            
            ForEach(self.$game.status) { status in
                StatusView(status: status)
            }
            
            Spacer()
            
            
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
        .background(GLOBALS.TABLE.COLOR)
    }
}
