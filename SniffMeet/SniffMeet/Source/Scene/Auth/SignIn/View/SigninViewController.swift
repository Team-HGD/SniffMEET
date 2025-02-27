//
//  SignInViewController.swift
//  SniffMeet
//
//  Created by 배현진 on 2/25/25.
//
import Combine
import UIKit

protocol SigninViewable: AnyObject {
    var presenter: (any SigninPresentable)? { get set }
}

final class SigninViewController: BaseViewController, SigninViewable {
    var presenter: (any SigninPresentable)?
    private let signUpTapGesture = UITapGestureRecognizer()
    private let findPWTapGesture = UITapGestureRecognizer()
    private var cancellables: Set<AnyCancellable> = []
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.text = Context.title
        label.textColor = SNMColor.mainNavy
        label.font = SNMFont.bigLogoTitle
        return label
    }()
    private var idTextField: InputTextField = InputTextField(placeholder: Context.idPlaceholder)
    private var pwTextField: InputTextField = InputTextField(placeholder: Context.pwPlaceholder)
    private var signInButton = PrimaryButton(title: Context.signinButtonTitle)
    private var signUpLabel: UILabel = {
        let label = UILabel()
        label.text = Context.signupButtonTitle
        label.textColor = SNMColor.mainNavy
        label.font = SNMFont.body
        label.isUserInteractionEnabled = true
        return label
    }()
    private var findPWLabel: UILabel = {
        let label = UILabel()
        label.text = Context.findPWButtonTitle
        label.textColor = SNMColor.mainNavy
        label.font = SNMFont.body
        label.isUserInteractionEnabled = true
        return label
    }()


    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func configureAttributes() {
        hideKeyboardWhenTappedAround()
        pwTextField.isSecureTextEntry = true
        signUpLabel.addGestureRecognizer(signUpTapGesture)
        findPWLabel.addGestureRecognizer(findPWTapGesture)
    }

    override func configureHierachy() {
        [titleLabel,
         idTextField,
         pwTextField,
         signInButton,
         signUpLabel,
         findPWLabel].forEach{
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }

    override func configureConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: Context.firstVerticalPadding),
            idTextField.topAnchor.constraint(
                equalTo: titleLabel.bottomAnchor,
                constant: LayoutConstant.largeVerticalPadding * 2),
            idTextField.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: LayoutConstant.horizontalPadding),
            idTextField.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -LayoutConstant.horizontalPadding),
            pwTextField.topAnchor.constraint(
                equalTo: idTextField.bottomAnchor,
                constant: LayoutConstant.regularVerticalPadding),
            pwTextField.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: LayoutConstant.horizontalPadding),
            pwTextField.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -LayoutConstant.horizontalPadding),
            signInButton.topAnchor.constraint(
                equalTo: pwTextField.bottomAnchor,
                constant: LayoutConstant.xlargeVerticalPadding),
            signInButton.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: LayoutConstant.horizontalPadding),
            signInButton.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -LayoutConstant.horizontalPadding),
            signUpLabel.topAnchor.constraint(
                equalTo: signInButton.bottomAnchor,
                constant: LayoutConstant.xlargeVerticalPadding),
            signUpLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            findPWLabel.topAnchor.constraint(
                equalTo: signUpLabel.bottomAnchor,
                constant: LayoutConstant.regularVerticalPadding),
            findPWLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    override func bind() {
        signInButton.publisher(event: .touchUpInside)
            .debounce(for: .seconds(EventConstant.debounceInterval), scheduler: RunLoop.main)
            .sink { [weak self] _ in
            // TODO: - 로그인 버튼 클릭시
            }
            .store(in: &cancellables)
        signUpTapGesture.publisher(for: \.state)
            .filter { $0 == .ended }
            .sink { [weak self] _ in
            // TODO: - 회원가입 클릭시
            }
            .store(in: &cancellables)
        findPWTapGesture.publisher(for: \.state)
            .filter { $0 == .ended }
            .sink { [weak self] _ in
            // TODO: - 비밀번호 찾기 클릭시
            }
            .store(in: &cancellables)
    }
}

private extension SigninViewController {
    enum Context {
        static let title = "SniffMEET"
        static let signinButtonTitle = "로그인"
        static let signupButtonTitle = "회원가입"
        static let findPWButtonTitle = "비밀번호 찾기"
        static let idPlaceholder: String = "아이디를 입력해주세요."
        static let pwPlaceholder: String = "비밀번호를 입력해주세요."
        static let firstVerticalPadding: CGFloat = 100
    }
}
