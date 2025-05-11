//
//  IncrementBuildNumber.swift
//  SwiftProjectTools
//
//  Created by Dustyn August on 4/19/25.
//

import ArgumentParser
import Foundation

struct IncrementBuildNumber: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "build-number",
        abstract: "Increment project build number."
    )
    
    @OptionGroup
    var project: ProjectOptions
    
    mutating func run() throws {
        let runner = ActionRunner(loggingEnabled: project.loggingEnabled)
        let pbxproj = try PBXProj(from: project, using: runner)
        let buildSetting: PBXProj.BuildSetting = .CURRENT_PROJECT_VERSION
        
        for (configuration, buildConfig) in pbxproj.configurations {
            let currentValue = try runner.extract(.pbxproj(buildSetting), from: buildConfig.value)
            
            let newValue = try incremented(
                buildNumber: currentValue,
                target: project.target,
                configuration: configuration
            )
            
            try runner.update(
                .pbxproj(
                    id: buildConfig.id,
                    key: buildSetting,
                    newValue: newValue,
                    filePath: pbxproj.filePath
                )
            )
        }
    }
}

private extension IncrementBuildNumber {
    private func incremented(
        buildNumber currentValueString: String,
        target: String,
        configuration: String
    ) throws(SwiftProjectToolsError) -> String {
        guard
            let currentValue = Int(currentValueString)
        else {
            throw .buildNumberError(target: target, configuration: configuration)
        }

        return "\(currentValue + 1)"
    }
}
