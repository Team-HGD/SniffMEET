//
//  DimPresentable.swift
//  SniffMeet
//
//  Created by sole on 2/17/25.
//

import UIKit

protocol DimPresentable: UIView {
    var dimView: UIView? { get set }
    func makeDimView() -> UIView
    func configureConstraints(toastView: any SNMToast)
    func present()
    func dismiss()
}

// MARK: - Default DimPresentable

extension DimPresentable {
    func makeDimView() -> UIView {
        let dimView = UIView()
        dimView.backgroundColor = UIColor.systemGray.withAlphaComponent(0.6)
        return dimView
    }
    func configureConstraints(toastView: any SNMToast) {
        guard let rootView = UIApplication.shared.keyWindow else {
            return
        }
        dimView = makeDimView()
        guard let dimView else { return }
        dimView.translatesAutoresizingMaskIntoConstraints = false
        toastView.translatesAutoresizingMaskIntoConstraints = false
        rootView.addSubview(dimView)
        dimView.addSubview(toastView)

        NSLayoutConstraint.activate([
            dimView.topAnchor.constraint(equalTo: rootView.topAnchor),
            dimView.bottomAnchor.constraint(equalTo: rootView.bottomAnchor),
            dimView.leadingAnchor.constraint(equalTo: rootView.leadingAnchor),
            dimView.trailingAnchor.constraint(equalTo: rootView.trailingAnchor),
        ])
        let constraints = toastView.animationType.location.constraints(
            rootView: dimView,
            toastView: self
        )
        NSLayoutConstraint.activate(constraints)
    }
    func present() {
        dimView?.alpha = 1
    }
    func dismiss() {
        dimView?.alpha = 0
        dimView?.removeFromSuperview()
    }
}
