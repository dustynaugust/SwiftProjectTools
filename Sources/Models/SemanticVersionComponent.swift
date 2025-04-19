//
//  SemanticVersionComponent.swift
//  
//
//  Created by Dustyn August on 9/26/24.
//

import Foundation
import ArgumentParser

enum SemanticVersionComponent: String {
    case major
    case minor
    case patch
}

extension SemanticVersionComponent: ExpressibleByArgument { }
