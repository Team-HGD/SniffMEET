//
//  AppRouter.swift
//  SniffMeet
//
//  Created by Kelly Chui on 11/12/24.
//

import UIKit

final class AppRouter: NSObject, Routable {
    private var window: UIWindow?

    init(window: UIWindow?) {
        self.window = window
        super.init()
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
    private func displayTabBar() {
        let submodules = (
            home: UINavigationController(rootViewController: HomeModuleBuilder.build()),
            mate: UINavigationController(rootViewController: MateListRouter.createMateListModule())
        )
        window?.rootViewController = TabBarModuleBuilder.build(usingSubmodules: submodules)
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
