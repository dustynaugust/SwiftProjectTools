//
//  ProjectOptions.swift
//  SwiftProjectTools
//
//  Created by Dustyn August on 4/19/25.
//

import ArgumentParser

struct ProjectOptions: ParsableArguments {
    @Option(
        name: [.customShort("t"), .customLong("target")],
        help: ArgumentHelp(
            "Specify the target project.",
            valueName: "target"
        )
    )
    var target: String

    @Option(
        name: [.customShort("c"), .customLong("configurations")],
        parsing: .upToNextOption,
        help: ArgumentHelp(
            "Specify the configurations (e.g., Develop, Release).",
            valueName: "config"
        )
    )
    var configurations: [String]

    @Option(
        name: [.customShort("p"), .customLong("pbxproj-file-path")],
        help: ArgumentHelp(
            "Full path to the .pbxproj file.",
            valueName: "path"
        )
    )
    var pbxprojFilePath: String

    @Flag(
        name: [.customShort("l"), .customLong("logging-enabled")],
        help: .hidden
    )
    var loggingEnabled = false
}
