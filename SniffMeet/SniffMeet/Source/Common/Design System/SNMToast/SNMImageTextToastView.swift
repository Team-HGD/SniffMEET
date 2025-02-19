//
//  SNMImageTextToastView.swift
//  SniffMeet
//
//  Created by sole on 2/17/25.
//

import UIKit

final class SNMImageTextToastView: UIVisualEffectView, SNMToast {
    let animationType: any SNMAnimationType
    private let imageView: UIImageView = UIImageView()
    private let messageLabel: UILabel = UILabel()
    private let vibrancyEffectView: UIVisualEffectView

    init(
        frame: CGRect = .zero,
        animationType: any SNMAnimationType,
        effect: UIBlurEffect = UIBlurEffect(style: .systemUltraThinMaterialDark),
        image: UIImage? = nil,
        text: String? = nil
    ) {
        self.animationType = animationType
        let vibrancyEffect = UIVibrancyEffect(blurEffect: effect, style: .label)
        self.vibrancyEffectView = UIVisualEffectView(effect: vibrancyEffect)
        super.init(effect: effect)

        imageView.image = image
        messageLabel.text = text

        configureHierarchy()
        configureConstraints()
        configureAttributes()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureHierarchy() {
        [vibrancyEffectView].forEach {
            contentView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        [imageView, messageLabel].forEach {
            vibrancyEffectView.contentView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    private func configureConstraints() {
        NSLayoutConstraint.activate([
            contentView.widthAnchor.constraint(equalToConstant: 150),
            contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 80),
            vibrancyEffectView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            vibrancyEffectView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            vibrancyEffectView.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            vibrancyEffectView.heightAnchor.constraint(equalTo: contentView.heightAnchor),
            imageView.leadingAnchor.constraint(
                equalTo: vibrancyEffectView.contentView.leadingAnchor,
                constant: 10
            ),
            imageView.centerYAnchor.constraint(
                equalTo: vibrancyEffectView.contentView.centerYAnchor
            ),
            imageView.widthAnchor.constraint(equalToConstant: 50),
            imageView.heightAnchor.constraint(equalToConstant: 50),
            messageLabel.leadingAnchor.constraint(
                equalTo: imageView.trailingAnchor,
                constant: 10
            ),
            messageLabel.trailingAnchor.constraint(
                equalTo: vibrancyEffectView.contentView.trailingAnchor,
                constant: -10
            ),
            messageLabel.centerYAnchor.constraint(
                equalTo: vibrancyEffectView.contentView.centerYAnchor
            )
        ])
    }
    private func configureAttributes() {
        layer.cornerRadius = 20
        layer.masksToBounds = true
        
        imageView.contentMode = .scaleAspectFit

        messageLabel.textAlignment = .left
        messageLabel.numberOfLines = 0
        messageLabel.font = SNMFont.subheadline
    }
}
