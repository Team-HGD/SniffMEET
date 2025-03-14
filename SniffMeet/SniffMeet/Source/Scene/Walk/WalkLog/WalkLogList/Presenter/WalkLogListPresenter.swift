//
//  WalkLogListPresenter.swift
//  SniffMeet
//
//  Created by sole on 2/27/25.
//

import Combine
import Foundation

protocol WalkLogListPresentable: AnyObject {
    var view: (any WalkLogListViewable)? { get }
    var interactor: (any WalkLogListInteractable)? { get }
    var router: (any WalkLogListRoutable)? { get }
    var output: (any WalkLogListPresenterOutput) { get }

    func viewDidLoad()
    func viewWillAppear()
    func didTapAddWalkLogButton()
}

final class WalkLogListPresenter: WalkLogListPresentable {
    weak var view: (any WalkLogListViewable)?
    var interactor: (any WalkLogListInteractable)?
    var router: (any WalkLogListRoutable)?
    var output: any WalkLogListPresenterOutput

    init(
        view: (any WalkLogListViewable)? = nil,
        interactor: (any WalkLogListInteractable)? = nil,
        router: (any WalkLogListRoutable)? = nil,
        output: any WalkLogListPresenterOutput = DefaultWalkLogListPresenterOutput(
            walkLogList: [],
            name: "후추추",
            profileImageData: nil
        )
    ) {
        self.view = view
        self.interactor = interactor
        self.router = router
        self.output = output
    }

    func viewDidLoad() {
        requestWalkLogList()
    }
    func viewWillAppear() {
        requestWalkLogList()
    }
    func didTapAddWalkLogButton() {
        guard let view else { return }
        router?.showTrackWalkView(view: view)
    }
    private func requestWalkLogList() {
        do {
            let (name, profileImageData) = try interactor?.fetchUserInfo() ?? ("", nil)
            output.name = name
            output.profileImageData = profileImageData
            let walkLogList = try interactor?.fetchWalkLogList()
            output.walkLogList = walkLogList ?? []
        } catch {
            SNMLogger.log(error.localizedDescription)
        }
    }
}

protocol WalkLogListPresenterOutput {
    var walkLogList: [WalkLog] { get set }
    var name: String { get set }
    var profileImageData: Data? { get set }
}

struct DefaultWalkLogListPresenterOutput: WalkLogListPresenterOutput {
    var walkLogList: [WalkLog]
    var name: String
    var profileImageData: Data?
}
