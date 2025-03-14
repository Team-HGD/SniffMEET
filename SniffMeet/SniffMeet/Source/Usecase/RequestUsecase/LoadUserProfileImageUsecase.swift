//
//  LoadInfoUsecase.swift
//  SniffMeet
//
//  Created by sole on 11/18/24.
//

import Foundation

protocol LoadUserProfileImageUsecase {
    func execute() throws -> Data?
}

struct LoadUserProfileImageImpl: LoadUserProfileImageUsecase {
    private let imageManageable: any FileManagable

    init(imageManageable: any FileManagable) {
        self.imageManageable = imageManageable
    }

    func execute() throws -> Data? {
        let profileImage = try? imageManageable.get(
            forKey: Environment.FileManagerKey.profileImage
        )
        return profileImage
    }
}
