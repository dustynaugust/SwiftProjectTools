//
//  SemanticVersionNumber.swift
//  
//
//  Created by Dustyn August on 9/26/24.
//

import Foundation

struct SemanticVersionNumber {
    let major: Int
    let minor: Int
    let patch: Int

    init?(
        from string: String
    ) {
        let components = string
            .components(separatedBy: ".")
            .compactMap(Int.init)

        guard
            components.count == 3
        else {
            return nil
        }

        self.major = components[0]
        self.minor = components[1]
        self.patch = components[2]
    }
}
