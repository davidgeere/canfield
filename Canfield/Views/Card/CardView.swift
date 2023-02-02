//
//  CardView.swift
//  Canfield
//
//  Created by David Geere on 2/2/23.
//

import SwiftUI

struct CardView: View {
    
    @EnvironmentObject private var game: Game
    
    @Binding public var card: Card

    init(_ card: Binding<Card>) {
        self._card = card
    }
    
    var body: some View {
        VStack {
            VStack {
                ZStack (alignment: .top) {
                    if self.card.face == .up && self.card.placement != .stock {
                        Image("deck.default.\(card.suite.name).\(card.rank.name)")
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        Image("deck.default.back")
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: 4))
        }
        .frame(width: Globals.CARD.WIDTH, height: Globals.CARD.HEIGHT)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .position(x: card.bounds.midX - card.bounds.width, y: card.bounds.midY - card.bounds.height)
    }
}

struct CardView_Previews: PreviewProvider {
    static var card1 = Card(suite: .clubs, rank: .jack, face: .up)

    static var card2 = Card(suite: .clubs, rank: .jack)
//
    static var previews: some View {
        HStack {
            CardView(.constant(card1))
                .environmentObject(Game.preview)

            CardView(.constant(card2))
                .environmentObject(Game.preview)
        }
        .fullscreen()
        .background(Globals.TABLE.COLOR)
    }
}
