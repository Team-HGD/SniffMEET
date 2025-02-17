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
    var output: any ProfileDropPresenterOutput { get }

    func viewDidLoad()
    func startNearByProfileDrop()
    func startTargetedProfileDrop()
    func showBrowserView()
    func quitProfileDrop()
    func didTapHelp()
}

protocol ProfileDropInteractorOutput: AnyObject {
    func didCloseTheView()
    func didConnectNISession()
    func failToConnectNISession()
    func receiveProfileData(_ data: DogDTO)
    func updateDeviceInfo()
}

protocol ProfileDropPresenterOutput {
}

struct DefaultProfileDropPresenterOutput: ProfileDropPresenterOutput {
}

final class ProfileDropPresenter: ProfileDropPresentable {
    weak var view: (any ProfileDropViewable)?
    var interactor: (any ProfileDropInteractable)?
    var router: (any ProfileDropRoutable)?
    var output: any ProfileDropPresenterOutput

    init(
        view: ProfileDropViewable? = nil,
        interactor: ProfileDropInteractable? = nil,
        router: ProfileDropRoutable? = nil,
        output: ProfileDropPresenterOutput = DefaultProfileDropPresenterOutput()
    ) {
        self.view = view
        self.interactor = interactor
        self.router = router
        self.output = output
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
    func showBrowserView() {
        if let view = self.view,
           let browserViewController = interactor?.mcBrowserViewController() as? AnyObject {
            router?.presentMCBrowserView(from: view, to: browserViewController)
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
}

extension ProfileDropPresenter: ProfileDropInteractorOutput {
    func didCloseTheView() {
    }
    func didConnectNISession() {
        view?.changeState(to: .success)
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
