//
//  CommandHistory.swift
//  Canfield
//
//  Created by David Geere on 2/21/23.
//

import Foundation

// Class for managing undo and redo history
class CommandHistory {
    private var undoStack: [UndoableCommand] = []
    private var redoStack: [UndoableCommand] = []
    
    func execute(command: UndoableCommand) {
        command.execute()
        undoStack.append(command)
        redoStack.removeAll()
    }
    
    func undo() {
        if let command = undoStack.popLast() {
            command.undo()
            redoStack.append(command)
        }
    }
    
    func redo() {
        if let command = redoStack.popLast() {
            command.execute()
            undoStack.append(command)
        }
    }
    
    func canUndo() -> Bool {
        return !undoStack.isEmpty
    }
    
    func canRedo() -> Bool {
        return !redoStack.isEmpty
    }
    
    func clear() {
        undoStack.removeAll()
        redoStack.removeAll()
    }
}
