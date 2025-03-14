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
    private var emailTextField: InputTextField = InputTextField(placeholder: Context.emailPlaceholder)
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
    private lazy var separatorView = createSeparatorView()
    private lazy var appleSignInButton = createSocialSignInButton(imageName: Context.appleSignInImage)
    private lazy var googleSignInButton = createSocialSignInButton(imageName: Context.googleSignInImage)
    private lazy var startSocialSeparatorView = createSeparatorView()
    private lazy var endSocialSeparatorView = createSeparatorView()
    private var socialSeparatorLabel: UILabel = {
        let label = UILabel()
        label.text = Context.socialSignInLabel
        label.textColor = SNMColor.subGray2
        label.font = SNMFont.callout
        return label
    }()
    private lazy var stackView = createStackView(axis: .horizontal, spacing: 20, distribution: .equalSpacing)
    private lazy var socialSeparatorStackView = createStackView(axis: .horizontal, spacing: 10, distribution: .fill)
    private lazy var socialSignInStackView = createStackView(axis: .horizontal, spacing: 20, distribution: .equalSpacing)

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
         emailTextField,
         pwTextField,
         signInButton,
         stackView,
         socialSeparatorStackView,
         socialSignInStackView].forEach{
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        [signUpLabel,
         separatorView,
         findPWLabel].forEach{
            stackView.addArrangedSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        [appleSignInButton,
         googleSignInButton].forEach{
            socialSignInStackView.addArrangedSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        [startSocialSeparatorView,
         socialSeparatorLabel,
         endSocialSeparatorView].forEach{
            socialSeparatorStackView.addArrangedSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }

    override func configureConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.bottomAnchor.constraint(
                equalTo: emailTextField.topAnchor,
                constant: -LayoutConstant.largeVerticalPadding * 2),
            emailTextField.bottomAnchor.constraint(
                equalTo: pwTextField.topAnchor,
                constant: -LayoutConstant.regularVerticalPadding),
            emailTextField.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: LayoutConstant.horizontalPadding),
            emailTextField.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -LayoutConstant.horizontalPadding),
            pwTextField.bottomAnchor.constraint(
                equalTo: signInButton.topAnchor,
                constant: -LayoutConstant.xlargeVerticalPadding),
            pwTextField.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: LayoutConstant.horizontalPadding),
            pwTextField.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -LayoutConstant.horizontalPadding),
            signInButton.centerYAnchor.constraint(
                equalTo: view.centerYAnchor,
                constant: Context.centerYConstant),
            signInButton.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: LayoutConstant.horizontalPadding),
            signInButton.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -LayoutConstant.horizontalPadding),
            stackView.topAnchor.constraint(
                equalTo: signInButton.bottomAnchor,
                constant: LayoutConstant.mediumVerticalPadding),
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            separatorView.widthAnchor.constraint(equalToConstant: Context.separatorViewStroke),
            separatorView.heightAnchor.constraint(
                equalTo: stackView.heightAnchor,
                multiplier: Context.separatorViewMultiplier),
            socialSeparatorStackView.topAnchor.constraint(
                equalTo: stackView.bottomAnchor,
                constant: LayoutConstant.largeVerticalPadding * 2),
            socialSeparatorStackView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: LayoutConstant.horizontalPadding),
            socialSeparatorStackView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -LayoutConstant.horizontalPadding),
            startSocialSeparatorView.heightAnchor.constraint(equalToConstant: Context.separatorViewStroke),
            endSocialSeparatorView.heightAnchor.constraint(equalToConstant: Context.separatorViewStroke),
            socialSeparatorLabel.centerXAnchor.constraint(equalTo: socialSeparatorStackView.centerXAnchor),
            socialSignInStackView.topAnchor.constraint(
                equalTo: socialSeparatorStackView.bottomAnchor,
                constant: LayoutConstant.mediumVerticalPadding),
            socialSignInStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
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
        appleSignInButton.publisher(event: .touchUpInside)
            .debounce(for: .seconds(EventConstant.debounceInterval), scheduler: RunLoop.main)
            .sink { [weak self] _ in
            // TODO: - 애플 로그인 버튼 클릭시
            }
            .store(in: &cancellables)
        googleSignInButton.publisher(event: .touchUpInside)
            .debounce(for: .seconds(EventConstant.debounceInterval), scheduler: RunLoop.main)
            .sink { [weak self] _ in
            // TODO: - 구글 로그인 버튼 클릭시
            }
            .store(in: &cancellables)
    }
}

private extension SigninViewController {
    enum Context {
        static let title: String = "SniffMEET"
        static let signinButtonTitle: String = "로그인"
        static let signupButtonTitle: String = "회원가입"
        static let findPWButtonTitle: String = "비밀번호 찾기"
        static let emailPlaceholder: String = "이메일을 입력해주세요."
        static let pwPlaceholder: String = "비밀번호를 입력해주세요."
        static let appleSignInImage: String = "appleSignIn"
        static let googleSignInImage: String = "googleSignIn"
        static let socialSignInLabel: String = "SNS 계정으로 로그인"
        static let centerYConstant: CGFloat = 50
        static let separatorViewStroke: CGFloat = 1
        static let separatorViewMultiplier: CGFloat = 0.7
    }

    private func createSeparatorView() -> UIView {
        let view = UIView()
        view.backgroundColor = SNMColor.subGray2
        return view
    }

    private func createStackView(axis: NSLayoutConstraint.Axis, spacing: CGFloat, distribution: UIStackView.Distribution) -> UIStackView {
        let stack = UIStackView()
        stack.axis = axis
        stack.spacing = spacing
        stack.alignment = .center
        stack.distribution = distribution
        return stack
    }

    private func createSocialSignInButton(imageName: String) -> UIButton {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: imageName), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        return button
    }
}
