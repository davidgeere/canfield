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
            case .stock, .waste, .none, .ready:
                EmptyView()
            case .tableau:
                Circle()
                    .background(RoundedRectangle(cornerRadius: .infinity).stroke(.white.opacity(0.4), lineWidth: 2))
                    .frame(width: 59, height: 59)
                    .foregroundColor(.clear)
            case .foundation(let suite):
                Image("suites/\(suite.name)")
                    .resizable()
                    .frame(width: 59, height: 59)
                    .foregroundColor(.white.opacity(0.4))
            }
        }
        .size(for: .card)
        .background(.white.opacity(0.2))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .background(RoundedRectangle(cornerRadius: 10).stroke(.white.opacity(0.4), lineWidth: 2))
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
