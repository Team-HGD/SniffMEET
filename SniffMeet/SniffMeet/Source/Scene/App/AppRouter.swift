//
//  AppRouter.swift
//  SniffMeet
//
//  Created by Kelly Chui on 11/12/24.
//

import Combine
import UIKit

final class AppRouter: NSObject, Routable {
    private var window: UIWindow?
    private var cancellables: Set<AnyCancellable> = Set<AnyCancellable>()

    init(window: UIWindow?) {
        self.window = window
        super.init()
        bind()
    }

    func displayInitialScreen() {
        Task {
            do {
                try await SupabaseSessionManager.shared.restoreSession()
                await MainActor.run { displayHomeView() }
            } catch {
                await MainActor.run { displayOnboardingView() }
            }
        }
    }
    func displayHomeView() {
        let tabBarController = TabBarModuleBuilder.build()
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
    }
    func displayOnboardingView() {
        let navigationController = UINavigationController(
            rootViewController: OnBoardingRouter.createModule()
        )
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
    func displayProfileSetupView() {
        let navigationController = UINavigationController(
            rootViewController: ProfileInputRouter.createProfileInputModule()
        )
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
}

// MARK: - AppRouterNotificationHandlers

extension AppRouter {
    /// 뷰에 진입한 후 산책 요청 화면을 present 합니다.
    func initializeViewAndPresentRespondView(walkNoti: WalkNoti) {
        Task { @MainActor in
            do {
                try await SupabaseSessionManager.shared.restoreSession()
                displayHomeView()
                presentRespondWalkView(walkNoti: walkNoti)
            } catch {
                displayProfileSetupView()
            }
        }
    }
    /// 뷰에 진입한 후 산책 응답 화면을 present 합니다.
    func initializeViewAndPresentProcessedWalkView(walkNoti: WalkNoti) {
        Task { @MainActor in
            do {
                try await SupabaseSessionManager.shared.restoreSession()
                displayHomeView()
                presentProcessedWalkView(walkNoti: walkNoti)
            } catch {
                displayProfileSetupView()
            }
        }
    }
    func presentRespondWalkView(walkNoti: WalkNoti) {
        let respondWalkViewController = RespondWalkRouter.createRespondtWalkModule(
            walkNoti: walkNoti
        )
        presentCardViewController(viewController: respondWalkViewController)
    }
    func presentProcessedWalkView(walkNoti: WalkNoti) {
        let processedWalkViewController = ProcessedWalkRouter.createProcessedWalkView(noti: walkNoti)
        presentCardViewController(viewController: processedWalkViewController)
    }
    private func presentCardViewController(viewController: UIViewController) {
        viewController.modalPresentationStyle = .custom
        viewController.transitioningDelegate = self
        if let rootViewController = UIViewController.topMostViewController {
            present(from: rootViewController, with: viewController, animated: true)
        }
    }
    private func presentSessionExpiredAlert() {
        let alertController = UIAlertController(
            title: "세션이 만료되었습니다.",
            message: "다시 로그인해주세요.",
            preferredStyle: .alert
        )
        let confirmAction: UIAlertAction = .init(title: "확인", style: .default) { [weak self] _ in
            self?.displayProfileSetupView()
        }
        alertController.addAction(confirmAction)
        if let rootViewController = UIViewController.topMostViewController as? UIAlertController {
            rootViewController.dismiss(animated: true)
        }
        UIViewController.topMostViewController?.present(alertController, animated: true)
    }
    private func presentAlert(from alertContent: NotificationAlert) {
        let alertController = UIAlertController(
            title: alertContent.title,
            message: alertContent.message,
            preferredStyle: .alert
        )
        let confirmAction: UIAlertAction = .init(title: alertContent.defaultActionString, style: .default)
        alertController.addAction(confirmAction)
        if let rootViewController = UIViewController.topMostViewController as? UIAlertController {
            rootViewController.dismiss(animated: true)
        }
        UIViewController.topMostViewController?.present(alertController, animated: true)
    }
    private func bind() {
        NotificationCenter.default.publisher(
            for: Environment.NotificationCenterName.sessionExpired
        )
        .receive(on: RunLoop.main)
        .sink { [weak self] _ in
            self?.presentSessionExpiredAlert()
        }
        .store(in: &cancellables)
        
        NotificationCenter.default.publisher(
            for: Environment.NotificationCenterName.profileDropFailed
        )
        .receive(on: RunLoop.main)
        .sink { [weak self] notification in
            guard let alertContent  = notification.object as? NotificationAlert else { return }
            self?.presentAlert(from: alertContent)
        }
        .store(in: &cancellables)
    }
}

// MARK: - AppRouter+UIViewControllerTransitioningDelegate

extension AppRouter: UIViewControllerTransitioningDelegate {
    func presentationController(
        forPresented presented: UIViewController,
        presenting: UIViewController?,
        source: UIViewController
    ) -> UIPresentationController? {
        CardPresentationController(
            presentedViewController: presented,
            presenting: presenting
        )
    }
}
