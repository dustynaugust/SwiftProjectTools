import ArgumentParser

SwiftProjectTools.main()

struct SwiftProjectTools: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "swift-project-tools",
        abstract: "Tools for updating Swift and Xcode projects.",
        subcommands: [
            Increment.self
        ]
    )
}
