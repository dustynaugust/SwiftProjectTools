//
//  Command.swift
//  
//
//  Created by Dustyn August on 9/26/24.
//

import Foundation

enum Command {
    case extract(ExtractCommand)
    case update(UpdateCommand)

    var rawValue: String {
        switch self {
        case let .extract(command):
            return command.rawValue

        case let .update(command):
            return command.rawValue
        }
    }
}
