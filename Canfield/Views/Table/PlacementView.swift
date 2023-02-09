//
//  TableSpaceView.swift
//  Canfield
//
//  Created by David Geere on 2/2/23.
//

import SwiftUI

struct PlacementView: View {
    
    private let placement: Placement
    
    init(for placement: Placement) {
        self.placement = placement
    }
    
    var body: some View {
        VStack {
            switch self.placement {
            case .waste, .none, .ready:
                EmptyView()
            case .stock:
                Image("icons/large/refresh")
                    .resizable()
                    .frame(width: 59, height: 59)
                    .foregroundColor(.white.opacity(0.4))
            case .tableau:
                Image("icons/large/open")
                    .resizable()
                    .frame(width: 59, height: 59)
                    .foregroundColor(.white.opacity(0.4))
            case .foundation(let suite):
                Image("icons/large/\(suite.name)")
                    .resizable()
                    .frame(width: 59, height: 59)
                    .foregroundColor(.white.opacity(0.4))
            }
        }
        .size(for: .card)
        .background(.white.opacity(0.2))
        .background(RoundedRectangle(cornerRadius: 10).stroke(.white.opacity(0.4), lineWidth: 4))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        
    }
}

struct TableSpaceView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            PlacementView(for: .stock)
        }
        .size(for: .full)
        .background(Globals.TABLE.COLOR)
    }
}
