//
//  TableView.swift
//  Canfield
//
//  Created by David Geere on 1/26/23.
//

import SwiftUI

struct GameView: View {
    
    @EnvironmentObject private var game: Game
    
    @Environment(\.verticalSizeClass) var verticalSizeClass: UserInterfaceSizeClass?
    @Environment(\.horizontalSizeClass) var horizontalSizeClass: UserInterfaceSizeClass?
    
    var body: some View {
        VStack {
            //            if horizontalSizeClass == .compact && verticalSizeClass == .regular {
            //                Text("iPhone Portrait")
            //            } else if horizontalSizeClass == .regular && verticalSizeClass == .compact {
            //                Text("iPhone Landscape")
            //            } else if horizontalSizeClass == .compact && verticalSizeClass == .compact {
            //                Text("Small iPhone Landscape")
            //            } else if horizontalSizeClass == .regular && verticalSizeClass == .regular {
            //                Text("iPad Portrait/Landscape")
            //            }
            
            HeaderView()
            ZStack(alignment: .top) {
                TableView()
                    .environmentObject(self.game)
                
                CardsView()
                    .environmentObject(self.game)
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
