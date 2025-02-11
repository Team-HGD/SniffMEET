//
//  ProfileDropViewController.swift
//  SniffMeet
//
//  Created by 배현진 on 2/11/25.
//

import UIKit

protocol ProfileDropViewable: AnyObject {
    var presenter: (any ProfileDropPresentable)? { get set }
}

final class ProfileDropViewController: BaseViewController, ProfileDropViewable {
    var presenter: (any ProfileDropPresentable)?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

}
