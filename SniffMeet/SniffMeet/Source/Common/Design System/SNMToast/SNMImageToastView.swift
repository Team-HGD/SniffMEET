//
//  SNMImageToastView.swift
//  SniffMeet
//
//  Created by sole on 2/17/25.
//

import UIKit

final class SNMImageToastView: UIVisualEffectView, SNMToast {
    let animationType: any SNMAnimationType
    private let imageView: UIImageView = UIImageView()
    private let vibrancyEffectView: UIVisualEffectView

    init(
        frame: CGRect = .zero,
        animationType: any SNMAnimationType,
        effect: UIBlurEffect = UIBlurEffect(style: .systemUltraThinMaterialDark),
        image: UIImage? = nil
    ) {
        self.animationType = animationType
        let vibrancyEffect = UIVibrancyEffect(blurEffect: effect, style: .label)
        self.vibrancyEffectView = UIVisualEffectView(effect: vibrancyEffect)
        super.init(effect: effect)

        imageView.image = image

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
        [imageView].forEach {
            vibrancyEffectView.contentView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    private func configureConstraints() {
        NSLayoutConstraint.activate([
            contentView.widthAnchor.constraint(equalToConstant: 80),
            contentView.heightAnchor.constraint(equalToConstant: 80),
            vibrancyEffectView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            vibrancyEffectView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            vibrancyEffectView.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            vibrancyEffectView.heightAnchor.constraint(equalTo: contentView.heightAnchor),
            imageView.centerXAnchor.constraint(
                equalTo: vibrancyEffectView.contentView.centerXAnchor
            ),
            imageView.centerYAnchor.constraint(
                equalTo: vibrancyEffectView.contentView.centerYAnchor
            ),
            imageView.widthAnchor.constraint(
                equalTo: vibrancyEffectView.contentView.widthAnchor,
                constant: -20
            ),
            imageView.heightAnchor.constraint(
                equalTo: vibrancyEffectView.contentView.heightAnchor,
                constant: -20
            )
        ])
    }
    private func configureAttributes() {
        layer.cornerRadius = 20
        layer.masksToBounds = true

        imageView.contentMode = .scaleAspectFit
    }
}
