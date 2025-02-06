//
//  ReportMateViewController.swift
//  SniffMeet
//
//  Created by 배현진 on 2/6/25.
//

import UIKit

protocol ReportMateViewable: AnyObject {
//    var presenter: (any ReportMatePresentable)? { get set }
}

final class ReportMateViewController: BaseViewController, ReportMateViewable {
    //    var presenter: (any ReportMatePresentable)?
    private var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "ImagePlaceholder")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    private var nickNameLabel: UILabel = {
        let label = UILabel()
        label.font = SNMFont.headline
        label.textColor = .black
        label.text = Context.nickName
        label.textAlignment = .center
        return label
    }()
    private var selectionView: UIView = {
        let view = UIView()
        view.backgroundColor = SNMColor.subGray1
        view.layer.cornerRadius = 10
        return view
    }()
    private var selectionLabel: UILabel = {
        let label = UILabel()
        label.text = Context.reportTitlePlaceholder
        label.textColor = .darkGray
        label.font = SNMFont.subheadline
        return label
    }()
    private var chevronImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "chevron.down")
        imageView.tintColor = SNMColor.subGray2
        return imageView
    }()
    private var reportTextView: UITextView = {
        let textView = UITextView()
        textView.text = Context.reportMessagePlaceholder
        textView.font = SNMFont.subheadline
        textView.backgroundColor = SNMColor.subGray1
        textView.layer.cornerRadius = 10
        let padding = LayoutConstant.edgePadding
        textView.textContainerInset = UIEdgeInsets(top: padding,
                                                   left: padding,
                                                   bottom: padding,
                                                   right: padding)
        textView.textColor = .lightGray
        return textView
    }()
    private var submitButton = PrimaryButton(title: Context.submitButtonTitle)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
//        presenter?.viewDidLoad()
    }

    override func configureAttributes() {
        // 키보드 숨기기, UI 업뎃 관련 등
        configureNavigationControllerAttributes()
        profileImageView.makeViewCircular()
        hideKeyboardWhenTappedAround()
    }
    private func configureNavigationControllerAttributes() {
        navigationController?.navigationBar.configureBackButton()
        navigationItem.title = Context.title
        navigationItem.largeTitleDisplayMode = .never
    }
    override func configureHierachy() {
        // addSubView 등
        [profileImageView,
         nickNameLabel,
         selectionView,
         reportTextView,
         submitButton].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        [selectionLabel, chevronImageView].forEach {
            selectionView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    override func configureConstraints() {
        // Constraints 등
        setConstraint()
        setSelectionConstraint()
    }

    private func setConstraint() {
        NSLayoutConstraint.activate([
            profileImageView.heightAnchor.constraint(equalToConstant: LayoutConstant.xlargeVerticalPadding * 2),
            profileImageView.widthAnchor.constraint(equalToConstant: LayoutConstant.xlargeVerticalPadding * 2),
            profileImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: Context.topMargin),
            profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nickNameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: LayoutConstant.mediumVerticalPadding),
            nickNameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            selectionView.topAnchor.constraint(equalTo: nickNameLabel.bottomAnchor, constant: LayoutConstant.largeVerticalPadding),
            selectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: LayoutConstant.horizontalPadding),
            selectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -LayoutConstant.horizontalPadding),
            reportTextView.topAnchor.constraint(equalTo: selectionView.bottomAnchor, constant: LayoutConstant.mediumVerticalPadding),
            reportTextView.bottomAnchor.constraint(equalTo: submitButton.topAnchor, constant: -LayoutConstant.horizontalPadding * 2),
            reportTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: LayoutConstant.horizontalPadding),
            reportTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -LayoutConstant.horizontalPadding),
            submitButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -LayoutConstant.largeVerticalPadding),
            submitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: LayoutConstant.horizontalPadding),
            submitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -LayoutConstant.horizontalPadding)
        ])
    }
    private func setSelectionConstraint() {
        NSLayoutConstraint.activate([
            selectionLabel.leadingAnchor.constraint(equalTo: selectionView.leadingAnchor, constant: LayoutConstant.xsmallVerticalPadding),
            selectionLabel.topAnchor.constraint(equalTo: selectionView.topAnchor, constant: LayoutConstant.edgePadding),
            selectionLabel.bottomAnchor.constraint(equalTo: selectionView.bottomAnchor, constant: -LayoutConstant.edgePadding),
            chevronImageView.trailingAnchor.constraint(equalTo: selectionView.trailingAnchor, constant: -LayoutConstant.xsmallVerticalPadding),
            chevronImageView.topAnchor.constraint(equalTo: selectionView.topAnchor, constant: LayoutConstant.edgePadding)
        ])
    }
    override func bind() {}
}

private extension ReportMateViewController {
    enum Context {
        static let title: String = "신고"
        static let nickName: String = "닉네임"
        static let reportTitlePlaceholder: String = "신고 이유를 선택해주세요."
        static let reportMessagePlaceholder: String = "자세한 신고 내용을 입력해주세요."
        static let submitButtonTitle: String = "제출하기"
        static let topMargin: CGFloat = 150
    }
}
