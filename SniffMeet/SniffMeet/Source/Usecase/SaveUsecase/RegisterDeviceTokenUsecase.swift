//
//  RegisterDeviceTokenUsecase.swift
//  SniffMeet
//
//  Created by sole on 11/25/24.
//

import Foundation

protocol RegisterDeviceTokenUsecase {
    func execute(deviceToken: Data) throws
}

struct RegisterDeviceTokenUsecaseImpl: RegisterDeviceTokenUsecase {
    private let keychainManager: any TokenManagable

    init(keychainManager: any TokenManagable) {
        self.keychainManager = keychainManager
    }

    func execute(deviceToken: Data) throws {
        let deviceTokenString = deviceToken.reduce("") { $0 + String(format: "%02X", $1) }
        try keychainManager.set(
            value: deviceTokenString,
            forKey: Environment.KeychainKey.deviceToken
        )
    }
}
