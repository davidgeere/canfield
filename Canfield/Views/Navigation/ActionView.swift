//
//  ActionView.swift
//  Canfield
//
//  Created by David Geere on 2/6/23.
//

import SwiftUI

struct ActionView: View {
    
    var name: String
    
    var body: some View {
        
        VStack {
            Image("icons/small/\(self.name)")
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundColor(.white)
        }
        .padding(12)
        .frame(width: 48, height: 48)
        .background(.white.opacity(0.2))
        .clipShape(RoundedRectangle(cornerRadius: 24))
        
    }
}

struct ActionView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            ActionView(name: "settings")
        }
        .size(for: .full)
        .background(Globals.TABLE.COLOR)
        
    }
}
