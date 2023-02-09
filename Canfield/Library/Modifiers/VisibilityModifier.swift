//
//  VisibilityModifier.swift
//  Canfield
//
//  Created by David Geere on 2/8/23.
//

import Foundation

import SwiftUI

struct VisibilityModifier : ViewModifier {
    var hide = false
    var remove = false
    
    func body(content: Content) -> some View {
        if hide {
            if remove {
                
            } else {
                content.hidden()
            }
        } else {
            content
        }
    }
}
