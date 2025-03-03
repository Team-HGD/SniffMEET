//
//  LoadInfoUseCase.swift
//  SniffMeet
//
//  Created by sole on 11/18/24.
//

import Foundation

protocol LoadUserInfoUseCase {
    func execute() throws -> ProfileInfo
}

struct LoadUserInfoUseCaseImpl: LoadUserInfoUseCase {
    private let dataLoadable: any DataLoadable

    init(dataLoadable: any DataLoadable) {
        self.dataLoadable = dataLoadable
    }

    func execute() throws -> ProfileInfo {
        let profileInfo = try dataLoadable.loadData(
            forKey: Environment.UserDefaultsKey.dogInfo,
            type: ProfileInfo.self
        )
        return profileInfo
    }
}
