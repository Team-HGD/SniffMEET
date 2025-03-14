//
//  HomeInteractor.swift
//  SniffMeet
//
//  Created by sole on 11/18/24.
//

import Foundation

protocol HomeInteractable: AnyObject {
    var presenter: (any HomePresentable)? { get }
    func loadInfo() throws -> (ProfileInfo, Data?)
    func saveDeviceToken()
}

final class HomeInteractor: HomeInteractable {
    weak var presenter: (any HomePresentable)?
    private let loadUserInfoUsecase: any LoadUserInfoUsecase
    private let loadUserProfileImageUsecase: any LoadUserProfileImageUsecase
    private let checkFirstLaunchUsecase: any CheckFirstLaunchUsecase
    private let saveFirstLaunchUsecase: any SaveFirstLaunchUsecase
    private let requestNotificationAuthUsecase: any RequestNotificationAuthUsecase
    private let remoteSaveDeviceTokenUsecase: any RemoteSaveDeviceTokenUsecase

    init(
        presenter: (any HomePresentable)? = nil,
        loadUserInfoUsecase: any LoadUserInfoUsecase,
        loadUserProfileImageUsecase: any LoadUserProfileImageUsecase,
        checkFirstLaunchUsecase: any CheckFirstLaunchUsecase,
        saveFirstLaunchUsecase: any SaveFirstLaunchUsecase,
        requestNotificationAuthUsecase: any RequestNotificationAuthUsecase,
        remoteSaveDeviceTokenUsecase: any RemoteSaveDeviceTokenUsecase
    ) {
        self.presenter = presenter
        self.loadUserInfoUsecase = loadUserInfoUsecase
        self.loadUserProfileImageUsecase = loadUserProfileImageUsecase
        self.checkFirstLaunchUsecase = checkFirstLaunchUsecase
        self.saveFirstLaunchUsecase = saveFirstLaunchUsecase
        self.requestNotificationAuthUsecase = requestNotificationAuthUsecase
        self.remoteSaveDeviceTokenUsecase = remoteSaveDeviceTokenUsecase
    }

    func loadInfo() -> (ProfileInfo, Data?) {
        do {
            let userInfo = try loadUserInfoUsecase.execute()
            let profileImage = try loadUserProfileImageUsecase.execute()
            return (userInfo, profileImage)
        } catch {
            // FIXME: 에러 핸들링 필요
            return (ProfileInfo.example, nil)
        }
    }
    func saveDeviceToken() {
        guard checkFirstLaunchUsecase.execute() else { return }
        Task {
            do {
                try saveFirstLaunchUsecase.execute()
                _ = try await requestNotificationAuthUsecase.execute()
                try await remoteSaveDeviceTokenUsecase.execute()
            } catch {
                SNMLogger.error(error.localizedDescription)
            }
        }
    }
}
