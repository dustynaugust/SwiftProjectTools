//
//  SwiftProjectToolsError.swift
//  
//
//  Created by Dustyn August on 9/26/24.
//

import Foundation

struct SwiftProjectToolsError: LocalizedError {
    let _errorDescription: String?
    let failureReason: String?
    let recoverySuggestion: String?
    
    init(
        errorDescription: String?,
        failureReason: String?,
        recoverySuggestion: String?
    ) {
        self._errorDescription = errorDescription
        self.failureReason = failureReason
        self.recoverySuggestion = recoverySuggestion
    }
    
    var errorDescription: String? {
        var lines: [String] = []
        
        if let _errorDescription {
            lines.append(_errorDescription)
        }
        
        if let failureReason {
            lines.append("Failure Reason: \(failureReason)")
        }
        
        if let recoverySuggestion {
            lines.append("Recovery Suggestion: \(recoverySuggestion)")
        }
        
        return lines.isEmpty ? nil : lines.joined(separator: "\n")
    }
}

extension SwiftProjectToolsError {
    static func buildNumberError(
        target: String,
        configuration: String
    ) -> SwiftProjectToolsError {
        SwiftProjectToolsError(
            errorDescription: .errorDescription(
                "Invalid build number (\(PBXProj.BuildSetting.CURRENT_PROJECT_VERSION.rawValue))",
                target: target,
                configuration: configuration
            ),
            failureReason: "The build number is not an Integer value.",
            recoverySuggestion: "Check the build number for is a valid Integer value."
        )
    }
    
    static let parseActionOutputError = SwiftProjectToolsError(
        errorDescription: "Unable to parse internal action output.",
        failureReason: nil,
        recoverySuggestion: nil
    )
        
    static func semanticVersionNumberError(
        target: String,
        configuration: String
    ) -> SwiftProjectToolsError {
        SwiftProjectToolsError(
            errorDescription:  .errorDescription(
                "Invalid version number (\(PBXProj.BuildSetting.MARKETING_VERSION.rawValue))",
                target: target,
                configuration: configuration
            ),
            failureReason: "The version number does not follow semantic versioning.",
            recoverySuggestion:  "Check the version number is in format \"MAJOR.MINOR.PATCH\"."
        )
    }
}

private extension String {
    static func errorDescription(
        _ message: String,
        target: String,
        configuration: String
    ) -> String {
        "\(message) for target \(target) in configuration \(configuration)"
    }
}
