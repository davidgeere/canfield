//
//  Dispatch.swift
//  Canfield
//
//  Created by David Geere on 2/22/23.
//

import Foundation

func main(execute work: @escaping @convention(block) () -> Void) {
    DispatchQueue.main.async(execute: work)
}
