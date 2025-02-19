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
    /// - Attention: Dim을 사용하는 경우(isDim이 true인 경우) 뷰를 빠져나갈 때 명시적으로 hidden 메서드를 반드시 호출해야 합니다.
    func show(
        in view: UIView?,
        completion: ((Bool) -> Void)?,
        isDim: Bool
    )
    func hidden(
        duration: TimeInterval?,
        delay: TimeInterval?,
        options: UIView.AnimationOptions?,
        completion: ((Bool) -> Void)?
    )
}

// MARK: - SNMToast Default 

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
    func show(in rootView: UIView?, completion: ((Bool) -> Void)? = nil, isDim: Bool = false) {
        guard let rootView else { return }
        if isDim, let dimPresentableToast = self as? DimPresentable {
            dimPresentableToast.configureConstraints(toastView: self)
        } else {
            configureConstraints(rootView: rootView, toastView: self)
        }

        UIView.animate(
            withDuration: animationType.duration,
            delay: animationType.delay,
            options: animationType.options,
            animations: { [weak self] in
                guard let self else { return }
                self.alpha = 1
                self.transform = animationType.beforeTransform
                if let dimPresentableToast = self as? DimPresentable {
                    dimPresentableToast.present()
                }
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
                guard let self else { return }
                self.alpha = 0
                self.transform = animationType.afterTransform
                if let dimPresentableToast = self as? DimPresentable {
                    dimPresentableToast.dimView?.alpha = 0
                }
            },
            completion: { [weak self] isFinished in
                guard let self else { return }
                self.removeFromSuperview()
                if let dimPresentableToast = self as? DimPresentable {
                    dimPresentableToast.dismiss()
                }
                completion?(isFinished)
            }
        )
    }
}
