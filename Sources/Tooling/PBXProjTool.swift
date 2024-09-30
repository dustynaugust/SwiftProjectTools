//
//  PBXProjTool.swift
//
//
//  Created by Dustyn August on 9/24/24.
//

import ArgumentParser
import Foundation

struct PBXProjTool: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "pbxproj-tool",
        abstract: "A tool for updating values in a .pbxproj file."
    )

    @Option(
        name: [.customShort("i"), .customLong("actions")],
        parsing: .upToNextOption,
        help: "Specify increment action(s)."
    )
    var actions: [IncrementAction]

    @Option(
        name: [.customShort("t"), .customLong("target")],
        help: "Specify the target project."
    )
    var target: String

    @Option(
        name: [.customShort("c"), .customLong("configurations")],
        parsing: .upToNextOption,
        help: "Specify the configurations (e.g., Develop, Release)."
    )
    var configurations: [String]

    @Option(
        name: [.customShort("p"), .customLong("pbxproj-file-path")],
        help: "Specify the path to the .pbxproj file."
    )
    var pbxprojFilePath: String

    @Flag(
        name: [.customShort("l"), .customLong("logging-enabled")],
        help: "Enable logging."
    )
    var loggingEnabled = false

    func run() throws {
        for action in actions {
            let pbxproj = try PBXProjValidator.validate(pbxprojFilePath)
            try validate(target: target)
            try validate(configurations: configurations)

            let pbxNativeTargetSection = try run(
                .extract(.pbxproj(section: .PBXNativeTarget)),
                input: pbxproj
            )

            let targetSection = try run(
                .extract(.targetSection(for: target)),
                input: pbxNativeTargetSection
            )

            let buildConfigurationListID = try run(
                .extract(.buildConfigurationListID(for: target)),
                input: targetSection
            )

            let xcConfigurationListSection = try run(
                .extract(.pbxproj(section: .XCConfigurationList)),
                input: pbxproj
            )

            let buildConfigurationList = try run(
                .extract(.buildConfigurationList(with: buildConfigurationListID)),
                input: xcConfigurationListSection
            )

            for configuration in configurations {
                let buildConfigurationID = try run(
                    .extract(.buildConfigurationID(for: configuration)),
                    input: buildConfigurationList
                )

                let buildConfiguration = try run(
                    .extract(.buildConfiguration(for: configuration, with: buildConfigurationID)),
                    input: pbxproj
                )

                let currentValueString = try run(
                    .extract(.incrementValue(with: action.buildConfigurationKey)),
                    input: buildConfiguration
                )

                let newValueString: String
                switch action {
                case .buildNumber:
                    newValueString = try incremented(
                        buildNumber: currentValueString,
                        target: target,
                        configuration: configuration
                    )

                case let .versionNumber(component):
                    newValueString = try incremented(
                        versionNumber: component,
                        in: currentValueString,
                        target: target,
                        configuration: configuration
                    )
                }

                let _ = try run(
                    .update(.pbxproj(id: buildConfigurationID, key: action.buildConfigurationKey, newValue: newValueString, filePath: pbxprojFilePath)),
                    input: nil
                )
            }
        }
    }
}

// MARK: Standard Output Helper(s)
private extension PBXProjTool {
    private func log(_ message: String) {
        guard loggingEnabled else { return }

        output(message)
    }

    private func log(command: String) {
        guard loggingEnabled else { return }

        output("COMMAND: ----------\n\(string(for: command))\n----------")
    }

    private func log(input: String) {
        guard loggingEnabled else { return }

        output("INPUT: ----------\n\(input)\n----------")
    }

    private func log(result: String) {
        guard loggingEnabled else { return }

        output("RESULT: ----------\n\(result)\n----------")
    }

    private func output(_ message: String) {
        print(message)
    }

    private func output(
        _ error: PBXProjToolError,
        function: String = #function
    ) {
        var message = ""
        if let localizedDescription = error.errorDescription {
            message.append(" Description: \(localizedDescription).")
        }

        if let recoverySuggestion = error.recoverySuggestion {
            message.append(" Suggestion: \(recoverySuggestion).")
        }


        output("ERROR in \(function).\(message)")
    }

    private func string(for command: String) -> String {
        if command.isEmpty {
            return "\"\""
        } else {

            return command
        }
    }
}

// MARK: Validate Helper(s)
private extension PBXProjTool {
    private func validate(
        target: String
    ) throws {
        guard
            !target.isEmpty
        else {
            throw ValidationError("Target must be specified.")
        }
    }
    
    private func validate(configurations: [String]) throws {
        guard !configurations.isEmpty else {
            throw ValidationError("At least one configuration must be specified.")
        }
    }
}

// MARK: Command Helper(s)
private extension PBXProjTool {
    private func run(
        _ command: Command,
        input: String?
    ) throws -> String {
        try run(command.rawValue, input: input)
    }

    private func run(
        _ command: String,
        input: String?
    ) throws -> String {
        let task = Process()
        let pipe = Pipe()

        task.standardOutput = pipe
        task.standardError = pipe
        task.arguments = ["-c", command]
        task.executableURL = URL(fileURLWithPath: "/bin/zsh")

        log(command: command)

        if let input {
            log(input: input)
            let inputPipe = Pipe()
            inputPipe.fileHandleForWriting.write(input.data(using: .utf8)!)
            inputPipe.fileHandleForWriting.closeFile()
            task.standardInput = inputPipe

        } else {
            task.standardInput = nil
        }

        try task.run()

        let data = try pipe.fileHandleForReading.readToEnd()

        guard
            let data
        else {
            log("empty data returned from command: \(string(for: command))")
            return ""
        }

        guard
            let output = String(data: data, encoding: .utf8)
        else {
            let error = PBXProjToolError.parseCommandOutput
            output(error)
            throw error
        }

        let result = output.trimmingCharacters(in: .whitespacesAndNewlines)
        log(result: result)
        return result
    }
}

// MARK: Increment Helper(s)
private extension PBXProjTool {
    private func incremented(
        buildNumber currentValueString: String,
        target: String,
        configuration: String
    ) throws -> String {
        guard
            let currentValue = Int(currentValueString)
        else {
            let error = PBXProjToolError.buildNumber(target: target, configuration: configuration)
            output(error)
            throw error
        }

        return "\(currentValue + 1)"
    }

    private func incremented(
        versionNumber: SemanticVersionComponent,
        in currentValueString: String,
        target: String,
        configuration: String
    ) throws -> String {
        guard
            let currentSemanticVersion = SemanticVersionNumber(from: currentValueString)
        else {
            let error = PBXProjToolError.semanticVersionNumber(target: target, configuration: configuration)
            output(error)
            throw error
        }

        switch versionNumber {
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
