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
    private let pwTextField: InputTextField = InputTextField(placeholder: Context.pwPlaceholder)
    private let pwCheckTextField: InputTextField = InputTextField(placeholder: Context.pwCheckPlaceholder)
    private let infoLabel: UILabel = {
        let label = UILabel()
        label.textColor = SNMColor.mainNavy
        label.text = Context.infoText
        label.font = SNMFont.caption
        return label
    }()
    private var resetPwButton = PrimaryButton(title: Context.resetPwButtonTitle)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = SNMColor.white
        resetPwButton.isEnabled = false
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
        [pwTextField,
         pwCheckTextField,
         infoLabel,
         resetPwButton].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }

    override func configureConstraints() {
        NSLayoutConstraint.activate([
            pwTextField.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: LayoutConstant.largeVerticalPadding),
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
            infoLabel.topAnchor.constraint(
                equalTo: pwCheckTextField.bottomAnchor,
                constant: LayoutConstant.regularVerticalPadding),
            infoLabel.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: Context.infoPadding),
            resetPwButton.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: LayoutConstant.horizontalPadding),
            resetPwButton.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -LayoutConstant.horizontalPadding),
            resetPwButton.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -LayoutConstant.horizontalPadding
            )
        ])
    }

    override func bind() {
    }
}

private extension ResetPwViewController {
    enum Context {
        static let title: String = " 비밀번호 변경"
        static let pwPlaceholder: String = "비밀번호를 입력해주세요."
        static let pwCheckPlaceholder: String = "비밀번호를 다시 입력해주세요."
        static let infoText: String = "영문, 숫자를 포함한 8자 이상 15자 이하로 입력해주세요."
        static let resetPwButtonTitle: String = "변경하기"
        static let infoPadding: CGFloat = 26
    }
}
