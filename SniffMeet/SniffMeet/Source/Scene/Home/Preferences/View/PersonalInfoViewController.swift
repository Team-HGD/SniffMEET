//
//  PersonalInfoViewController.swift
//  SniffMeet
//
//  Created by 배현진 on 3/23/25.
//

import UIKit

protocol PersonalInfoViewable: AnyObject {
    var presenter: (any PersonalInfoPresentable)? { get set }
}

final class PersonalInfoViewController: BaseViewController, PersonalInfoViewable {
    var presenter: (any PersonalInfoPresentable)?
    var personalInfoptions: [PersonalInfoOption] = []
    private var personalInfoTableView: UITableView = UITableView()

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
        view.addSubview(personalInfoTableView)
        personalInfoTableView.translatesAutoresizingMaskIntoConstraints = false
    }

    override func configureConstraints() {
        NSLayoutConstraint.activate([
            personalInfoTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            personalInfoTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            personalInfoTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            personalInfoTableView.bottomAnchor.constraint(
                equalTo: view.bottomAnchor,
                constant: -Context.marginTableViewToView)
        ])
    }

    override func bind() {
    }
    
    private func setTableView() {
        personalInfoptions = presenter?.getOptions() ?? []
        personalInfoTableView.delegate = self
        personalInfoTableView.dataSource = self
        personalInfoTableView.separatorStyle = .none
        personalInfoTableView.register(UITableViewCell.self, forCellReuseIdentifier: Context.personalInfoCellID)
        personalInfoTableView.reloadData()
    }
}

extension PersonalInfoViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return personalInfoptions.count
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: Context.personalInfoCellID,
            for: indexPath)
        let option = personalInfoptions[indexPath.row]
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
        let option = personalInfoptions[indexPath.row]
        presenter?.didSelectOption(option.type)
    }
    
}

private extension PersonalInfoViewController {
    enum Context {
        static let title: String = "개인정보 수정"
        static let personalInfoCellID: String = "personalInfoCell"
        
        static let cellHeight: CGFloat = 60
        static let marginTableViewToView: CGFloat = 400
    }
}
