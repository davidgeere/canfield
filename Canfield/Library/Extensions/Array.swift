//
//  Array.swift
//  Canfield
//
//  Created by David Geere on 2/8/23.
//

import Foundation

extension Array {
    mutating func shuffle() {
        for i in 0..<(count - 1) {
            let j = Int(arc4random_uniform(UInt32(count - i))) + i
            swapAt(i, j)
        }
    }
}

extension Array where Element: Equatable {
    func union(with elements:[Element]) -> [Element] {
        return self + elements.filter { new in
            return !self.contains { old in
                return new == old
            }
        }
    }
}
