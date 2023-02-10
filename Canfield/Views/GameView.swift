//
//  TableView.swift
//  Canfield
//
//  Created by David Geere on 1/26/23.
//

import SwiftUI

struct GameView: View {
    
    @EnvironmentObject private var game: Game
    
    var body: some View {
        VStack {
            HeaderView()
            ZStack(alignment: .top) {
                TableView()
                    .environmentObject(self.game)
                
                ZStack {
                    ForEach(self.$game.cards) { card in
                        CardView(card)
                            .playable(
                                card,
                                onTap: {
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
            .size(for: .full)
        }
        .overlay(alignment: .bottom) {
            ActionsView()
                .environmentObject(self.game)
        }
        .size(for: .full)
        .background(Globals.TABLE.COLOR)
    }
}

struct TableView_Previews: PreviewProvider {
    static var previews: some View {
        
        Group { // All
            Group { // Landscape
                GameView()
                    .previewDevice(PreviewDevice(rawValue: "iPhone 13 mini"))
                    .previewDisplayName("iPhone Small Landscape")
                
                GameView()
                    .previewDevice(PreviewDevice(rawValue: "iPhone 14"))
                    .previewDisplayName("iPhone Medium Landscape")
                
                GameView()
                    .previewDevice(PreviewDevice(rawValue: "iPhone 14 Pro Max"))
                    .previewDisplayName("iPhone Large Landscape")
                
                GameView()
                    .previewDevice(PreviewDevice(rawValue: "iPad Pro (11-inch)"))
                    .previewDisplayName("iPad Landscape")
                
                GameView()
                    .previewDevice(PreviewDevice(rawValue: "Mac Catalyst"))
                    .previewDisplayName("Mac")
            }
            .previewInterfaceOrientation(.landscapeRight)
            
            Group {
                GameView()
                    .previewDevice(PreviewDevice(rawValue: "iPhone 13 mini"))
                    .previewDisplayName("iPhone Small Portrait")
                
                GameView()
                    .previewDevice(PreviewDevice(rawValue: "iPhone 14"))
                    .previewDisplayName("iPhone Medium Portrait")
                
                GameView()
                    .previewDevice(PreviewDevice(rawValue: "iPhone 14 Pro Max"))
                    .previewDisplayName("iPhone Large Portrait")
                
                GameView()
                    .previewDevice(PreviewDevice(rawValue: "iPad Pro (11-inch)"))
                    .previewDisplayName("iPad Portrait")
            }
            .previewInterfaceOrientation(.portrait)
        }
        .environmentObject(Game.preview)
        
        
    }
}
