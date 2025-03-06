//
//  ProfileDropRouter.swift
//  SniffMeet
//
//  Created by 배현진 on 2/11/25.
//

import UIKit

protocol ProfileDropRoutable: AnyObject, Routable {
    var presenter: (any ProfileDropPresentable)? { get set }
    func presentMCBrowserView (from profileDropView: any ProfileDropViewable, to mcBrowserView: AnyObject)
    func dismissMCBrowserView (view: AnyObject)
    func dismissView(view: any ProfileDropViewable)
    func dismissView(view: any ProfileDropViewable, with alert: NotificationAlert)
    func showMateRequestView(profileDropView: any ProfileDropViewable, data: DogDTO)
    func showHelpView(profileDropView: any ProfileDropViewable)
}

protocol ProfileDropBuildable {
    static func createProfileDropModule() -> UIViewController
}

final class ProfileDropRouter: ProfileDropRoutable {
    weak var presenter: (any ProfileDropPresentable)?

    func presentMCBrowserView (from profileDropView: any ProfileDropViewable, to mcBrowserView: AnyObject) {
        guard let profileDropView = profileDropView as? UIViewController,
              let mcBrowserViewController = mcBrowserView as? UIViewController
        else { return }
        present(from: profileDropView, with: mcBrowserViewController, animated: true)
    }
    
    func dismissMCBrowserView (view: AnyObject) {
        guard let mcBrowserViewController = view as? UIViewController
        else { return }
        dismiss(from: mcBrowserViewController, animated: true)
    }
    
    func dismissView(view: any ProfileDropViewable) {
        if let view = view as? UIViewController {
            Task { @MainActor in
                pop(from: view, animated: true)
            }
        }
    }
    func dismissView(view: any ProfileDropViewable, with alert: NotificationAlert) {
        guard  let view = view as? UIViewController else { return }
        
        Task { @MainActor in
            view.navigationController?.popViewController(animated: true, completion: {
                NotificationCenter.default.post(
                    name: Environment.NotificationCenterName.sessionExpired,
                    object: alert
                )
            })
        }
    }
    func showMateRequestView(profileDropView: any ProfileDropViewable, data: DogDTO) {
        guard let profileDropView = profileDropView as? UIViewController else { return }
        let requestMateViewController = RequestMateRouter.createRequestMateModule(profile: data)
        let transitionDelegate = ProfileDropTransitionDelegate()
        requestMateViewController.modalPresentationStyle = .fullScreen
        requestMateViewController.transitioningDelegate = transitionDelegate
        HapticManager.instance.playHaptic(type: .shortsHaptic)
        present(from: profileDropView, with: requestMateViewController, animated: true)
    }
    func showHelpView(profileDropView: any ProfileDropViewable) {
        guard let profileDropView = profileDropView as? UIViewController else { return }
        let helpURLString = Environment.URLString.helpPage
        guard let url = URL(string: helpURLString) else { return }
        presentSafari(from: profileDropView, animated: true, url: url)
    }
}

extension ProfileDropRouter: ProfileDropBuildable {
    static func createProfileDropModule() -> UIViewController {
        guard let mpcManager = MPCManager(dataManager: LocalDataManager()) else {
            return UIViewController()
        }
        let niManager = NIManager()
        let nearByProfileDropUseCase: NearByProfileDropUseCase =
        NearByProfileDropUseCaseImpl(
            dataManager: LocalDataManager(),
            niManager: niManager,
            mpcManager: mpcManager)
        let targetedProfileDropUseCase: TargetedProfileDropUseCase =
        TargetedProfileDropUseCaseImpl(
            dataManager: LocalDataManager(),
            mpcManager: mpcManager)
        let quitProfileDropUseCase: QuitProfileDropUseCase =
        QuitProfileDropUseCaseImpl(niManager: niManager)
        let niDeviceChecker: NIDeviceCheckerProtocol = NIDeviceChecker()
        

        let view: ProfileDropViewable & UIViewController = ProfileDropViewController()
        let router: ProfileDropRoutable & ProfileDropBuildable = ProfileDropRouter()
        let presenter: ProfileDropPresentable & ProfileDropInteractorOutput = ProfileDropPresenter()
        let interactor: ProfileDropInteractable = ProfileDropInteractor(
            nearByProfileDropUseCase: nearByProfileDropUseCase,
            targetedProfileDropUseCase: targetedProfileDropUseCase,
            quitProfileDropUseCase: quitProfileDropUseCase,
            niDeviceChecker: niDeviceChecker)

        view.presenter = presenter
        presenter.view = view
        presenter.router = router
        presenter.interactor = interactor
        interactor.presenter = presenter
        router.presenter = presenter

        return view
    }
}
