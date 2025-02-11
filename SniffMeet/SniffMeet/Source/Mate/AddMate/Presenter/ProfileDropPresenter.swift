//
//  ProfileDropPresenter.swift
//  SniffMeet
//
//  Created by 배현진 on 2/11/25.
//

protocol ProfileDropPresentable: AnyObject {
    var view: (any ProfileDropViewable)? { get set }
    var interactor: (any ProfileDropInteractable)? { get set }
    var router: (any ProfileDropRoutable)? { get set }
    var output: any ProfileDropPresenterOutput { get }

    func viewDidLoad()
}

protocol ProfileDropInteractorOutput: AnyObject {
    func didCloseTheView()
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
    }
}

extension ProfileDropPresenter: ProfileDropInteractorOutput {
    func didCloseTheView() {
    }
}
