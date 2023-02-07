//
//  CardView.swift
//  Canfield
//
//  Created by David Geere on 2/2/23.
//

import SwiftUI

struct CardView: View {
    
    @Binding public var card: Card
    
    private let axis: (x: CGFloat, y: CGFloat, z: CGFloat)

    init(_ card: Binding<Card>) {
        self._card = card
        self.axis = (x: .zero, y: 1, z: .zero)
    }
    
    var body: some View {
        ZStack {
            VStack {
                VStack {
                    ZStack (alignment: .top) {
                        if self.card.face == .up && self.card.placement != .stock {
                            Image("deck.default.\(card.suite.name).\(card.rank.name)")
                                .resizable()
                                .scaledToFill()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .rotation3DEffect(.degrees(180), axis: self.axis)
                        } else {
                            Image("deck.default.back")
                                .resizable()
                                .scaledToFill()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                    }
                }
                .overlay(alignment: .top){
                    HStack {
                        Text("\(card.symbol)")
                        Text("\(card.order)")
                    }
                    .font(.footnote)
                    .rotation3DEffect(card.face == .up ? .degrees(180): .zero, axis: self.axis)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 4))
            }
            .size(for: .card)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .opacity(card.placement == .none ? 0 : 1)
            .shadow(radius: card.moving ? 8 : card.order == 1 ? 2 : 0)
            .rotation3DEffect(card.face == .up ? .degrees(180): .zero, axis: self.axis)
            .animation(.easeIn(duration: 0.3), value: card.face)
            .animation(.easeIn(duration: 0.3), value: card.placement)
        }
        .offset(x: card.offset.width, y: card.offset.height)
        .position(x: card.bounds.midX, y: card.bounds.midY)
        .zIndex( card.zindex )
    }
}

struct CardView_Previews: PreviewProvider {
    
    static var card1 = Card(suite: .clubs, rank: .jack, placement: .ready, face: .up, moving: true)
    static var card2 = Card(suite: .clubs, rank: .jack, placement: .ready, moving: true)

    static var previews: some View {
        HStack {
            CardView(.constant(card1))

            CardView(.constant(card2))
        }
        .size(for: .full)
        .background(Globals.TABLE.COLOR)
    }
}
