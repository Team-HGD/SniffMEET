//
//  ProcessedWalkInteractor.swift
//  SniffMeet
//
//  Created by sole on 12/4/24.
//

import Foundation

protocol ProcessedWalkInteractable: AnyObject {
    var presenter: (any ProcessedWalkInteractorOutput)? { get set }
    func fetchSenderInfo(userID: UUID)
    func fetchProfileImage(urlString: String)
    func convertLocationToText(latitude: Double, longtitude: Double)
}

final class ProcessedWalkInteractor: ProcessedWalkInteractable {
    weak var presenter: (any ProcessedWalkInteractorOutput)?
    private let convertLocationToTextUsecase: any ConvertLocationToTextUsecase
    private let requestUserInfoUsecase: RequestMateInfoUsecase
    private let requestProfileImageUsecase: RequestProfileImageUsecase

    init(
        presenter: (any ProcessedWalkInteractorOutput)? = nil,
        convertLocationToTextUsecase: any ConvertLocationToTextUsecase,
        requestUserInfoUsecase: any RequestMateInfoUsecase,
        requestProfileImageUsecase: any RequestProfileImageUsecase
    ) {
        self.presenter = presenter
        self.convertLocationToTextUsecase = convertLocationToTextUsecase
        self.requestUserInfoUsecase = requestUserInfoUsecase
        self.requestProfileImageUsecase = requestProfileImageUsecase
    }

    func fetchSenderInfo(userID: UUID) {
        Task {
            do {
                guard let senderInfo = try await requestUserInfoUsecase.execute(
                    mateID: userID
                ) else {
                    presenter?.didFailToFetchWalkRequest(
                        error: SupabaseAuthError.userNotFound
                    )
                    return
                }
                presenter?.didFetchUserInfo(senderInfo: senderInfo)
                guard let profileImageURL = senderInfo.profileImageURL else { return }
                fetchProfileImage(urlString: profileImageURL)
            } catch {
                presenter?.didFailToFetchWalkRequest(error: error)
            }
        }
    }
    func fetchProfileImage(urlString: String) {
        Task { [weak self] in
            let imageData = try await self?.requestProfileImageUsecase.execute(fileName: urlString)
            self?.presenter?.didFetchProfileImage(with: imageData)
        }
    }
    func convertLocationToText(latitude: Double, longtitude: Double) {
        Task {
            let locationText: String? = await convertLocationToTextUsecase.execute(
                latitude: latitude, longtitude: longtitude
            )
            presenter?.didConvertLocationToText(with: locationText)
        }
    }
}
