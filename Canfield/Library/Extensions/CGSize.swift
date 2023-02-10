//
//  CGSize.swift
//  Canfield
//
//  Created by David Geere on 2/9/23.
//

import Foundation

extension CGSize {
    var ratio: CGFloat {
        if self.height > self.width {
            return self.width / self.height
        } else {
            return self.height / self.width
        }
    }
}
