//
//  Numerics.swift
//  Canfield
//
//  Created by David Geere on 2/4/23.
//

import Foundation

struct Core {
    
    private init() {}
    
    public struct Numeric {
        
        private init() {}
        
        public static func round(_ value: Double, precision: Int = 0) -> String
        {
            return String(format: "%.\(precision)f", value)
        }
    }
}

extension CGFloat {
    func round(precision: Int = 0) -> String
    {
        return Core.Numeric.round(self, precision: precision)
    }
}

extension Double {
    func round(precision: Int = 0) -> String
    {
        return Core.Numeric.round(self, precision: precision)
    }
}

extension Int {
    func words() -> String {
        
        let formatter = NumberFormatter()
        
        formatter.numberStyle = .spellOut
        
        if let result = formatter.string(from: NSNumber(value: self)) {
            return result
        }
        
        return String(self)
    }
}
