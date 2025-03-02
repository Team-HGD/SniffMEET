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
    private let emailTextField: InputTextField = InputTextField(placeholder: Context.emailPlaceholder)
    private let infoLabel: UILabel = {
        let label = UILabel()
        label.textColor = SNMColor.mainNavy
        label.text = Context.infoText
        label.font = SNMFont.caption
        return label
    }()
    private var sendResetPwEmailButton = PrimaryButton(title: Context.sendResetPwEmailButtonTitle)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = SNMColor.white
        sendResetPwEmailButton.isEnabled = false
    }

    override func configureAttributes() {
        hideKeyboardWhenTappedAround()
        configureNavigationControllerAttributes()
    }

    private func configureNavigationControllerAttributes() {
        navigationController?.navigationBar.configureBackButton()
        navigationItem.title = Context.title
    }

    override func configureHierachy() {
        [emailTextField,
         infoLabel,
         sendResetPwEmailButton].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }

    override func configureConstraints() {
        NSLayoutConstraint.activate([
            emailTextField.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: LayoutConstant.largeVerticalPadding),
            emailTextField.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: LayoutConstant.horizontalPadding),
            emailTextField.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -LayoutConstant.horizontalPadding),
            infoLabel.topAnchor.constraint(
                equalTo: emailTextField.bottomAnchor,
                constant: LayoutConstant.regularVerticalPadding),
            infoLabel.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: Context.infoPadding),
            sendResetPwEmailButton.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: LayoutConstant.horizontalPadding),
            sendResetPwEmailButton.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -LayoutConstant.horizontalPadding),
            sendResetPwEmailButton.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -LayoutConstant.horizontalPadding
            )
        ])
    }

    override func bind() {
    }
}

private extension ResetPwEmailViewController {
    enum Context {
        static let title: String = "비밀번호 재설정"
        static let emailPlaceholder: String = "이메일을 입력해주세요."
        static let infoText: String = "해당 이메일로 비밀번호 재설정 정보를 전송해드립니다."
        static let sendResetPwEmailButtonTitle: String = "전송하기"
        static let infoPadding: CGFloat = 26
    }
}
