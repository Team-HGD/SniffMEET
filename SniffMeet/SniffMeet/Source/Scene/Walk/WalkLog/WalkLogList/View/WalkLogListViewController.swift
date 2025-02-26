//
//  WalkLogListViewController.swift
//  SniffMeet
//
//  Created by sole on 11/24/24.
//

import UIKit

protocol WalkLogListViewable: AnyObject {
    var presenter: (any WalkLogListPresentable)? { get }
}

final class WalkLogListViewController: BaseViewController, WalkLogListViewable {
    var presenter: (any WalkLogListPresentable)?
    private let walkLogTableView: UITableView = UITableView()

    override func configureAttributes() {
        walkLogTableView.dataSource = self
        walkLogTableView.delegate = self
        walkLogTableView.separatorInset = .zero
    }
    override func configureHierachy() {
        [walkLogTableView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }
    override func configureConstraints() {
        NSLayoutConstraint.activate([
            walkLogTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            walkLogTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            walkLogTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            walkLogTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
}

//MARK: - WalkLogListViewController+UITableView DataSource, Delegate

extension WalkLogListViewController: UITableViewDataSource {
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        3
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = WalkLogCell(style: .default, reuseIdentifier: WalkLogCell.identifier)
        return cell
    }
}

extension WalkLogListViewController: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        393
    }
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
