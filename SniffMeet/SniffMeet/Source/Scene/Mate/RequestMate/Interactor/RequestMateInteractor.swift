//
//  RequestMateInteractor.swift
//  SniffMeet
//
//  Created by 배현진 on 11/20/24.
//

import Foundation

protocol RequestMateInteractable: AnyObject {
    var presenter: (any RequestMateInteractorOutput)? { get set }

    func fetchDogProfileImage(fileName: String) async throws
    func saveMateInfo(id: UUID) async
}

final class RequestMateInteractor: RequestMateInteractable {
    weak var presenter: (any RequestMateInteractorOutput)?
    private let respondMateRequestUseCase: RespondMateRequestUseCase
    private let requestProfileImageUsecase: RequestProfileImageUseCase

    init(
        presenter: (any RequestMateInteractorOutput)? = nil,
        respondMateRequestUseCase: RespondMateRequestUseCase,
        requestProfileImageUsecase: RequestProfileImageUseCase
    ) {
        self.presenter = presenter
        self.respondMateRequestUseCase = respondMateRequestUseCase
        self.requestProfileImageUsecase = requestProfileImageUsecase
    }

    func fetchDogProfileImage(fileName: String) async throws {
        let imageData = try await requestProfileImageUsecase.execute(fileName: fileName)
        presenter?.showProfileImage(imageData: imageData)
    }
    func saveMateInfo(id: UUID) async {
        await respondMateRequestUseCase.execute(mateId: id, isAccepted: true)
    }
}
