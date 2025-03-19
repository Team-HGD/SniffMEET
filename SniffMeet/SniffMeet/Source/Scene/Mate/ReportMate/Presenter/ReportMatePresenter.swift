//
//  ReportMatePresenter.swift
//  SniffMeet
//
//  Created by 배현진 on 2/6/25.
//
import Combine
import Foundation

protocol ReportMatePresentable: AnyObject {
    var view: (any ReportMateViewable)? { get set }
    var interactor: (any ReportMateInteractable)? { get set }
    var router: (any ReportMateRoutable)? { get set }
    var output: any ReportMatePresenterOutput { get }

    func viewDidLoad()
    func didTapSelectReportView()
    func requestReport(option: String, message: String)
}

protocol ReportMateInteractorOutput: AnyObject {
    func didFetchMateInfo(mateInfo: Mate?)
    func didFetchProfileImage(data: Data?)
    func updateSelectedReportOption(_ option: String)
    func didCloseTheView()
}

protocol ReportMatePresenterOutput {
    var mateInfo: PassthroughSubject<Mate?, Never> { get }
    var profileImageData: PassthroughSubject<Data?, Never> { get }
    var reportOption: PassthroughSubject<String, Never> { get }
}

struct DefaultReportMatePresenterOutput: ReportMatePresenterOutput {
    var profileImageData: PassthroughSubject<Data?, Never>
    var mateInfo: PassthroughSubject<Mate?, Never>
    var reportOption: PassthroughSubject<String, Never>
}

final class ReportMatePresenter: ReportMatePresentable {
    weak var view: (any ReportMateViewable)?
    var interactor: (any ReportMateInteractable)?
    var router: (any ReportMateRoutable)?
    var output: any ReportMatePresenterOutput
    var cancellables = Set<AnyCancellable>()

    init(
        view: ReportMateViewable? = nil,
        interactor: ReportMateInteractable? = nil,
        router: ReportMateRoutable? = nil,
        output: ReportMatePresenterOutput = DefaultReportMatePresenterOutput(
            profileImageData: PassthroughSubject<Data?, Never>(),
            mateInfo: PassthroughSubject<Mate?, Never>(),
            reportOption: PassthroughSubject<String, Never>()
        )
    ) {
        self.view = view
        self.interactor = interactor
        self.router = router
        self.output = output
    }
    
    func viewDidLoad() {
        interactor?.fetchMateInfo()
    }
    func didTapSelectReportView() {
        guard let view else { return }
        router?.showSelectReportView(reportMateView: view, matePresenter: self)
    }
    func requestReport(option: String, message: String) {
        interactor?.sendReportRequest(option: option, message: message)
    }
}

extension ReportMatePresenter: ReportMateInteractorOutput {
    func didFetchMateInfo(mateInfo: Mate?) {
        output.mateInfo.send(mateInfo)
        if let profileImageName = mateInfo?.profileImageName {
            interactor?.requestProfileImage(imageName: profileImageName)
        }
    }
    func didFetchProfileImage(data: Data?) {
        output.profileImageData.send(data)
    }
    func updateSelectedReportOption(_ option: String) {
        output.reportOption.send(option)
    }
    func didCloseTheView() {
        guard let view else { return }
        router?.dismissView(view: view)
    }
}

