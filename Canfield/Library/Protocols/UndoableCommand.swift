//
//  UndoableCommand.swift
//  Canfield
//
//  Created by David Geere on 2/21/23.
//

import Foundation

/// We use the Command pattern, which separates the request for an action from the actual execution of that action.
/// This allows you to easily undo and redo actions by keeping track of a history of commands.
///
/// Protocol for commands that can be undone
protocol UndoableCommand {
    func execute()
    func undo()
}
