//
//  Command.swift
//  Canfield
//
//  Created by David Geere on 2/22/23.
//

import Foundation

protocol Command {
    
    func execute()
    
    func undo()
    
    func redo()
    
}
