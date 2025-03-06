//
//  HomePresenter.swift
//  SniffMeet
//
//  Created by sole on 11/18/24.
//

import Combine
import UIKit

protocol HomePresentable: AnyObject {
    var view: (any HomeViewable)? { get set }
    var router: (any HomeRoutable)? { get set }
    var interactor: (any HomeInteractable)? { get set }
    var output: (any HomePresenterOutput) { get }

    func viewDidLoad()
    func notificationBarButtonDidTap()
    func didTapEditButton(userInfo: ProfileInfo)
    func didTapRequestWalkButton()
}

final class HomePresenter: HomePresentable {
    weak var view: (any HomeViewable)?
    var router: (any HomeRoutable)?
    var interactor: (any HomeInteractable)?
    var output: HomePresenterOutput

    init(
        view: (any HomeViewable)? = nil,
        router: (any HomeRoutable)? = nil,
        interactor: (any HomeInteractable)? = nil,
        output: HomePresenterOutput = DefaultHomePresenterOutput(
            profileInfo: CurrentValueSubject<ProfileInfo, Never>(ProfileInfo.example),
            profileImage: CurrentValueSubject<Data?, Never>(nil)
        )
    ) {
        self.view = view
        self.router = router
        self.interactor = interactor
        self.output = output
    }

    func viewDidLoad() {
        interactor?.saveDeviceToken()
        do {
            if let (info, imageData) = try interactor?.loadInfo() {
                output.profileInfo.send(info)
                output.profileImage.send(imageData)
            }
        } catch {
            SNMLogger.error("이미지 실패?: \(error.localizedDescription)")
            let placeHolderInfo: ProfileInfo = ProfileInfo.example
            output.profileInfo.send(placeHolderInfo)
        }
    }

    func notificationBarButtonDidTap() {
        guard let view else { return }
        router?.showNotificationView(homeView: view)
    }

    func didTapEditButton(userInfo: ProfileInfo) {
        guard let view else { return }
        router?.showProfileEditView(homeView: view, userInfo: userInfo)
    }

    func didTapRequestWalkButton() {
        guard let view else { return }
        router?.transitionToMateListView(homeView: view)
    }
}

// MARK: - HomePresenterOutput

protocol HomePresenterOutput {
    var profileInfo: CurrentValueSubject<ProfileInfo, Never> { get }
    var profileImage: CurrentValueSubject<Data?, Never> { get }
}

struct DefaultHomePresenterOutput: HomePresenterOutput {
    var profileInfo: CurrentValueSubject<ProfileInfo, Never>
    var profileImage: CurrentValueSubject<Data?, Never>
}
