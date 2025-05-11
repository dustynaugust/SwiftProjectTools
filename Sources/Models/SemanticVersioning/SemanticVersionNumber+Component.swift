//
//  SemanticVersionNumber+Component.swift
//  
//
//  Created by Dustyn August on 9/26/24.
//

import Foundation
import ArgumentParser

extension SemanticVersionNumber {
    enum Component: String {
        case major
        case minor
        case patch
    }
}

extension SemanticVersionNumber.Component: ExpressibleByArgument { }
