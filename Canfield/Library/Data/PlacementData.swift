//
//  PlacementData.swift
//  Canfield
//
//  Created by David Geere on 2/2/23.
//

import Foundation

struct PlacementData: Identifiable, Equatable {
    
    var id: Placement {
        return self.placement
    }
    
    let placement: Placement
    let bounds: CGRect
    
    init(_ placement: Placement, bounds: CGRect) {
    
        self.placement = placement
        self.bounds = bounds
        
    }
    
    static func == (left: PlacementData, right: PlacementData) -> Bool {
        return left.id == right.id
    }
}
