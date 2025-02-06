//
//  ReportMatePresenter.swift
//  SniffMeet
//
//  Created by 배현진 on 2/6/25.
//
import Combine
import Foundation

protocol ReportMatePresentable: AnyObject {
    var view: ReportMateViewable? { get set }
    var interactor: ReportMateInteractable? { get set }
    var router: ReportMateRoutable? { get set }
    var output: any ReportMatePresenterOutput { get }

    func viewDidLoad()
    func didTapSelectReportView()
}

protocol ReportMateInteractorOutput: AnyObject {
    func didFetchMateInfo(mateInfo: Mate?)
    func didFetchProfileImage(data: Data?)
}

protocol ReportMatePresenterOutput {
    var mateInfo: PassthroughSubject<Mate?, Never> { get }
    var profileImageData: PassthroughSubject<Data?, Never> { get }
}

struct DefaultReportMatePresenterOutput: ReportMatePresenterOutput {
    var profileImageData: PassthroughSubject<Data?, Never>
    var mateInfo: PassthroughSubject<Mate?, Never>
}

final class ReportMatePresenter: ReportMatePresentable {
    weak var view: ReportMateViewable?
    var interactor: ReportMateInteractable?
    var router: ReportMateRoutable?
    var output: any ReportMatePresenterOutput

    init(
        view: ReportMateViewable? = nil,
        interactor: ReportMateInteractable? = nil,
        router: ReportMateRoutable? = nil,
        output: ReportMatePresenterOutput = DefaultReportMatePresenterOutput(profileImageData: PassthroughSubject<Data?, Never>(), mateInfo: PassthroughSubject<Mate?, Never>()
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
        router?.showSelectReportView(reportMateView: view)
    }
}

extension ReportMatePresenter: ReportMateInteractorOutput {
    func didFetchMateInfo(mateInfo: Mate?) {
        SNMLogger.log("presenter mate: \(String(describing: mateInfo))")
        SNMLogger.log("presenter mate2: \(mateInfo)")
        output.mateInfo.send(mateInfo)
        if let profileImageName = mateInfo?.profileImageURLString {
            interactor?.requestProfileImage(imageName: profileImageName)
        }
    }
    func didFetchProfileImage(data: Data?) {
        output.profileImageData.send(data)
    }
}

