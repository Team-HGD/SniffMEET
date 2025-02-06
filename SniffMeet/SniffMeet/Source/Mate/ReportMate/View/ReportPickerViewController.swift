//
//  ReportPickerViewController.swift
//  SniffMeet
//
//  Created by 배현진 on 2/6/25.
//

import UIKit

protocol ReportPickerViewable: AnyObject {
//    var presenter: (any ReportPickerPresentable)? { get set }
}

final class ReportPickerViewController: UIViewController, ReportPickerViewable {
//    var presenter: (any ReportPickerPresentable)?
    var options: [String] = ["산책 시 폭력적인 행동", "불쾌한 언행", "기타"]
    var didSelectOption: ((String) -> Void)?

    private let tableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupTableView()
    }

    private func setupView() {
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        preferredContentSize = .init(width: 300, height: 300)
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.frame = view.bounds
        view.addSubview(tableView)
    }
}

extension ReportPickerViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.textLabel?.text = options[indexPath.row]
        cell.textLabel?.textAlignment = .center
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        didSelectOption?(options[indexPath.row])
        dismiss(animated: true)
    }
}
