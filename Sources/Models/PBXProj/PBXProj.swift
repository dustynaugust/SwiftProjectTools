//
//  PBXProj.swift
//  PBXProjTool
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
        from project: ProjectOptions,
        using runner: CommandRunner
    ) throws {
        let contents = try PBXProjValidator.validatePBXproj(at: project.pbxprojFilePath)
        try PBXProjValidator.validate(target: project.target)
        try PBXProjValidator.validate(configurations: project.configurations)

        let pbxNativeTargetSection = try runner.extract(.pbxproj(.PBXNativeTarget), from: contents)
        let targetSection = try runner.extract(.targetSection(for: project.target), from: pbxNativeTargetSection)
        let buildConfigurationListID = try runner.extract(.buildConfigurationListID(for: project.target), from: targetSection)
        let xcConfigurationListSection = try runner.extract(.pbxproj(.XCConfigurationList), from: contents)
        let buildConfigurationList = try runner.extract(.buildConfigurationList(with: buildConfigurationListID), from: xcConfigurationListSection)

        var configs: [String: BuildConfiguration] = [:]

        for configuration in project.configurations {
            let id = try runner.extract(.buildConfigurationID(for: configuration), from: buildConfigurationList)
            let config = try runner.extract(.buildConfiguration(for: configuration, with: id), from: contents)
            configs[configuration] = BuildConfiguration(id: id, value: config)
        }

        self.init(
            filePath: project.pbxprojFilePath,
            contents: contents,
            targetSection: targetSection,
            buildConfigurationList: buildConfigurationList,
            configurations: configs
        )
    }
}
