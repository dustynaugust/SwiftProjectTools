//
//  Increment.swift
//  SwiftProjectTools
//
//  Created by Dustyn August on 5/11/25.
//

import ArgumentParser

struct Increment: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "increment",
        abstract: "Increment values like project version or build number.",
        subcommands: [
            IncrementBuildNumber.self,
            IncrementVersionNumber.self
        ]
    )
}
