//
//  IncrementAction.swift
//  
//
//  Created by Dustyn August on 9/26/24.
//

import ArgumentParser
import Foundation

enum IncrementAction: ExpressibleByArgument, CaseIterable {
    case buildNumber
    case versionNumber(SemanticVersionComponent)

    init?(argument: String) {
        switch argument {
        case .rawValue(for: .buildNumber):
            self = .buildNumber

        case .rawValue(for: .versionNumber(.major)):
            self = .versionNumber(.major)

        case .rawValue(for: .versionNumber(.minor)):
            self = .versionNumber(.minor)

        case .rawValue(for: .versionNumber(.patch)):
            self = .versionNumber(.patch)

        default:
            return nil
        }
    }

    static var allValueStrings: [String]  = IncrementAction.allCases.map(String.rawValue(for:))

    static var allCases: [Self] = [
        .buildNumber,
        .versionNumber(.major),
        .versionNumber(.minor),
        .versionNumber(.patch),
    ]

    var description: String {
        switch self {
        case .buildNumber:
            return "Build Number"

        case .versionNumber(.major):
            return "Major Version Number"

        case .versionNumber(.minor):
            return "Minor Version Number"

        case .versionNumber(.patch):
            return "Patch Version Number"
        }
    }

    var buildConfigurationKey: String {
        switch self {
        case .buildNumber:
            return "CURRENT_PROJECT_VERSION"

        case .versionNumber(.major),
                .versionNumber(.minor),
                .versionNumber(.patch):
            return "MARKETING_VERSION"
        }
    }
}

extension String {
    static func rawValue(
        for action: IncrementAction
    ) -> Self {
        switch action {
        case .buildNumber:
            return "INCREMENT_BUILD_NUMBER"

        case .versionNumber(.major):
            return "INCREMENT_MAJOR_VERSION_NUMBER"

        case .versionNumber(.minor):
            return "INCREMENT_MINOR_VERSION_NUMBER"

        case .versionNumber(.patch):
            return "INCREMENT_PATCH_VERSION_NUMBER"
        }
    }
}
