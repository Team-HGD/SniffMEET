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
    var preferencesOptions: [PreferencesOption] = []
    private var preferencesTableView: UITableView = UITableView()
    private var versionInfoLabel: UILabel = {
        let label = UILabel()
        label.text = Context.versionInfo
        label.textColor = SNMColor.subGray2
        label.font = SNMFont.caption
        label.textAlignment = .right
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        configureNavigationControllerAttributes()
    }

    override func configureAttributes() {
        setTableView()
        setVersionInfo()
    }
    
    private func configureNavigationControllerAttributes() {
        navigationController?.navigationBar.configureBackButton()
        navigationItem.title = Context.title
        navigationItem.largeTitleDisplayMode = .never
    }

    override func configureHierachy() {
        [preferencesTableView,
         versionInfoLabel].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }

    override func configureConstraints() {
        NSLayoutConstraint.activate([
            preferencesTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            preferencesTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            preferencesTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            preferencesTableView.bottomAnchor.constraint(
                equalTo: view.bottomAnchor,
                constant: -Context.marginTableViewToView),
            versionInfoLabel.topAnchor.constraint(equalTo: preferencesTableView.bottomAnchor),
            versionInfoLabel.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: LayoutConstant.horizontalPadding),
            versionInfoLabel.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -LayoutConstant.horizontalPadding)
        ])
    }

    override func bind() {
    }
    
    private func setTableView() {
        preferencesOptions = presenter?.getOptions() ?? []
        preferencesTableView.delegate = self
        preferencesTableView.dataSource = self
        preferencesTableView.separatorStyle = .none
        preferencesTableView.register(UITableViewCell.self, forCellReuseIdentifier: Context.preferenceCellID)
        preferencesTableView.reloadData()
    }
    
    private func setVersionInfo() {
        guard let dictionary = Bundle.main.infoDictionary,
        let version = dictionary["CFBundleShortVersionString"] as? String else { return }
        versionInfoLabel.text = Context.versionInfo + version
    }
}

extension PreferencesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return preferencesOptions.count
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: Context.preferenceCellID,
            for: indexPath)
        let option = preferencesOptions[indexPath.row]
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
        let option = preferencesOptions[indexPath.row]
        presenter?.didSelectOption(option.type)
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
