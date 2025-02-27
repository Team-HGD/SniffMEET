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

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.viewDidLoad()
    }

    override func configureAttributes() {
        walkLogTableView.dataSource = self
        walkLogTableView.delegate = self
        walkLogTableView.separatorInset = .zero
        walkLogTableView.allowsSelection = false
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

    private func distanceLabelString(_ meters: Double) -> String {
        String(format: "%.2f km", meters / 1000)
    }
    private func dateLabelString(_ date: Date) -> String {
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 MM월 dd일"
        return dateFormatter.string(from: date)
    }
    private func durationLabelString(_ timeInterval: TimeInterval) -> String {
        let totalSeconds = Int(timeInterval)
        let hours = totalSeconds / (60 * 60)
        let minutes = (totalSeconds / 60) % 60
        let seconds = Int(totalSeconds) % 60

        return hours > 0 ? "\(hours)시간 \(minutes)분" : "\(minutes)분 \(seconds)초"
    }
}

//MARK: - WalkLogListViewController+UITableView DataSource, Delegate

extension WalkLogListViewController: UITableViewDataSource {
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        presenter?.output.walkLogList.count ?? 0
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell: WalkLogCell = walkLogTableView.dequeueReusableCell(
            withIdentifier: WalkLogCell.identifier
        ) as? WalkLogCell ?? WalkLogCell(style: .default, reuseIdentifier: WalkLogCell.identifier)
        let walkLogs: [WalkLog] = presenter?.output.walkLogList ?? []

        cell.configureWalkLogSection(
            date: dateLabelString(walkLogs[indexPath.row].endDate),
            distance: distanceLabelString(walkLogs[indexPath.row].distance),
            step: "\(walkLogs[indexPath.row].step) 걸음",
            duration: durationLabelString(walkLogs[indexPath.row].duration),
            image: UIImage(
                data: walkLogs[indexPath.row].image ?? Data()
            )
        )
        cell.configureProfileSection(
            profileImage: UIImage(
                data: presenter?.output.profileImageData ?? Data()
            ),
            name: presenter?.output.name ?? "후추추"
        )

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
}
