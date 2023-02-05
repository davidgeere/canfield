//
//  Numerics.swift
//  Canfield
//
//  Created by David Geere on 2/4/23.
//

import Foundation

struct Numerics {
    public enum RoundingPrecision {
        case ones
        case tenths
        case hundredths
    }

    public func round<N: Numeric>(_ value: N, precision: RoundingPrecision = .ones) -> N
    {
        switch precision {
        case .ones:
            return round(value)
        case .tenths:
            return round(value * 10) / 10.0
        case .hundredths:
            return round(value * 100) / 100.0
        }
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
