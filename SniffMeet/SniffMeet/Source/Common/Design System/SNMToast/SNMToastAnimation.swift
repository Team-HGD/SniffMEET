//
//  SNMAnimationType.swift
//  SniffMeet
//
//  Created by sole on 2/16/25.
//

import UIKit

enum SNMToastAnimation {
    case slideUp
    case slideDown
    case showAtCenter
}

extension SNMToastAnimation: SNMAnimationType {
    var location: AnimateLocation {
        switch self {
        case .slideUp: .bottom
        case .slideDown: .top
        case .showAtCenter: .center
        }
    }

    var beforeTransform: CGAffineTransform {
        switch self {
        case .slideUp:
            CGAffineTransform(translationX: 0, y: -60)
        case .slideDown:
            CGAffineTransform(translationX: 0, y: 60)
        case .showAtCenter:
            CGAffineTransform.identity
        }
    }

    var afterTransform: CGAffineTransform {
        beforeTransform.inverted()
    }

    var duration: TimeInterval {
        1
    }

    var delay: TimeInterval {
        0
    }

    var options: UIView.AnimationOptions {
        [.curveEaseInOut]
    }

    func onComplete(toastView: any SNMToast, isFinished: Bool) {
        switch self {
        case .slideUp, .slideDown:
            toastView.hidden(duration: 2)
        case .showAtCenter:
            break
        }
    }
}
