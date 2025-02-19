//
//  SNMProgressView.swift
//  SniffMeet
//
//  Created by sole on 2/16/25.
//

import UIKit

final class SNMProgressView: BaseView, SNMToast, DimPresentable {
    var dimView: UIView?
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
            backgroundView.centerXAnchor.constraint(equalTo: centerXAnchor),
            backgroundView.centerYAnchor.constraint(equalTo: centerYAnchor),
            backgroundView.widthAnchor.constraint(equalToConstant: 120),
            backgroundView.heightAnchor.constraint(equalToConstant: 120),
            activityIndicatorView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 30),
            activityIndicatorView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -30),
            activityIndicatorView.topAnchor.constraint(equalTo: topAnchor, constant: 30),
            activityIndicatorView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -30)
        ])
    }
    override func configureAttributes() {
        layer.cornerRadius = 20
        layer.masksToBounds = true

        activityIndicatorView.style = .large
        activityIndicatorView.startAnimating()
    }
}
