//
//  Table.swift
//  Canfield
//
//  Created by David Geere on 2/2/23.
//

import Foundation

class Table {
    
    private var placements: [Placement : CGRect]
    
    public var bounds: CGRect
    
    init() {
        self.bounds = .zero
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
}
