//
//  ReportMateInteractor.swift
//  SniffMeet
//
//  Created by 배현진 on 2/6/25.
//

protocol ReportMateInteractable: AnyObject {
    var presenter: ReportMateInteractorOutput? { get set }
    func fetchMateInfo()
    func requestProfileImage(imageName: String?)
}

final class ReportMateInteractor: ReportMateInteractable {
    private var mate: Mate
    weak var presenter: ReportMateInteractorOutput?
    private let requestProfileImageUseCase: any RequestProfileImageUseCase

    init(
        mate: Mate,
        presenter: ReportMateInteractorOutput? = nil,
        requestProfileImageUseCase: any RequestProfileImageUseCase
    ) {
        self.mate = mate
        self.presenter = presenter
        self.requestProfileImageUseCase = requestProfileImageUseCase
    }

    func fetchMateInfo() {
        presenter?.didFetchMateInfo(mateInfo: mate)
    }

    func requestProfileImage(imageName: String?) {
        Task { @MainActor in
            let fileName = mate.profileImageURLString ?? ""
            guard let imageData = await requestProfileImageUseCase.execute(fileName: fileName) else { return }
            presenter?.didFetchProfileImage(data: imageData)
        }
    }
}
