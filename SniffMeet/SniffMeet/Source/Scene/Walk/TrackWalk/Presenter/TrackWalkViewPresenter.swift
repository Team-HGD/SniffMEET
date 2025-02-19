//
//  Untitled.swift
//  SniffMeet
//
//  Created by 윤지성 on 2/18/25.
//

protocol TrackWalkPresentable: AnyObject {
    var view: (any TrackWalkViewable)? { get set }
    var interactor: (any TrackWalkInteractable)? { get set }
    var router: (any TrackWalkRoutable)? { get set }
}

protocol TrackWalkInteractorOutput: AnyObject {
}

final class TrackWalkViewPresenter: TrackWalkPresentable {
    weak var view: (any TrackWalkViewable)?
    var interactor: (any TrackWalkInteractable)?
    var router: (any TrackWalkRoutable)?
    
}
