//
//  StatusView.swift
//  Canfield
//
//  Created by David Geere on 2/6/23.
//

import SwiftUI

struct StatusView: View {
    
    public var name: String
    @State public var value: Int
    
    var body: some View {
        HStack( spacing: 4) {
            Image("icons/small/\(self.name.lowercased())")
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundColor(.white)
            
            HStack( spacing: 16) {
                Text(self.name)
                    .font(size: 17, .medium)
                
                Text(String(self.value))
                    .font(size: 17, .semiBold)
                    
            }
            .foregroundColor(.white)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .frame(height: 48)
        .background(.white.opacity(0.2))
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
}

struct StatusView_Previews: PreviewProvider {
    
    static var value: Int = 1000
    static var previews: some View {
        ZStack {
            StatusView(name: "Moves", value: value)
        }
        .size(for: .full)
        .background(Globals.TABLE.COLOR)
    }
}
