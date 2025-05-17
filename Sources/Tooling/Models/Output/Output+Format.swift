//
//  Output+Format.swift
//  SwiftProjectTools
//
//  Created by Dustyn August on 5/17/25.
//

import ArgumentParser

extension Output{
 enum Format: String {
    case text
    case json = "JSON"

    static var helpDescription: String {
        allCases.map(\.rawValue).joined(separator: ", ")
    }
}
}

extension Output.Format: CaseIterable { }

extension Output.Format: ExpressibleByArgument { }

extension Output.Format: CustomStringConvertible {
    var description: String { rawValue }
}
