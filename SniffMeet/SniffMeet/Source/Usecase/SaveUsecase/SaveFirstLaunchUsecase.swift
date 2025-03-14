//
//  SaveFirstLaunchUsecase.swift
//  SniffMeet
//
//  Created by sole on 12/1/24.
//

protocol SaveFirstLaunchUsecase {
    func execute() throws
}

struct SaveFirstLaunchUsecaseImpl: SaveFirstLaunchUsecase {
    private let userDefaultsManager: any UserDefaultsManagable

    init(userDefaultsManager: any UserDefaultsManagable) {
        self.userDefaultsManager = userDefaultsManager
    }

    func execute() throws {
        try userDefaultsManager.set(
            value: true,
            forKey: Environment.UserDefaultsKey.isFirstLaunch
        )
    }
}
