//
//  WalkLogListInteractor.swift
//  SniffMeet
//
//  Created by sole on 2/27/25.
//

import Foundation

protocol WalkLogListInteractable: AnyObject {
    var presenter: (any WalkLogListPresentable)? { get }

    func fetchUserInfo() throws -> (name: String, profileImageData: Data?)
    func fetchWalkLogList() throws -> [WalkLog]
}

final class WalkLogListInteractor: WalkLogListInteractable {
    weak var presenter: (any WalkLogListPresentable)?
    private let loadUserInfoUsecase: any LoadUserInfoUsecase
    private let loadUserProfileImageUsecase: any LoadUserProfileImageUsecase
    private let requestWalkLogListUsecase: any RequestWalkLogListUsecase

    init(
        presenter: (any WalkLogListPresentable)? = nil,
        loadUserInfoUsecase: any LoadUserInfoUsecase,
        loadUserProfileImageUsecase: any LoadUserProfileImageUsecase,
        requestWalkLogListUsecase: any RequestWalkLogListUsecase
    ) {
        self.presenter = presenter
        self.loadUserInfoUsecase = loadUserInfoUsecase
        self.loadUserProfileImageUsecase = loadUserProfileImageUsecase
        self.requestWalkLogListUsecase = requestWalkLogListUsecase
    }

    func fetchUserInfo() throws -> (name: String, profileImageData: Data?) {
        let userInfo = try loadUserInfoUsecase.execute()
        let profileImageData = try loadUserProfileImageUsecase.execute()
        return (userInfo.name, profileImageData)
    }
    func fetchWalkLogList() throws -> [WalkLog] {
        try requestWalkLogListUsecase.execute()
    }
}
