//
//  Untitled.swift
//  SniffMeet
//
//  Created by 윤지성 on 2/18/25.
//

protocol TrackWalkInteractable: AnyObject {
    var presenter: TrackWalkInteractorOutput? { get set }

}

final class TrackWalkInteractor: TrackWalkInteractable {
    weak var presenter: (any TrackWalkInteractorOutput)?
}
