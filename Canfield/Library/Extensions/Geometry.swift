//
//  CGRect.swift
//  Canfield
//
//  Created by David Geere on 2/4/23.
//

import Foundation

struct Geometry {
    
    public static func within(position1: CGPoint, position2: CGPoint, size: CGSize) -> Bool {
        return within(position1: position1, position2: position2, height: size.height, width: size.width)
    }
    
    public static func within(position1: CGPoint, position2: CGPoint, height: CGFloat, width: CGFloat) -> Bool {
        return within(x1: position1.x, x2: position2.x, y1: position1.y, y2: position2.y, height: height, width: width)
    }
    
    public static func within(x1: CGFloat, x2: CGFloat, y1: CGFloat, y2: CGFloat, height: CGFloat, width: CGFloat) -> Bool {
        
        let detection_x = abs(x1 - x2) < width
        let detection_y = abs(y1 - y2) < height
        
        guard detection_x && detection_y else { return false }
        
        return true
    }
}

extension CGRect {
    func within(area: CGRect) -> Bool {
        return Geometry.within(x1: area.minX, x2: self.minX, y1: area.minY, y2: self.minY, height: area.height, width: area.width)
    }
}
