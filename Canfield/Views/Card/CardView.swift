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
                    .overlay(alignment: .bottom) {
                            VStack {
                                
                                Text("O: \(card.order)")
                                
                                if card.parent != nil {
                                    Text("P: \(card.parent!.suite.symbol) \(card.parent!.rank.symbol)")
                                }
                                
                                if card.child != nil {
                                    Text("C: \(card.child!.suite.symbol) \(card.child!.rank.symbol)")
                                }
                            }
                            .foregroundColor(.black)
                            .font(.footnote)
                            .rotation3DEffect(.degrees(180), axis: self.axis)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 4))
            }
            .size(for: .card)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .opacity(card.placement == .none ? 0 : 1)
            .shadow(radius: card.moving ? 8 : 0)
            .rotation3DEffect(card.face == .up ? .degrees(180): .zero, axis: self.axis)
            .animation(.default, value: card.face)
        }
        .position(card.bounds.origin)
        .zIndex(card.moving ? 1000 : Double(card.order) )
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
