//
//  SemanticVersionNumber+Component.swift
//  
//
//  Created by Dustyn August on 9/26/24.
//

import Foundation
import ArgumentParser

extension SemanticVersionNumber {
    enum Component: String, Codable {
        case major = "MAJOR"
        case minor = "MINOR"
        case patch = "PATCH"
    }
}

extension SemanticVersionNumber.Component: CaseIterable { }

extension SemanticVersionNumber.Component: ExpressibleByArgument {
    init?(
        argument: String
    ) {
        switch argument.uppercased() {
        case SemanticVersionNumber.Component.major.rawValue:
            self = .major
            
        case SemanticVersionNumber.Component.minor.rawValue:
            self = .minor
            
        case SemanticVersionNumber.Component.patch.rawValue:
            self = .patch
            
        default:
            return nil
        }
    }
}
