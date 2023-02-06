//
//  DebugView.swift
//  Canfield
//
//  Created by David Geere on 2/4/23.
//

import SwiftUI

struct LayoutDebugView: View {
    
    @EnvironmentObject private var game: Game
    
    var body: some View {
        ZStack() {
            ForEach(Placement.allCases) { placement in
                VStack(alignment: .leading) {
//                    DebugRowView("P", value: placement.name)
                    DebugRowView("X", values: [self.game.table[placement].minX.round(precision: 0), self.game.table[placement].midX.round(precision: 0), self.game.table[placement].maxX.round(precision: 0)] )
                    DebugRowView("Y", values: [self.game.table[placement].minY.round(precision: 0), self.game.table[placement].midY.round(precision: 0), self.game.table[placement].maxY.round(precision: 0)] )
//                    DebugRowView("S", values: [self.game.table[placement].width.round(precision: 0), self.game.table[placement].height.round(precision: 0)])
                    Spacer()
                }
                .frame(width: self.game.table[placement].width, height: self.game.table[placement].height)
                .background(.clear)
                .border(.red, width: 2)
                .position(x: self.game.table[placement].midX, y: self.game.table[placement].midY)
            }
        }
        .size(for: .full)
    }
}

struct LayoutDebugView_Previews: PreviewProvider {
    static var previews: some View {
        LayoutDebugView()
            .environmentObject(Game.preview)
    }
}
