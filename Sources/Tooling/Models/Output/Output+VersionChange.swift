//
//  Output+VersionChange.swift
//  SwiftProjectTools
//
//  Created by Dustyn August on 5/17/25.
//

extension Output {
    struct VersionChange: Codable {
        let configuration: String
        let component: SemanticVersionNumber.Component
        let from: String
        let to: String
        
        var message: String {
            "Incremented \(component.rawValue.uppercased()) version number from \(from) to \(to) in \(configuration) configuration."
        }
    }
}
