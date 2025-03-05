//
//  ProfileDropPresenter.swift
//  SniffMeet
//
//  Created by 배현진 on 2/11/25.
//
import Foundation

protocol ProfileDropPresentable: AnyObject {
    var view: (any ProfileDropViewable)? { get set }
    var interactor: (any ProfileDropInteractable)? { get set }
    var router: (any ProfileDropRoutable)? { get set }

    func viewDidLoad()
    func startNearByProfileDrop()
    func startTargetedProfileDrop()
    func showBrowserView()
    func quitProfileDrop()
    func didTapHelp()
    func didCloseTheView()
    func didCloseTheView(with alert: NotificationAlert)
}

protocol ProfileDropInteractorOutput: AnyObject {
    func didConnectNISession()
    func failToConnectNISession()
    func showConnectionState(to state: ConnectionState)
    func receiveProfileData(_ data: DogDTO)
    func updateDeviceInfo()
    func closeBrowserView()
}

final class ProfileDropPresenter: ProfileDropPresentable {
    weak var view: (any ProfileDropViewable)?
    var interactor: (any ProfileDropInteractable)?
    var router: (any ProfileDropRoutable)?

    init(
        view: ProfileDropViewable? = nil,
        interactor: ProfileDropInteractable? = nil,
        router: ProfileDropRoutable? = nil
    ) {
        self.view = view
        self.interactor = interactor
        self.router = router
    }

    func viewDidLoad() {
        checkNISupport()
    }
    func startNearByProfileDrop() {
        interactor?.tryNearByProfileDrop()
    }
    func startTargetedProfileDrop() {
        interactor?.tryNearByProfileDrop()
    }
    func didCloseTheView() {
        guard let view else { return }
        router?.dismissView(view: view)
    }
    func showBrowserView() {
        if let view = self.view,
           let browserViewController = interactor?.mcBrowserViewController() as? AnyObject {
            router?.presentMCBrowserView(from: view, to: browserViewController)
        }
    }
    func closeBrowserView() {
        if let view = self.view,
           let browserViewController = interactor?.mcBrowserViewController() as? AnyObject {
            router?.dismissMCBrowserView(view: browserViewController)
        }
    }
    func quitProfileDrop() {
        interactor?.quitProfileDrop()
    }
    func didTapHelp() {
        guard let view else { return }
        router?.showHelpView(profileDropView: view)
    }
    private func checkNISupport() {
        interactor?.checkNISupport()
    }
    func didCloseTheView(with alert: NotificationAlert) {
        guard let view else { return }
        router?.dismissView(view: view, with: alert)
    }
}

extension ProfileDropPresenter: ProfileDropInteractorOutput {
    func didConnectNISession() {
        view?.changeState(to: .successNISession)
    }
    func showConnectionState(to state: ConnectionState) {
        view?.changeState(to: state)
    }
    func failToConnectNISession() {
        view?.changeState(to: .failure)
    }
    func receiveProfileData(_ data: DogDTO) {
        guard let view else { return }
        router?.showMateRequestView(profileDropView: view, data: data)
    }
    func updateDeviceInfo() {
        view?.changeNotSupportedNI()
    }
}
