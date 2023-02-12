//
//  Table.swift
//  Canfield
//
//  Created by David Geere on 2/2/23.
//

import Foundation

class Table {
    
    public static let instance = Table()
    
    private var placements: [Placement : CGRect]
    
    private init() {
        self.placements = [:]
        
        self.placements[.stock] = CGRect.zero
        self.placements[.waste] = CGRect.zero
        
        for column in Column.allCases {
            self.placements[.tableau(column)] = CGRect.zero
        }
        
        for suite in Suite.allCases {
            self.placements[.foundation(suite)] = CGRect.zero
        }
    }
    
    subscript(placement: Placement) -> CGRect {
        get {
            guard let bounds = self.placements[placement] else { return CGRect.zero }
            
            return bounds
        }
        set {
            return self.placements[placement] = newValue
        }
    }
    
    public func placement(area: CGRect) -> Placement? {
        for placement in Placement.allCases {
            
            guard area.within(area: self[placement]) else { continue }
            
            return placement
        }
        
        return nil
    }
}
