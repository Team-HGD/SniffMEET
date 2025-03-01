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
    private let loadUserInfoUseCase: any LoadUserInfoUseCase
    private let checkFirstLaunchUseCase: any CheckFirstLaunchUseCase
    private let saveFirstLaunchUseCase: any SaveFirstLaunchUseCase
    private let requestNotificationAuthUseCase: any RequestNotificationAuthUseCase
    private let remoteSaveDeviceTokenUseCase: any RemoteSaveDeviceTokenUseCase

    init(
        presenter: (any HomePresentable)? = nil,
        loadUserInfoUseCase: any LoadUserInfoUseCase,
        checkFirstLaunchUseCase: any CheckFirstLaunchUseCase,
        saveFirstLaunchUseCase: any SaveFirstLaunchUseCase,
        requestNotificationAuthUseCase: any RequestNotificationAuthUseCase,
        remoteSaveDeviceTokenUseCase: any RemoteSaveDeviceTokenUseCase
    ) {
        self.presenter = presenter
        self.loadUserInfoUseCase = loadUserInfoUseCase
        self.checkFirstLaunchUseCase = checkFirstLaunchUseCase
        self.saveFirstLaunchUseCase = saveFirstLaunchUseCase
        self.requestNotificationAuthUseCase = requestNotificationAuthUseCase
        self.remoteSaveDeviceTokenUseCase = remoteSaveDeviceTokenUseCase
    }

    func loadInfo() -> (ProfileInfo, Data?) {
        do {
            return try loadUserInfoUseCase.execute()
        } catch {
            // FIXME: 에러 핸들링 필요
            return (ProfileInfo.example, nil)
        }
    }
    func saveDeviceToken() {
        guard checkFirstLaunchUseCase.execute() else { return }
        Task {
            do {
                try saveFirstLaunchUseCase.execute()
                _ = try await requestNotificationAuthUseCase.execute()
                try await remoteSaveDeviceTokenUseCase.execute()
            } catch {
                SNMLogger.error(error.localizedDescription)
            }
        }
    }
}
