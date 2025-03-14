//
//  RequestMateRouter.swift
//  SniffMeet
//
//  Created by 배현진 on 11/20/24.
//

import UIKit

protocol RequestMateRoutable: AnyObject {
    var presenter: (any RequestWalkPresentable)? { get set }

    func dismissView(view: any RequestMateViewable)
}

protocol RequestMateBuildable {
    static func createRequestMateModule(profile: DogDTO) -> UIViewController
}

final class RequestMateRouter: RequestMateRoutable {
    weak var presenter: (any RequestWalkPresentable)?

    func dismissView(view: any RequestMateViewable) {
        if let view = view as? UIViewController {
            SNMLogger.log("dismissView")
            view.dismiss(animated: true)
        }
    }
}

extension RequestMateRouter: RequestMateBuildable {
    static func createRequestMateModule(profile: DogDTO) -> UIViewController {
        let respondMateRequestUsecase: RespondMateRequestUsecase = RespondMateRequestUsecaseImpl(
            localDataManager: LocalDataManager(),
            remoteDataManger: SupabaseDBManager.shared,
            sessionManager: SupabaseSessionManager.shared
        )
        let requestProfileImageUsecase: RequestProfileImageUsecase =
        RequestProfileImageUsecaseImpl(
            remoteImageManager: SupabaseStorageManager(
                networkProvider: SNMNetworkProvider(),
                sessionManager: SupabaseSessionManager.shared
            ),
            cacheManager: CacheManager.shared)
        let view = RequestMateViewController(dogDTO: profile)
        let presenter: RequestMatePresentable & RequestMateInteractorOutput = RequestMatePresenter()
        let interactor = RequestMateInteractor(
            respondMateRequestUsecase: respondMateRequestUsecase,
            requestProfileImageUsecase: requestProfileImageUsecase)
        let router: RequestMateRoutable & RequestMateBuildable = RequestMateRouter()

        view.presenter = presenter
        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router
        interactor.presenter = presenter

        return view
    }
}
