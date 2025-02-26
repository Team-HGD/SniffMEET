//
//  SignInViewController.swift
//  SniffMeet
//
//  Created by 배현진 on 2/25/25.
//

import UIKit

protocol SigninViewable: AnyObject {
    var presenter: (any SigninPresentable)? { get set }
}

final class SigninViewController: BaseViewController, SigninViewable {
    var presenter: (any SigninPresentable)?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func configureAttributes() {
    }

    override func configureHierachy() {
    }

    override func configureConstraints() {
    }

    override func bind() {
    }
}

private extension SigninViewController {
    enum Context {
    }
}
