//
//  CardDebugView.swift
//  Canfield
//
//  Created by David Geere on 2/4/23.
//

import SwiftUI

struct CardDebugView: View {
    
    @Binding public var card: Card
    
    init(_ card: Binding<Card>) {
        self._card = card
    }
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading) {
                
                DebugRowView("Card", value: self.card.symbol)
                DebugRowView("Order", value: String(self.card.order))
                
                
                DebugRowView("N", values: [((self.card.bounds.minX + self.card.offset.width) - (self.card.bounds.width / 2)).round(precision: 2),
                                           ((self.card.bounds.minY + self.card.offset.height) - (self.card.bounds.height / 2)).round(precision: 2)] )
                
                DebugRowView("O", values: [self.card.offset.height.round(precision: 2), self.card.offset.width.round(precision: 2)] )
                
                DebugRowView("X", values: [self.card.bounds.minX.round(precision: 0), self.card.bounds.midX.round(precision: 0), self.card.bounds.maxX.round(precision: 0)] )
                DebugRowView("Y", values: [self.card.bounds.minY.round(precision: 0), self.card.bounds.midY.round(precision: 0), self.card.bounds.maxY.round(precision: 0)] )
            }
        }
        .size(for: .full)
        .background(.white.opacity(0.8))
        .border(.red)
    }
}

struct CardDebugView_Previews: PreviewProvider {
    static var card = Card(suite: .clubs, rank: .jack)

    static var previews: some View {
        CardDebugView(.constant(card))
    }
}
