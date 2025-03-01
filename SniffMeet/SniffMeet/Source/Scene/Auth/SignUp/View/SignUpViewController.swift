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
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 5
        stack.alignment = .fill
        return stack
    }()
    private var idTextField: InputTextField = InputTextField(placeholder: Context.idPlaceholder)
    private var pwTextField: InputTextField = InputTextField(placeholder: Context.pwPlaceholder)
    private var pwCheckTextField: InputTextField = InputTextField(placeholder: Context.pwCheckPlaceholder)
    private var warningLabel: UILabel = {
        let label = UILabel()
        label.textColor = SNMColor.mainNavy
        label.text = Context.pwInfoText
        label.font = SNMFont.caption
        return label
    }()
    private var idVerifyButton = PrimaryButton(title: Context.idVerifyButtonTitle)
    private var signUpButton = PrimaryButton(title: Context.signUpButtonTitle)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = SNMColor.white
        signUpButton.isEnabled = false
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
        [idTextField,
         idVerifyButton].forEach {
            stackView.addArrangedSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        [stackView,
         pwTextField,
         pwCheckTextField,
         warningLabel,
         signUpButton].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }

    override func configureConstraints() {
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: 30),
            stackView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: LayoutConstant.horizontalPadding),
            stackView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -LayoutConstant.horizontalPadding),
            pwTextField.topAnchor.constraint(
                equalTo: stackView.bottomAnchor,
                constant: LayoutConstant.xlargeVerticalPadding),
            pwTextField.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: LayoutConstant.horizontalPadding),
            pwTextField.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -LayoutConstant.horizontalPadding),
            pwCheckTextField.topAnchor.constraint(
                equalTo: pwTextField.bottomAnchor,
                constant: LayoutConstant.xlargeVerticalPadding),
            pwCheckTextField.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: LayoutConstant.horizontalPadding),
            pwCheckTextField.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -LayoutConstant.horizontalPadding),
            warningLabel.topAnchor.constraint(
                equalTo: pwCheckTextField.bottomAnchor,
                constant: LayoutConstant.regularVerticalPadding),
            warningLabel.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: Context.warningPadding),
            signUpButton.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: LayoutConstant.horizontalPadding),
            signUpButton.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -LayoutConstant.horizontalPadding),
            signUpButton.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -LayoutConstant.horizontalPadding
            )
        ])
    }

    override func bind() {
    }
}

private extension SignUpViewController {
    enum Context {
        static let title: String = " 회원가입"
        static let idPlaceholder: String = "이메일을 입력해주세요."
        static let pwPlaceholder: String = "비밀번호를 입력해주세요."
        static let pwCheckPlaceholder: String = "비밀번호를 다시 입력해주세요."
        static let pwInfoText: String = "영문, 숫자를 포함한 8자 이상의 비밀번호를 입력해주세요."
        static let idVerifyButtonTitle: String = "인증"
        static let signUpButtonTitle: String = "다음"
        static let warningPadding: CGFloat = 26
    }
}
