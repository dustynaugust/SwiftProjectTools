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

extension Output.Format: CustomStringConvertible {
    var description: String { rawValue }
}

extension Output.Format: ExpressibleByArgument {
    init?(
        argument: String
    ) {
        switch argument.uppercased() {
        case Output.Format.text.rawValue.uppercased():
            self = .text
            
        case Output.Format.json.rawValue:
            self = .json
            
        default:
            return nil
        }
    }
}
