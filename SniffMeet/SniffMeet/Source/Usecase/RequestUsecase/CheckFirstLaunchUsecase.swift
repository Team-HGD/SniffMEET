//
//  CheckFirstLaunchUsecase.swift
//  SniffMeet
//
//  Created by sole on 12/1/24.
//

protocol CheckFirstLaunchUsecase {
    func execute() -> Bool
}

struct CheckFirstLaunchUsecaseImpl: CheckFirstLaunchUsecase {
    private let userDefaultsManager: any UserDefaultsManagable

    init(userDefaultsManager: any UserDefaultsManagable) {
        self.userDefaultsManager = userDefaultsManager
    }

    func execute() -> Bool {
        let isFirstLaunch = try? userDefaultsManager.get(
            forKey: Environment.UserDefaultsKey.isFirstLaunch,
            type: Bool.self
        )
        return isFirstLaunch == nil
    }
}
