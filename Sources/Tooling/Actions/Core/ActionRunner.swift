//
//  ActionRunner.swift
//  SwiftProjectTools
//
//  Created by Dustyn August on 4/19/25.
//

import Foundation

struct ActionRunner {
    let loggingEnabled: Bool
    
    func extract(
        _ action: Extract,
        from: String
    ) throws -> String {
        try run(action, input: from)
    }
    
    func update(
        _ action: Update
    ) throws {
        let _ = try run(action, input: nil)
    }
}

private extension ActionRunner {
    private func run(
        _ action: some Action,
        input: String? = nil
    ) throws -> String {
        let task = Process()
        let pipe = Pipe()

        task.standardOutput = pipe
        task.standardError = pipe
        task.arguments = ["-c", action.value]
        task.executableURL = URL(fileURLWithPath: "/bin/zsh")
        
        if let input,
            let inputData = input.data(using: .utf8) {
            let inputPipe = Pipe()
            inputPipe.fileHandleForWriting.writeabilityHandler = { handle in
                try? handle.write(contentsOf: inputData)
                handle.closeFile()
            }

            task.standardInput = inputPipe
        }

        try task.run()

        let data = try pipe.fileHandleForReading.readToEnd()
        
        guard
            let data
        else {
            return ""
        }
        
        guard
            let output = String(data: data, encoding: .utf8)
        else {
            let error = SwiftProjectToolsError.parseActionOutputError
            throw error
        }

        return output.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private func output(
        _ message: String
    ) {
        print(message)
    }

    private func log(
        _ message: String
    ) {
        guard loggingEnabled else { return }

        output(message)
    }

    private func log(
        action: String
    ) {
        guard loggingEnabled else { return }

        output("ACTION: ----------\n\(string(for: action))\n----------")
    }

    private func log(
        input: String
    ) {
        guard loggingEnabled else { return }

        output("INPUT: ----------\n\(input)\n----------")
    }

    private func log(
        result: String
    ) {
        guard loggingEnabled else { return }

        output("RESULT: ----------\n\(result)\n----------")
    }

    private func output(
        _ error: SwiftProjectToolsError,
        function: String = #function
    ) {
        output("ERROR in \(function)")
        
        let errorMessage: String
        if let errorDescription = error.errorDescription {
            errorMessage = errorDescription
            
        } else {
            errorMessage = "No description available."
        }
        
        output("Error: \(errorMessage)")
    }

    private func string(
        for action: String
    ) -> String {
        if action.isEmpty {
            return "\"\""
        } else {

            return action
        }
    }
}
