//
//  LoadInfoUsecase.swift
//  SniffMeet
//
//  Created by sole on 11/18/24.
//

import Foundation

protocol LoadUserInfoUsecase {
    func execute() throws -> ProfileInfo
}

struct LoadUserInfoUsecaseImpl: LoadUserInfoUsecase {
    private let dataLoadable: any DataLoadable

    init(dataLoadable: any DataLoadable) {
        self.dataLoadable = dataLoadable
    }

    func execute() throws -> ProfileInfo {
        let profileInfo = try dataLoadable.loadData(
            forKey: Environment.UserDefaultsKey.profileInfo,
            type: ProfileInfo.self
        )
        return profileInfo
    }
}
