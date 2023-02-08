//
//  Array.swift
//  Canfield
//
//  Created by David Geere on 2/8/23.
//

import Foundation

extension Array where Element: Equatable {
    func union(with elements:[Element]) -> [Element] {
        return self + elements.filter { new in
            return !self.contains { old in
                return new == old
            }
        }
    }
}
