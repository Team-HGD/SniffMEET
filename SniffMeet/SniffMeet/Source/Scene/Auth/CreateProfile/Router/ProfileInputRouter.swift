//
//  Untitled.swift
//  SniffMeet
//
//  Created by 윤지성 on 11/14/24.
//
import UIKit

protocol ProfileCreateRoutable {
    func presentPostCreateScreen(from view: any ProfileCreateViewable, with dogDetail: DogInfo)
}

protocol ProfileCreateBuildable {
    static func createProfileCreateModule() -> UIViewController
}

final class ProfileCreateRouter: ProfileCreateRoutable {
    func presentPostCreateScreen(from view: any ProfileCreateViewable, with dogDetail: DogInfo) {
        let profileCreateViewController = ProfileSetRouter.createProfileSetModule(
            dogDetailInfo: dogDetail
        )
        if let sourceView = view as? UIViewController {
            sourceView.navigationController?.pushViewController(
                profileCreateViewController,
                animated: true
            )
        }
    }
}

extension ProfileCreateRouter: ProfileCreateBuildable {
    static func createProfileCreateModule() -> UIViewController {
        let view: any ProfileCreateViewable & UIViewController = ProfileCreateViewController()
        var presenter: any ProfileCreatePresentable = ProfileCreatePresenter()
        let router: any ProfileCreateRoutable & ProfileCreateBuildable = ProfileCreateRouter()
        
        view.presenter = presenter
        presenter.view = view
        presenter.router = router
        
        return view
    }
}
