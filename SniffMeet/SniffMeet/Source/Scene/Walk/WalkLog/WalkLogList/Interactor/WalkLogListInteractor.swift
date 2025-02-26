//
//  WalkLogListInteractor.swift
//  SniffMeet
//
//  Created by sole on 2/27/25.
//

protocol WalkLogListInteractable: AnyObject {
    var presenter: (any WalkLogListPresentable)? { get }
}

final class WalkLogListInteractor: WalkLogListInteractable {
    weak var presenter: (any WalkLogListPresentable)?
}
