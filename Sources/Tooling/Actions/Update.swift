//
//  Update.swift
//  
//
//  Created by Dustyn August on 9/26/24.
//

import Foundation

struct Update: Action {
    let value: String
}

extension Update {
    static func pbxproj(
        id: String,
        key: PBXProj.BuildSetting,
        newValue: String,
        filePath: String
    ) -> Update {
        Update(value: "sed -i '' -E \"/^[[:blank:]]*\(id)[[:blank:]]*.*=/,/^[[:blank:]]*};[[:blank:]]*$/ s/([[:blank:]]*\(key.rawValue)[[:blank:]]*=[[:blank:]]*)[^;]*;/\\1\(newValue);/\" \(filePath)")
    }
}
