//
//  WalkLogListPresenter.swift
//  SniffMeet
//
//  Created by sole on 2/27/25.
//

protocol WalkLogListPresentable: AnyObject {
    var view: (any WalkLogListViewable)? { get }
    var interactor: (any WalkLogListInteractable)? { get }
    var router: (any WalkLogListRoutable)? { get }
}

final class WalkLogListPresenter: WalkLogListPresentable {
    weak var view: (any WalkLogListViewable)?
    var interactor: (any WalkLogListInteractable)?
    var router: (any WalkLogListRoutable)?
}
