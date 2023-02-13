//
//  TableView.swift
//  Canfield
//
//  Created by David Geere on 1/26/23.
//

import SwiftUI
import SpriteKit

struct GameView: View {
    
    @EnvironmentObject private var game: Game
    
    @Environment(\.verticalSizeClass) var verticalSizeClass: UserInterfaceSizeClass?
    @Environment(\.horizontalSizeClass) var horizontalSizeClass: UserInterfaceSizeClass?
    
    var scene: GameScene {
        let scene = GameScene(size: Table.instance[.ready].size)
        scene.scaleMode = .resizeFill
        return scene
    }
    
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
                
                SpriteView(scene: scene)
                    .background(GLOBALS.TABLE.COLOR)
                    .environmentObject(self.game)
                    .size(for: .full)
            }
            .size(for: .full)
        }
        .overlay(alignment: .bottom) {
            ActionsView()
                .environmentObject(self.game)
        }
        .size(for: .full)
        .background(GLOBALS.TABLE.COLOR)
    }
}

struct TableView_Previews: PreviewProvider {
    static var previews: some View {
        
        GameView()
            .environmentObject(Game.preview)
        
        
    }
}
