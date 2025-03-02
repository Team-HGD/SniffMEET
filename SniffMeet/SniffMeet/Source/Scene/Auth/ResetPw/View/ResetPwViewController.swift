//
//  ResetPwViewController.swift
//  SniffMeet
//
//  Created by 배현진 on 3/2/25.
//

import UIKit

protocol ResetPwViewable: AnyObject {
    var presenter: (any ResetPwPresentable)? { get set }
}

final class ResetPwViewController: BaseViewController, ResetPwViewable {
    var presenter: (any ResetPwPresentable)?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func configureAttributes() {
        hideKeyboardWhenTappedAround()
    }

    override func configureHierachy() {
    }

    override func configureConstraints() {
    }

    override func bind() {
    }
}

private extension ResetPwViewController {
    enum Context {
    }
}
