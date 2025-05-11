//
//  Extract.swift
//  
//
//  Created by Dustyn August on 9/26/24.
//

import Foundation

struct Extract: Action {
    var value: String
}

extension Extract {
    static func buildConfiguration(
        for configuration: String,
        with id: String
    ) -> Extract {
        Extract(
            value: "sed -n '/^[[:blank:]]*\(id) \\/\\* \(configuration) \\*\\/ = {/,/};/p'"
        )
    }
    
    static func buildConfigurationID(
        for configuration: String
    ) -> Extract {
        Extract(
            value: "sed -E -n '/\\/\\* \(configuration) \\*\\// s/(.*)\\/\\* \(configuration) \\*\\/.*/\\1/p'"
        )
    }
    
    static func buildConfigurationList(
        with id: String
    ) -> Extract {
        Extract(
            value: "sed -E -n '/^[[:blank:]]*\(id) /,/^[[:blank:]]*};/p'"
        )
    }
    
    static func buildConfigurationListID(
        for target: String
    ) -> Extract {
        Extract(
            value: "sed -n -e '/\\/\\* \(target) \\*\\//,/};/ s/.*buildConfigurationList = \\([A-Z0-9]*\\).*/\\1/p'"
        )
    }
    
    static func pbxproj(
        _ buildSetting: PBXProj.BuildSetting
    ) -> Extract {
        Extract(
            value: "sed -n 's/.*\(buildSetting.rawValue) *= *\\([^;]*\\);.*/\\1/p'"
        )
    }
    
    static func pbxproj(
        _ section: PBXProj.Section
    ) -> Extract {
        Extract(
            value: "sed -E -n '/\\* Begin \(section.rawValue) section \\*/,/\\* End \(section.rawValue) section \\*/p'"
        )
    }
    
    static func targetSection(
        for target: String
    ) -> Extract {
        Extract(
            value: "sed -E -n '/\\/\\* \(target) \\*\\//,/^\\t\\t};/p'"
        )
    }
}
