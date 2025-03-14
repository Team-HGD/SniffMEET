//
//  WalkLogCell.swift
//  SniffMeet
//
//  Created by sole on 11/24/24.
//

import UIKit

final class WalkLogCell: UITableViewCell {
    private let profileImageView: UIImageView = UIImageView(frame: .zero)

    private let profileStackView: UIStackView = UIStackView()
    private let nickNameLabel: UILabel = UILabel()
    private let dateLabel: UILabel = UILabel()

    private let walkLogStackView: UIStackView = UIStackView()

    private let distanceStackView: UIStackView = UIStackView()
    private let distanceTitleLabel: UILabel = UILabel()
    private let distanceLabel: UILabel = UILabel()

    private let stepStackView: UIStackView = UIStackView()
    private let stepTitleLabel: UILabel = UILabel()
    private let stepLabel: UILabel = UILabel()

    private let durationStackView: UIStackView = UIStackView()
    private let durationTitleLabel: UILabel = UILabel()
    private let durationLabel: UILabel = UILabel()

    private let walkLogImageView: UIImageView = UIImageView(frame: .zero)

    override init(
        style: UITableViewCell.CellStyle,
        reuseIdentifier: String?
    ) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureAttributes()
        configureHierarchy()
        configureConstraints()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureAttributes() {
        profileImageView.backgroundColor = SNMColor.subGray1
        profileImageView.image = UIImage(resource: .imagePlaceholder)
        profileImageView.layer.masksToBounds = true
        profileImageView.layer.cornerRadius = Layout.profileImageSize / 2

        nickNameLabel.font = SNMFont.headline

        dateLabel.font = SNMFont.caption2
        dateLabel.textColor = SNMColor.text2

        walkLogStackView.spacing = 30
        profileStackView.axis = .vertical
        distanceStackView.axis = .vertical
        stepStackView.axis = .vertical
        durationStackView.axis = .vertical

        distanceTitleLabel.text = Context.distanceLabelTitle
        distanceTitleLabel.textAlignment = .center
        distanceTitleLabel.textColor = SNMColor.text2
        distanceTitleLabel.font = SNMFont.caption2
        distanceLabel.font = SNMFont.caption2
        distanceLabel.textAlignment = .center

        stepTitleLabel.text = Context.stepLabelTitle
        stepTitleLabel.textAlignment = .center
        stepTitleLabel.textColor = SNMColor.text2
        stepTitleLabel.font = SNMFont.caption2
        stepLabel.font = SNMFont.caption2
        stepLabel.textAlignment = .center

        durationTitleLabel.text = Context.timeLabelTitle
        durationTitleLabel.textAlignment = .center
        durationTitleLabel.textColor = SNMColor.text2
        durationTitleLabel.font = SNMFont.caption2
        durationLabel.font = SNMFont.caption2
        durationLabel.textAlignment = .center

        walkLogImageView.image = UIImage(resource: .imagePlaceholder)
    }
    private func configureHierarchy() {
        [nickNameLabel,
         dateLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            profileStackView.addArrangedSubview($0)
        }
        [distanceTitleLabel,
         distanceLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            distanceStackView.addArrangedSubview($0)
        }
        [stepTitleLabel,
         stepLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            stepStackView.addArrangedSubview($0)
        }
        [durationTitleLabel,
         durationLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            durationStackView.addArrangedSubview($0)
        }
        [distanceStackView,
         stepStackView,
         durationStackView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            walkLogStackView.addArrangedSubview($0)
        }

        [profileImageView,
         profileStackView,
         walkLogStackView,
         walkLogImageView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
    }
    private func configureConstraints() {
        NSLayoutConstraint.activate([
            profileImageView.widthAnchor.constraint(
                equalToConstant: Layout.profileImageSize
            ),
            profileImageView.heightAnchor.constraint(
                equalToConstant: Layout.profileImageSize
            ),
            profileImageView.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: LayoutConstant.horizontalPadding
            ),
            profileImageView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: LayoutConstant.horizontalPadding
            ),

            profileStackView.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            profileStackView.leadingAnchor.constraint(
                equalTo: profileImageView.trailingAnchor,
                constant: LayoutConstant.tagHorizontalSpacing
            ),
            profileStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            distanceStackView.heightAnchor.constraint(
                equalToConstant: SNMFont.caption.lineHeight * 2
            ),
            stepStackView.heightAnchor.constraint(
                equalToConstant: SNMFont.caption.lineHeight * 2
            ),
            durationStackView.heightAnchor.constraint(
                equalToConstant: SNMFont.caption.lineHeight * 2
            ),

            walkLogStackView.topAnchor.constraint(
                equalTo: profileImageView.bottomAnchor,
                constant: LayoutConstant.smallVerticalPadding
            ),
            walkLogStackView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: LayoutConstant.horizontalPadding
            ),
            walkLogStackView.heightAnchor.constraint(
                equalToConstant: walkLogStackView.intrinsicContentSize.height
            ),
            
            walkLogImageView.topAnchor.constraint(
                equalTo: walkLogStackView.bottomAnchor,
                constant: LayoutConstant.smallVerticalPadding
            ),
            walkLogImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            walkLogImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            walkLogImageView.heightAnchor.constraint(equalToConstant: Layout.profileImageViewHeight)
        ])
    }

    func configureWalkLogSection(
        date: String,
        distance: String,
        step: String,
        duration: String,
        image: UIImage?
    ) {
        dateLabel.text = date
        distanceLabel.text = distance
        stepLabel.text = step
        durationLabel.text = duration
        walkLogImageView.image = image ?? .imagePlaceholder
    }
    func configureProfileSection(profileImage: UIImage?, name: String) {
        profileImageView.image = profileImage ?? .imagePlaceholder
        nickNameLabel.text = name
    }
}

extension WalkLogCell {
    static let identifier: String = String(describing: WalkLogCell.self)
}

// MARK: - WalkLogCell+Constant

private extension WalkLogCell {
    enum Context {
        static let distanceLabelTitle: String = "거리"
        static let stepLabelTitle: String = "걸음 수"
        static let timeLabelTitle: String = "시간"
    }

    enum Layout {
        static let profileImageSize: CGFloat = 58
        static let profileImageViewHeight: CGFloat = 246
    }
}
