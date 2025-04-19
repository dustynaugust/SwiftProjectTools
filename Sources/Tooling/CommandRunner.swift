//
//  CommandRunner.swift
//  PBXProjTool
//
//  Created by Dustyn August on 4/19/25.
//

import Foundation

struct CommandRunner {
    let loggingEnabled: Bool
    
    func extract(
        _ command: ExtractCommand,
        from: String
    ) throws -> String {
        try run(command, input: from)
    }
    
    func update(
        _ command: UpdateCommand
    ) throws {
        let _ = try run(command, input: nil)
    }
}

private extension CommandRunner {
    private func run(
        _ command: some Command,
        input: String? = nil
    ) throws -> String {
        let task = Process()
        let pipe = Pipe()

        task.standardOutput = pipe
        task.standardError = pipe
        task.arguments = ["-c", command.value]
        task.executableURL = URL(fileURLWithPath: "/bin/zsh")
        
        log(command: command.value)
        
        if let input {
            let inputPipe = Pipe()
            inputPipe.fileHandleForWriting.write(input.data(using: .utf8)!)
            inputPipe.fileHandleForWriting.closeFile()
            task.standardInput = inputPipe
        }

        try task.run()

        guard
            let data = try pipe.fileHandleForReading.readToEnd()
        else {
            log("empty data returned from command: \(string(for: command.value))")
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

    func output(_ message: String) {
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
