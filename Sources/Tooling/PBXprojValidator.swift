//
//  PBXprojValidator.swift
//  
//
//  Created by Dustyn August on 9/25/24.
//

import ArgumentParser
import Foundation

enum PBXProjValidator {
    // Combine all validations into one function
    static func validatePBXproj(
        at filePath: String
    ) throws -> String {
        try validateFileExists(at: filePath)
        try validateFileExtension(for: filePath)
        try validateFileIsReadable(at: filePath)
        try validateFileNotEmpty(at: filePath)
        try validateFileCanBeParsed(at: filePath)
        try validateIsFile(at: filePath)
        return try fileString(at: filePath)
    }
    
    static func validate(
        target: String
    ) throws {
        guard
            !target.isEmpty
        else {
            throw ValidationError("Target must be specified.")
        }
    }
    
    static func validate(configurations: [String]) throws {
        guard !configurations.isEmpty else {
            throw ValidationError("At least one configuration must be specified.")
        }
    }
}

private extension PBXProjValidator {
    private static func validateFileCanBeParsed(
        at filePath: String
    ) throws {
        let content = try String(contentsOfFile: filePath, encoding: .utf8)

        guard
            content.contains("PBXNativeTarget")
        else {
            throw ValidationError("The file at \(filePath) does not appear to be a valid .pbxproj file.")
        }
    }

    private static func validateFileExists(
        at filePath: String
    ) throws {
        let fileManager = FileManager.default

        guard
            fileManager.fileExists(atPath: filePath)
        else {
            throw ValidationError("The file at \(filePath) does not exist.")
        }
    }

    private static func validateFileExtension(
        for filePath: String
    ) throws {
        let fileExtension = (filePath as NSString).pathExtension

        guard
            fileExtension == "pbxproj"
        else {
            throw ValidationError("The file at \(filePath) is not a .pbxproj file.")
        }
    }

    private static func validateFileIsReadable(
        at filePath: String
    ) throws {
        let fileManager = FileManager.default

        guard
            fileManager.isReadableFile(atPath: filePath)
        else {
            throw ValidationError("The file at \(filePath) is not readable. Please check file permissions.")
        }
    }

    private static func validateFileNotEmpty(
        at filePath: String
    ) throws {
        let fileManager = FileManager.default
        let attributes = try fileManager.attributesOfItem(atPath: filePath)

        if let fileSize = attributes[.size] as? Int,
           fileSize == 0 {
            throw ValidationError("The file at \(filePath) is empty.")
        }
    }

    private static func validateIsFile(
        at filePath: String
    ) throws {
        var isDirectory: ObjCBool = false
        let fileManager = FileManager.default

        guard
            fileManager.fileExists(atPath: filePath, isDirectory: &isDirectory),
            !isDirectory.boolValue
        else {
            throw ValidationError("The path \(filePath) is a directory, not a file.")
        }
    }

    private static func validatePathResolution(
        for filePath: String
    ) throws -> String {
        let fileManager = FileManager.default
        let resolvedPath = (filePath as NSString).expandingTildeInPath

        guard
            fileManager.fileExists(atPath: resolvedPath)
        else {
            throw ValidationError("The path \(resolvedPath) does not exist.")
        }

        return resolvedPath
    }

    private static func fileString(
        at filePath: String
    ) throws -> String{
        let fileManager = FileManager.default

        guard
            let data = fileManager.contents(atPath: filePath),
            let fileString =  String(data: data, encoding: .utf8),
            !fileString.isEmpty
        else {
            throw ValidationError("The file at \(filePath) cannot be converted into a string")
        }

        return fileString
    }
}
