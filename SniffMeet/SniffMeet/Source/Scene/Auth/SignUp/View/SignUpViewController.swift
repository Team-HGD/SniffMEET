//
//  SignupViewController.swift
//  SniffMeet
//
//  Created by 배현진 on 2/26/25.
//

import UIKit

protocol SignUpViewable: AnyObject {
    var presenter: (any SignUpPresentable)? { get set }
}

final class SignUpViewController: BaseViewController, SignUpViewable {
    var presenter: (any SignUpPresentable)?

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

private extension SignUpViewController {
    enum Context {
    }
}
