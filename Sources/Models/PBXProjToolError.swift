//
//  PBXProjToolError.swift
//  
//
//  Created by Dustyn August on 9/26/24.
//

import Foundation

enum PBXProjToolError: LocalizedError {
    case buildNumber(target: String, configuration: String)
    case parseCommandOutput
    case semanticVersionNumber(target: String, configuration: String)

    var errorDescription: String? {
        switch self {
        case let .buildNumber(target, configuration):
            return "Invalid build number for target \(target) in configuration \(configuration)"

        case .parseCommandOutput:
            return "Unable to parse internal command output."

        case let .semanticVersionNumber(target, configuration):
            return "Invalid version number for target \(target) in configuration \(configuration)"
        }
    }

    var failureReason: String? {
        switch self {
        case .buildNumber:
            return "The build number is not an Integer value."

        case.parseCommandOutput:
            return nil

        case .semanticVersionNumber:
            return "The version number does not follow semantic versioning (X.Y.Z)"
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case let .buildNumber(target, configuration):
            return "Check the build number for target \(target) in configuration \(configuration) is a valid Integer value."

        case .parseCommandOutput:
            return nil

        case let .semanticVersionNumber(target, configuration):
            return "Check the version number for target \(target) in configuration \(configuration) is in format \"X.Y.Z\""
        }
    }
}
