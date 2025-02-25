//
//  ProfileInputPresenter.swift
//  SniffMeet
//
//  Created by 윤지성 on 11/14/24.
//

protocol ProfileCreatePresentable {
    var view: (any ProfileCreateViewable)? { get set }
    var router: (any ProfileCreateRoutable)? { get set }
    var interactor: (any ProfileCreateInteractable)? { get set }
    func moveToProfileCreateView(with newDogDetailInfo: DogInfo)
}

final class ProfileCreatePresenter: ProfileCreatePresentable {
    weak var view: (any ProfileCreateViewable)?
    var interactor: (any ProfileCreateInteractable)?
    var router: (any ProfileCreateRoutable)?
    let output: any ProfileCreatePresenterOutput
    
    init(view: (any ProfileCreateViewable)? = nil,
         interactor: (any ProfileCreateInteractable)? = nil,
         router: (any ProfileCreateRoutable)? = nil,
         output: any ProfileCreatePresenterOutput = DefaultProfileCreatePresenterOutput()
    ) {
        self.view = view
        self.interactor = interactor
        self.router = router
        self.output = output
    }
    
    func moveToProfileCreateView(with newDogDetailInfo: DogInfo) {
        guard let view else { return }
        router?.presentPostCreateScreen(from: view, with: newDogDetailInfo)
    }
}

// MARK: - ProfileCreatePresenterOutput
protocol ProfileCreatePresenterOutput {
    
}

struct DefaultProfileCreatePresenterOutput: ProfileCreatePresenterOutput {
    
}
