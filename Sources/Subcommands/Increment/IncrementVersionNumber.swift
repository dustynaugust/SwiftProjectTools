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
    
    @Argument(help: "The version component to increment (major, minor, patch)")
    var component: SemanticVersionNumber.Component
    
    @OptionGroup
    var project: ProjectOptions
    
    mutating func run() throws {
        let runner = ActionRunner(loggingEnabled: project.loggingEnabled)
        let pbxproj = try PBXProj(from: project, using: runner)
        let pbxprojValue: PBXProj.BuildSetting = .MARKETING_VERSION
        
        var messages: [String] = []

        for (configuration, buildConfig) in pbxproj.configurations {
            let currentValue = try runner.extract(.pbxproj(pbxprojValue), from: buildConfig.value)
            
            let newValue = try incremented(
                versionNumber: component,
                in: currentValue,
                target: project.target,
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
            
            messages.append("Incremented \(component) version number from \(currentValue) to \(newValue) in \(configuration) configuration")
        }
        
        guard
            !messages.isEmpty
        else {
            throw ExitCode.failure
        }
        
        throw CleanExit.message(messages.joined(separator: "\n"))
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

