//
//  Table.swift
//  Canfield
//
//  Created by David Geere on 2/2/23.
//

import Foundation

class Table {
    
    private var placements: [Placement : CGRect]
    
    public var bounds: CGRect {
        didSet {
            print("table:", self.bounds)
        }
    }
    
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
    
    public func position(_ card:Card) -> CGPoint {
        
        var x:CGFloat = .zero
        var y:CGFloat = .zero
        
        if card.placement == .none {
            x = 0
            y = 0
        } else {
            x = self[card.placement].origin.x + (self[card.placement].width / 2)
            y = self[card.placement].origin.y + (self[card.placement].height / 2)
        }
        
        return CGPoint(x: x, y: y)
    }
}
