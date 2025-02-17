//
//  AnimationType.swift
//  SniffMeet
//
//  Created by sole on 2/17/25.
//

import UIKit

protocol SNMAnimationType {
    var location: AnimateLocation { get }
    var beforeTransform: CGAffineTransform { get }
    var afterTransform: CGAffineTransform { get }
    var duration: TimeInterval { get }
    var delay: TimeInterval { get }
    var options: UIView.AnimationOptions { get }
    func onComplete(toastView: any SNMToast, isFinished: Bool)
}

enum AnimateLocation {
    case top
    case bottom
    case center

    func constraints(rootView: UIView, toastView: UIView) -> [NSLayoutConstraint] {
        switch self {
        case .top:
            [
                toastView.centerXAnchor.constraint(equalTo: rootView.centerXAnchor),
                toastView.topAnchor.constraint(equalTo: rootView.topAnchor)
            ]
        case .bottom:
            [
                toastView.centerXAnchor.constraint(equalTo: rootView.centerXAnchor),
                toastView.bottomAnchor.constraint(equalTo: rootView.bottomAnchor)
            ]
        case .center:
            [
                toastView.centerXAnchor.constraint(equalTo: rootView.centerXAnchor),
                toastView.centerYAnchor.constraint(equalTo: rootView.centerYAnchor)
            ]
        }
    }
}
