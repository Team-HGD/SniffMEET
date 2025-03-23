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
    var settingsOptions: [PreferencesOption] = []
    private var tableView: UITableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func configureAttributes() {
        configureNavigationControllerAttributes()
        setTableView()
    }
    
    private func configureNavigationControllerAttributes() {
        navigationController?.navigationBar.configureBackButton()
        navigationItem.title = Context.title
        navigationItem.largeTitleDisplayMode = .never
    }

    override func configureHierachy() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
    }

    override func configureConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -Context.marginTableViewToView)
        ])
    }

    override func bind() {
    }
    
    private func setTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Context.preferenceCellID)
        tableView.separatorStyle = .none
        settingsOptions = presenter?.getSettingsOptions() ?? []
        tableView.reloadData()
    }
}

extension PreferencesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingsOptions.count
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: Context.preferenceCellID,
            for: indexPath)
        let option = settingsOptions[indexPath.row]
        cell.textLabel?.text = option.title
        return cell
    }
    
    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        return Context.cellHeight
    }
    
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        let option = settingsOptions[indexPath.row]
        presenter?.didSelectPreferenceOption(option.type)
    }
    
}

private extension PreferencesViewController {
    enum Context {
        static let title: String = "설정"
        static let versionInfo: String = "버전 정보 "
        static let preferenceCellID: String = "PreferenceCell"
        
        static let cellHeight: CGFloat = 60
        static let marginTableViewToView: CGFloat = 400
    }
}
