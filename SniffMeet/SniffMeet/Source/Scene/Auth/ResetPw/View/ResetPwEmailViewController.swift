//
//  SendResetPwMailViewController.swift
//  SniffMeet
//
//  Created by 배현진 on 3/2/25.
//

import UIKit

protocol ResetPwEmailViewable: AnyObject {
    var presenter: (any ResetPwEmailPresentable)? { get set }
}

final class ResetPwEmailViewController: BaseViewController, ResetPwEmailViewable {
    var presenter: (any ResetPwEmailPresentable)?

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

private extension ResetPwEmailViewController {
    enum Context {
    }
}
