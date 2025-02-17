//
//  OnBoardingPageViewController.swift
//  SniffMeet
//
//  Created by 배현진 on 12/4/24.
//

import UIKit

class OnBoardingPageViewController: BaseViewController {
    let page: OnBoardingPage

    private var titleLabel: UILabel = {
        let label = UILabel()
        label.text = Context.titleLabel
        label.textColor = SNMColor.mainNavy
        label.numberOfLines = 4
        label.font = SNMFont.largeTitle
        return label
    }()
    private var descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = Context.descriptionLabel
        label.textColor = SNMColor.mainNavy
        label.numberOfLines = 5
        label.font = SNMFont.callout
        return label
    }()
    private var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "ImagePlaceholder")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    private var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        return stackView
    }()

    init(page: OnBoardingPage) {
        self.page = page
        super.init()
    }
    
    override func configureAttributes() {
        titleLabel.attributedText = getAttributedText(
            fullText: page.title,
            highlight: Context.highlightText,
            color: SNMColor.mainBrown
        )
        descriptionLabel.text = page.description
        if page.isGif {
            if let gifImageView = GIFImageView(named: page.imageName) {
                imageView.removeFromSuperview()
                imageView = gifImageView
                imageView.contentMode = .scaleAspectFit
            }
        } else {
            imageView.image = UIImage(named: page.imageName)
        }
    }
    override func configureHierachy() {
        [titleLabel,
         imageView,
         descriptionLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            stackView.addArrangedSubview($0)
        }
        stackView.setCustomSpacing(Context.smallStackSpacing, after: titleLabel)
        stackView.setCustomSpacing(Context.largeStackSpacing, after: imageView)

        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)

    }
    override func configureConstraints() {
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: LayoutConstant.horizontalPadding
            ),
            stackView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -LayoutConstant.horizontalPadding
            ),
            stackView.centerYAnchor.constraint(
                equalTo: view.centerYAnchor,
                constant: -Context.stackCenter
            ),
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.heightAnchor.constraint(
                equalTo: view.heightAnchor,
                multiplier: Context.multiplier
            ),
            stackView.widthAnchor.constraint(equalTo: stackView.widthAnchor),

            imageView.heightAnchor.constraint(
                equalTo: stackView.widthAnchor,
                multiplier: Context.multiplier
            ),
            imageView.widthAnchor.constraint(equalTo: stackView.widthAnchor)
        ])
    }
    override func bind() {}
}

private extension OnBoardingPageViewController {
    enum Context {
        static let titleLabel: String = "온보딩 타이틀"
        static let descriptionLabel: String = "온보딩 설명"
        static let highlightText: String = "산책 메이트"
        static let smallStackSpacing: CGFloat = 10
        static let largeStackSpacing: CGFloat = 50
        static let stackCenter: CGFloat = 60
        static let multiplier: Double = 0.7
    }
}

private extension OnBoardingPageViewController {
    private func getAttributedText(
        fullText: String,
        highlight: String,
        color: UIColor) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: fullText)

        if let range = fullText.range(of: highlight) {
            let nsRange = NSRange(range, in: fullText)
            attributedString.addAttribute(.foregroundColor, value: color, range: nsRange)
        }

        return attributedString
    }
}

