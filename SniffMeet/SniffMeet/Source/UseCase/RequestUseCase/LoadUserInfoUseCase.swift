//
//  LoadInfoUseCase.swift
//  SniffMeet
//
//  Created by sole on 11/18/24.
//

import Foundation

protocol LoadUserInfoUseCase {
    func execute() throws -> (ProfileInfo, Data?)
}

struct LoadUserProfileUseCaseImpl: LoadUserInfoUseCase {
    private let dataLoadable: (any DataLoadable)
    private let imageManageable: (any FileManagable)

    init(dataLoadable: any DataLoadable, imageManageable: any FileManagable) {
        self.dataLoadable = dataLoadable
        self.imageManageable = imageManageable
    }

    func execute() throws -> (ProfileInfo, Data?) {
        let userInfo = try dataLoadable.loadData(
            forKey: Environment.UserDefaultsKey.dogInfo,
            type: ProfileInfo.self
        )
        let profileImage = try? imageManageable.get(
            forKey: Environment.FileManagerKey.profileImage
        )
        return (userInfo, profileImage)
    }
}
