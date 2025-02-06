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
    func sendReportRequest(option: String, message: String)
}

final class ReportMateInteractor: ReportMateInteractable {
    private var mate: Mate
    weak var presenter: ReportMateInteractorOutput?
    private let requestProfileImageUseCase: any RequestProfileImageUseCase
    private let requestReportUseCase: any RequestReportUseCase

    init(
        mate: Mate,
        presenter: ReportMateInteractorOutput? = nil,
        requestProfileImageUseCase: any RequestProfileImageUseCase,
        requestReportUseCase: any RequestReportUseCase
    ) {
        self.mate = mate
        self.presenter = presenter
        self.requestProfileImageUseCase = requestProfileImageUseCase
        self.requestReportUseCase = requestReportUseCase
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
    func sendReportRequest(option: String, message: String) {
        guard let id = SessionManager.shared.session?.user?.userID else { return }
        let report = Report(reporterID: id,
                            reportedID: mate.userID,
                            option: option,
                            message: message)
        Task {
            do {
                try await requestReportUseCase.execute(report: report)
            } catch {
                SNMLogger.error("RequesrReportUseCase Error: \(error.localizedDescription)")
            }
        }
        presenter?.didCloseTheView()
    }
}
