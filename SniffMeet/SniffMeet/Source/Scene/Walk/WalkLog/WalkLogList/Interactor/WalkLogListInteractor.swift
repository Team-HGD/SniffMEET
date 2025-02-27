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
    private let loadUserInfoUsecase: any LoadUserInfoUseCase
    private let requestWalkLogListUsecase: any RequestWalkLogListUseCase

    init(
        presenter: (any WalkLogListPresentable)? = nil,
        loadUserInfoUsecase: any LoadUserInfoUseCase,
        requestWalkLogListUsecase: any RequestWalkLogListUseCase
    ) {
        self.presenter = presenter
        self.loadUserInfoUsecase = loadUserInfoUsecase
        self.requestWalkLogListUsecase = requestWalkLogListUsecase
    }

    func fetchUserInfo() throws -> (name: String, profileImageData: Data?) {
        let userInfo = try loadUserInfoUsecase.execute()
        return (userInfo.name, userInfo.profileImage)
    }
    func fetchWalkLogList() throws -> [WalkLog] {
        try requestWalkLogListUsecase.execute()
    }
}
