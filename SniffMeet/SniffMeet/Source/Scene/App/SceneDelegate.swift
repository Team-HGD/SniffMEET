//
//  SceneDelegate.swift
//  SniffMeet
//
//  Created by sole on 11/4/24.
//

import GoogleSignIn
import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    var appRouter: AppRouter?
    private weak var sessionController: SessionViewController?
    private let convertToAPSUsecase: ConvertToWalkAPSUsecase = ConvertToWalkAPSUsecaseImpl()

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        appRouter = AppRouter(window: window)
        let sessionController = SessionViewController(appRouter: appRouter)
        self.sessionController = sessionController

        if let response = connectionOptions.notificationResponse {
            routePushNotification(response: response)
        }
        window?.rootViewController = sessionController
        window?.makeKeyAndVisible()
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }
        // TODO: url scheme에 따라 분기처리
        GIDSignIn.sharedInstance.handle(url)
    }

    /// push notification을 통해 앱에 처음 진입한 경우 라우팅을 진행합니다.
    private func routePushNotification(response: UNNotificationResponse) {
        let userInfo = response.notification.request.content.userInfo
        if let walkAPS = convertToAPSUsecase.execute(walkAPSUserInfo: userInfo) {
            sessionController?.walkNoti = walkAPS.notification.toEntity()
        }
    }
}
