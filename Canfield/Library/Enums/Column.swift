//
//  Column.swift
//  Canfield
//
//  Created by David Geere on 2/2/23.
//

import Foundation

enum Column: Int, CaseIterable, Codable, Identifiable {
    
    case one = 1
    case two = 2
    case three = 3
    case four = 4
    case five = 5
    case six = 6
    case seven = 7
    
    var id: Int {
        return self.rawValue
    }
    
    var value: Int {
        return self.rawValue
    }
    
    var count: Int {
        return self.value - 1
    }
    
    var order: Int {
        return self.rawValue * 100
    }
    
    var name: String {
        return self.value.words()
    }
    
}
