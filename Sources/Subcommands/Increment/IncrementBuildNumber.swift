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
        let buildSetting: PBXProj.BuildSetting = .CURRENT_PROJECT_VERSION
        
        for (configuration, buildConfig) in pbxproj.configurations {
            let currentValue = try runner.extract(.pbxproj(buildSetting), from: buildConfig.value)
            
            let newValue = try incremented(
                buildNumber: currentValue,
                target: sharedOptions.target,
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
    ) throws -> String {
        guard
            let currentValue = Int(currentValueString)
        else {
            throw SwiftProjectToolsError.buildNumberError(target: target, configuration: configuration)
        }

        return "\(currentValue + 1)"
    }
}
