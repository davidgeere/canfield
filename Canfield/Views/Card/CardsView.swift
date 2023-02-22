//
//  CardsView.swift
//  Canfield
//
//  Created by David Geere on 2/9/23.
//

import SwiftUI

struct CardsView: View {
    
    @EnvironmentObject private var game: Game
    
    var body: some View {
        ZStack {
            ForEach(self.$game.cards) { card in
                CardView(card)
                    .playable(
                        card,
                        onTap: {
                            if $0.card.face == .up {
                                switch $0.card.placement {
                                case .stock:
                                    self.game.waste($0)
                                case .waste:
                                    self.game.place($0)
                                case .foundation: return
                                case .tableau:
                                    self.game.place($0)
                                default: return
                                }
                            }
                        },
                        onDrag: {
                            self.game.drag($0)
                        },
                        onDrop: {
                            self.game.drop($0)
                        },
                        onReset: {
                            self.game.regroup($0)
                        })
            }
        }
        .size(for: .full)
    }
}

struct CardsView_Previews: PreviewProvider {
    static var previews: some View {
        CardsView()
            .environmentObject(Game.preview)
    }
}
