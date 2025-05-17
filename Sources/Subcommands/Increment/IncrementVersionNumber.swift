//
//  IncrementVersionNumber.swift
//  SwiftProjectTools
//
//  Created by Dustyn August on 4/19/25.
//

import Foundation
import ArgumentParser

struct IncrementVersionNumber: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "version-number",
        abstract: "Increment project version."
    )
    
    @Argument(
        help: ArgumentHelp(
            "The version component to increment.",
            valueName: "component"
        )
    )
    var component: SemanticVersionNumber.Component
    
    @OptionGroup
    var sharedOptions: SharedOptions
    
    mutating func run() throws {
        let loggingEnabled: Bool
#if DEBUG
        loggingEnabled = sharedOptions.loggingEnabled
#else
        loggingEnabled = false
#endif
        let runner = ActionRunner(loggingEnabled: loggingEnabled)
        let pbxproj = try PBXProj(from: sharedOptions, using: runner)
        let pbxprojValue: PBXProj.BuildSetting = .MARKETING_VERSION
        
        var changes: [Output.VersionChange] = []

        for (configuration, buildConfig) in pbxproj.configurations {
            let currentValue = try runner.extract(.pbxproj(pbxprojValue), from: buildConfig.value)
            
            let newValue = try incremented(
                versionNumber: component,
                in: currentValue,
                target: sharedOptions.target,
                configuration: configuration
            )
            
            try runner.update(
                .pbxproj(
                    id: buildConfig.id,
                    key: pbxprojValue,
                    newValue: newValue,
                    filePath: pbxproj.filePath
                )
            )
            
            changes.append(
                Output.VersionChange(
                    configuration: configuration,
                    component: component,
                    from: currentValue,
                    to: newValue
                )
            )
        }
        
        let fallbackMessage = "Incremented \(component.rawValue) version number."
        switch sharedOptions.outputFormat {
        case .text:
            guard
                !changes.isEmpty
            else {
                throw CleanExit.message(fallbackMessage)
            }
            
            throw CleanExit.message(changes.map(\.message).joined(separator: "\n"))

        case .json:
            let message = String(
                decoding: try JSONEncoder().encode(changes),
                as: UTF8.self
            )
            
            if !message.isEmpty {
                throw CleanExit.message(message)
                
            } else {
                throw CleanExit.message(fallbackMessage)
            }
        }
    }
}

private extension IncrementVersionNumber {
    private func incremented(
        versionNumber component: SemanticVersionNumber.Component,
        in currentValueString: String,
        target: String,
        configuration: String
    ) throws -> String {
        guard
            let currentSemanticVersion = SemanticVersionNumber(from: currentValueString)
        else {
            throw SwiftProjectToolsError.semanticVersionNumberError(target: target, configuration: configuration)
        }

        switch component {
        case .major:
            let newValue = currentSemanticVersion.major + 1
            return "\(newValue).0.0"

        case .minor:
            let newValue = currentSemanticVersion.minor + 1
            return "\(currentSemanticVersion.major).\(newValue).0"

        case .patch:
            let newValue = currentSemanticVersion.patch + 1
            return "\(currentSemanticVersion.major).\(currentSemanticVersion.minor).\(newValue)"
        }
    }
}
