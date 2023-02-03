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
            HStack {
                Group {
//                    Text("Moves")
//                    Text("\(self.game.moves.count)")

                    switch self.game.state {
                    case .none, .ready, .setup:
                        Text("Start")
                            .onTapGesture {
                                withAnimation(.spring()) {
                                    self.game.deal()
                                }
                            }
                    case .dealt, .started, .paused, .ended:
                        Text("Restart")
                            .onTapGesture {
                                withAnimation(.spring()) {
                                    self.game.restart()
                                }
                            }
                    }
                    
                    
                }
                .foregroundColor(.white)
            }
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
