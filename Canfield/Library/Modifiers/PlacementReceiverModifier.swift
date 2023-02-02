//
//  PlacementReceiver.swift
//  Canfield
//
//  Created by David Geere on 2/2/23.
//

import Foundation
import SwiftUI

struct PlacementReceiverModifier: ViewModifier {
    
    private var receive: ([PlacementData]) -> Void
    
    init(receive: @escaping ([PlacementData]) -> Void ) {
        self.receive = receive
    }
    
    func body(content: Content) -> some View {
        content
            .onPreferenceChange(PlacementPreferenceKey.self){ value in
                self.receive(value)
            }
    }
}
