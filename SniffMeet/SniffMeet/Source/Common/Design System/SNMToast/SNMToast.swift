//
//  SNMToast.swift
//  SniffMeet
//
//  Created by Kelly Chui on 12/5/24.
//

import UIKit

protocol SNMToast: UIView {
    var animationType: any SNMAnimationType { get }
    func configureConstraints(rootView: UIView, toastView: any SNMToast)
    /// - Note: 해당 메서드를 실행하기 전에
    /// [configureConstraints(rootView:toastView:)](configureConstraints(rootView:toastView:))가 호출되어야 합니다.
    func show(
        in view: UIView?,
        completion: ((Bool) -> Void)?
    )
    func hidden(
        duration: TimeInterval?,
        delay: TimeInterval?,
        options: UIView.AnimationOptions?,
        completion: ((Bool) -> Void)?
    )
}

extension SNMToast {
    func configureConstraints(rootView: UIView, toastView: any SNMToast) {
        translatesAutoresizingMaskIntoConstraints = false
        rootView.addSubview(self)

        let constraints = animationType.location.constraints(
            rootView: rootView,
            toastView: self
        )
        NSLayoutConstraint.activate(constraints)
    }
    func show(in rootView: UIView?, completion: ((Bool) -> Void)? = nil) {
        guard let rootView else { return }
        configureConstraints(rootView: rootView, toastView: self)

        UIView.animate(
            withDuration: animationType.duration,
            delay: animationType.delay,
            options: animationType.options,
            animations: { [weak self] in
                guard let self else { return }
                self.alpha = 1
                self.transform = animationType.beforeTransform
            },
            completion: { [weak self] isFinished in
                guard let self else { return }
                self.animationType.onComplete(toastView: self, isFinished: isFinished)
                completion?(isFinished)
            }
        )
    }
    func hidden(
        duration: TimeInterval? = nil,
        delay: TimeInterval? = nil,
        options: UIView.AnimationOptions? = nil,
        completion: ((Bool) -> Void)? = nil
    ) {
        UIView.animate(
            withDuration: duration ?? animationType.duration,
            delay: delay ?? animationType.delay,
            options: options ?? animationType.options,
            animations: { [weak self] in
                guard let self = self else { return }
                self.alpha = 0
                self.transform = animationType.afterTransform
            },
            completion: { [weak self] isFinished in
                guard let self else { return }
                self.removeFromSuperview()
                completion?(isFinished)
            }
        )
    }
}
