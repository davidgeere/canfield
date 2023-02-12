//
//  StatusView.swift
//  Canfield
//
//  Created by David Geere on 2/6/23.
//

import SwiftUI

struct StatusView: View {
    
    @Binding public var status: Status
    
    var body: some View {
        HStack( spacing: 4) {
            Image("icons/small/\(self.status.key.value)")
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundColor(.white)
            
            HStack( spacing: 16) {
                Text(self.status.key.value)
                    .font(size: 17, .medium)
                
                Text(String(self.status.display))
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
    
    static var status = Status(key: .moves, value: 0)
    
    static var previews: some View {
        ZStack {
            StatusView(status: .constant(status))
        }
        .size(for: .full)
        .background(GLOBALS.TABLE.COLOR)
    }
}
