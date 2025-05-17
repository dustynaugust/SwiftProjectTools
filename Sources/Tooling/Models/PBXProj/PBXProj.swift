//
//  PBXProj.swift
//  SwiftProjectTools
//
//  Created by Dustyn August on 4/19/25.
//

struct PBXProj {
    let filePath: String
    let contents: String
    let targetSection: String
    let buildConfigurationList: String
    let configurations: [String: BuildConfiguration]
}

extension PBXProj {
    init(
        from sharedOptions: SharedOptions,
        using runner: ActionRunner
    ) throws {
        let contents = try PBXProjValidator.validatePBXproj(at: sharedOptions.pbxprojFilePath)
        try PBXProjValidator.validate(target: sharedOptions.target)
        try PBXProjValidator.validate(configurations: sharedOptions.configurations)

        let pbxNativeTargetSection = try runner.extract(.pbxproj(.PBXNativeTarget), from: contents)
        let targetSection = try runner.extract(.targetSection(for: sharedOptions.target), from: pbxNativeTargetSection)
        let buildConfigurationListID = try runner.extract(.buildConfigurationListID(for: sharedOptions.target), from: targetSection)
        let xcConfigurationListSection = try runner.extract(.pbxproj(.XCConfigurationList), from: contents)
        let buildConfigurationList = try runner.extract(.buildConfigurationList(with: buildConfigurationListID), from: xcConfigurationListSection)

        var configs: [String: BuildConfiguration] = [:]

        for configuration in sharedOptions.configurations {
            let id = try runner.extract(.buildConfigurationID(for: configuration), from: buildConfigurationList)
            let config = try runner.extract(.buildConfiguration(for: configuration, with: id), from: contents)
            configs[configuration] = BuildConfiguration(id: id, value: config)
        }

        self.init(
            filePath: sharedOptions.pbxprojFilePath,
            contents: contents,
            targetSection: targetSection,
            buildConfigurationList: buildConfigurationList,
            configurations: configs
        )
    }
}
