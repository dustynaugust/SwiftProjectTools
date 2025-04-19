//
//  PBXProjTool.swift
//
//
//  Created by Dustyn August on 9/24/24.
//

import ArgumentParser
import Foundation

struct PBXProjTool: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "pbxproj-tool",
        abstract: "A tool for updating values in a .pbxproj file.",
        subcommands: [
            Increment.self
        ]
    )
}

struct Increment: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "increment",
        abstract: "Increment project values like version or build number.",
        subcommands: [
            IncrementBuildNumber.self,
            IncrementVersionNumber.self
        ]
    )
}
