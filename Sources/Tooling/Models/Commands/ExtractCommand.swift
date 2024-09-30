//
//  ExtractCommand.swift
//  
//
//  Created by Dustyn August on 9/26/24.
//

import Foundation

enum ExtractCommand {
    case buildConfiguration(for: String, with: String)
    case buildConfigurationID(for: String)
    case buildConfigurationList(with: String)
    case buildConfigurationListID(for: String)
    case incrementValue(with: String)
    case pbxproj(section: PBXprojSection)
    case targetSection(for: String)

    var rawValue: String {
        switch self {
        case let .buildConfiguration(for: configuration, with: id):
            return "sed -n '/^[[:blank:]]*\(id) \\/\\* \(configuration) \\*\\/ = {/,/};/p'"

        case let .buildConfigurationID(for: configuration):
            return "sed -E -n '/\\/\\* \(configuration) \\*\\// s/(.*)\\/\\* \(configuration) \\*\\/.*/\\1/p'"
            
        case let .buildConfigurationList(with: id):
            return "sed -E -n '/^[[:blank:]]*\(id) /,/^[[:blank:]]*};/p'"

        case let .buildConfigurationListID(for: target):
            return "sed -n -e '/\\/\\* \(target) \\*\\//,/};/ s/.*buildConfigurationList = \\([A-Z0-9]*\\).*/\\1/p'"

        case let .incrementValue(with: key):
            return "sed -n 's/.*\(key) *= *\\([^;]*\\);.*/\\1/p'"

        case let .pbxproj(section):
            return "sed -E -n '/\\* Begin \(section.rawValue) section \\*/,/\\* End \(section.rawValue) section \\*/p'"

        case let .targetSection(for: target):
            return "sed -E -n '/\\/\\* \(target) \\*\\//,/^\\t\\t};/p'"
        }
    }
}
