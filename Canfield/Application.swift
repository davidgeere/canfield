//
//  CanfieldApp.swift
//  Canfield
//
//  Created by David Geere on 1/26/23.
//

import SwiftUI

@main
struct Application: App {
    
    @StateObject private var game = Game.instance
    
    var body: some Scene {
        WindowGroup {
//            GameView()
//                .environmentObject(self.game)
            TestView()
        }
    }
}
