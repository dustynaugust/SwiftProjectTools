//
//  UpdateCommand.swift
//  
//
//  Created by Dustyn August on 9/26/24.
//

import Foundation

enum UpdateCommand {
    case pbxproj(id: String,
                 key: String,
                 newValue: String,
                 filePath: String)

    var rawValue: String {
        switch self {
        case let .pbxproj(id, key, newValue, filePath):
            return "sed -i '' -E \"/^[[:blank:]]*\(id)[[:blank:]]*.*=/,/^[[:blank:]]*};[[:blank:]]*$/ s/([[:blank:]]*\(key)[[:blank:]]*=[[:blank:]]*)[^;]*;/\\1\(newValue);/\" \(filePath)"
        }
    }

}
