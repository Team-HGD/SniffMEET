//
//  SettingViewController.swift
//  SniffMeet
//
//  Created by 배현진 on 3/19/25.
//

import UIKit

protocol PreferencesViewable: AnyObject {
    var presenter: (any PreferencesPresentable)? { get set }
}

final class PreferencesViewController: BaseViewController, PreferencesViewable {
    var presenter: (any PreferencesPresentable)?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func configureAttributes() {
        configureNavigationControllerAttributes()
    }
    
    private func configureNavigationControllerAttributes() {
        navigationController?.navigationBar.configureBackButton()
        navigationItem.title = Context.title
        navigationItem.largeTitleDisplayMode = .never
    }

    override func configureHierachy() {
    }

    override func configureConstraints() {
    }

    override func bind() {
    }
}

private extension PreferencesViewController {
    enum Context {
        static let title: String = "설정"
    }
}
