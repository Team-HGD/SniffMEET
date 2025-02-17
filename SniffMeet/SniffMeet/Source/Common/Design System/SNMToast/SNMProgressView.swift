//
//  SNMProgressView.swift
//  SniffMeet
//
//  Created by sole on 2/16/25.
//

import UIKit

final class SNMProgressView: BaseView, SNMToast {
    let animationType: any SNMAnimationType
    private let backgroundView: UIVisualEffectView
    private let activityIndicatorView = UIActivityIndicatorView()

    init(
        frame: CGRect = .zero,
        effect: UIVisualEffect = UIBlurEffect(style: .systemMaterial),
        animationType: any SNMAnimationType
    ) {
        self.animationType = animationType
        self.backgroundView = UIVisualEffectView(effect: effect)
        super.init(frame: frame)
    }

    override func configureHierarchy() {
        [backgroundView, activityIndicatorView].forEach {
            addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    override func configureConstraints() {
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: 120),
            heightAnchor.constraint(greaterThanOrEqualToConstant: 120),
            backgroundView.centerXAnchor.constraint(equalTo: centerXAnchor),
            backgroundView.centerYAnchor.constraint(equalTo: centerYAnchor),
            backgroundView.widthAnchor.constraint(equalTo: widthAnchor),
            backgroundView.heightAnchor.constraint(equalTo: heightAnchor),
            activityIndicatorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            activityIndicatorView.trailingAnchor.constraint(equalTo: trailingAnchor),
            activityIndicatorView.topAnchor.constraint(equalTo: topAnchor),
            activityIndicatorView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    override func configureAttributes() {
        layer.cornerRadius = 20
        layer.masksToBounds = true

        activityIndicatorView.style = .large
        activityIndicatorView.startAnimating()
    }
}
