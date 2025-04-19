//
//  UpdateCommand.swift
//  
//
//  Created by Dustyn August on 9/26/24.
//

import Foundation

struct UpdateCommand: Command {
    let value: String
}

extension UpdateCommand {
    static func pbxproj(
        id: String,
        key: PBXProj.BuildSetting,
        newValue: String,
        filePath: String
    ) -> UpdateCommand {
        UpdateCommand(value: "sed -i '' -E \"/^[[:blank:]]*\(id)[[:blank:]]*.*=/,/^[[:blank:]]*};[[:blank:]]*$/ s/([[:blank:]]*\(key.rawValue)[[:blank:]]*=[[:blank:]]*)[^;]*;/\\1\(newValue);/\" \(filePath)")
    }
}
