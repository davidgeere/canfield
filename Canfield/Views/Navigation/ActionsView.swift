//
//  ActionsView.swift
//  Canfield
//
//  Created by David Geere on 2/6/23.
//

import SwiftUI

struct ActionsView: View {
    
    @EnvironmentObject private var game: Game
    
    var body: some View {
        HStack(spacing: 32) {
            ActionView(name: "hint")
                .onTapGesture {
                    self.game.restart()
                }
            if self.game.state == .started {
                ActionView(name: "pause")
                    .onTapGesture {
                        self.game.restart()
                    }
            } else {
                ActionView(name: "play")
                    .onTapGesture {
                        self.game.deal()
                    }
            }
            ActionView(name: "undo")
                .onTapGesture {
                    self.game.undo()
                }
        }
        .padding(16)
        .frame(height: 64)
        .background(.black.opacity(0.2))
        .clipShape(RoundedRectangle(cornerRadius: 32))
    }
}

struct ActionsView_Previews: PreviewProvider {
    static var previews: some View {
        ActionsView()
    }
}
