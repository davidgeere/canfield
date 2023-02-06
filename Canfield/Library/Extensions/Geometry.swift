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
        
        let left = CGRect(x: x1, y: y1, width: width, height: height)
        let right = CGRect(x: x2, y: y2, width: width, height: height)
        
        return left.intersects(right)
    }
    
    public static func overlap(position1: CGPoint, position2: CGPoint, size: CGSize) -> Double {
        return overlap(position1: position1, position2: position2, height: size.height, width: size.width)
    }
    
    public static func overlap(position1: CGPoint, position2: CGPoint, height: CGFloat, width: CGFloat) -> Double {
        return overlap(x1: position1.x, x2: position2.x, y1: position1.y, y2: position2.y, height: height, width: width)
    }
    
    public static func overlap(x1: CGFloat, x2: CGFloat, y1: CGFloat, y2: CGFloat, height: CGFloat, width: CGFloat) -> Double {
        
        let left = CGRect(x: x1, y: y1, width: width, height: height)
        let right = CGRect(x: x2, y: y2, width: width, height: height)
        
        guard left.intersects(right) else { return 0.0 }
        
        let intersection = left.intersection(right)
        
        return ((intersection.width * intersection.height) / (((left.width * left.height) + (right.width * right.height))/2.0) * 100.0)
    }
}

extension CGRect {
    func within(area: CGRect) -> Bool {
        return Geometry.within(x1: area.minX, x2: self.minX, y1: area.minY, y2: self.minY, height: area.height, width: area.width)
    }
    
    func overlap(area: CGRect) -> Double {
        return Geometry.overlap(x1: area.minX, x2: self.minX, y1: area.minY, y2: self.minY, height: area.height, width: area.width)
    }
}
