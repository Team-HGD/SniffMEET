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
    private let requestProfileImageUsecase: any RequestProfileImageUsecase
    private let requestReportUsecase: any RequestReportUsecase

    init(
        mate: Mate,
        presenter: ReportMateInteractorOutput? = nil,
        requestProfileImageUsecase: any RequestProfileImageUsecase,
        requestReportUsecase: any RequestReportUsecase
    ) {
        self.mate = mate
        self.presenter = presenter
        self.requestProfileImageUsecase = requestProfileImageUsecase
        self.requestReportUsecase = requestReportUsecase
    }

    func fetchMateInfo() {
        presenter?.didFetchMateInfo(mateInfo: mate)
    }
    func requestProfileImage(imageName: String?) {
        Task {
            let fileName = mate.profileImageURLString ?? ""
            guard let imageData = await requestProfileImageUsecase.execute(fileName: fileName) else { return }
            presenter?.didFetchProfileImage(data: imageData)
        }
    }
    func sendReportRequest(option: String, message: String) {
        guard let id = try? SupabaseSessionManager.shared.userID.get() else { return }
        let report = Report(reporterID: id,
                            reportedID: mate.userID,
                            option: option,
                            message: message)
        Task {
            do {
                try await requestReportUsecase.execute(report: report)
                presenter?.didCloseTheView()
            } catch {
                SNMLogger.error("RequesrReportUsecase Error: \(error.localizedDescription)")
            }
        }
    }
}
