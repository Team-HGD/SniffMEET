//
//  MateListViewController.swift
//  SniffMeet
//
//  Created by Kelly Chui on 11/21/24.
//
import Combine
import UIKit

protocol MateListViewable: AnyObject {
    var presenter: (any MateListPresentable)? { get set }
    func changeMPCButtonState(to buttonState: AddMateButton.ButtonState)
}

final class MateListViewController: BaseViewController, MateListViewable {
    var presenter: (any MateListPresentable)?
    private var mateCellDictionary: [UUID: UITableViewCell] = [:] // [mateID: Cell]
    private var imageDataSource: [UUID: Data] = [:] // [mateID: mate의 profileImage Data]
    private var cancellables: Set<AnyCancellable> = []
    private let tableView: UITableView = UITableView()
    private let addMateButton = AddMateButton(title: "새 메이트를 연결하세요")

    override func viewWillAppear(_ animated: Bool) {
        presenter?.viewWillAppear()
        super.viewWillAppear(animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(showSentAlert),
            name: .init(rawValue: "requestWalk"),
            object: nil
        )
    }

    override func configureAttributes() {
        navigationItem.title = Context.title
        setTableView()
    }

    override func configureHierachy() {
        view.addSubview(tableView)
        view.addSubview(addMateButton)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        addMateButton.translatesAutoresizingMaskIntoConstraints = false
    }

    override func configureConstraints() {
        let constraints = [
            tableView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor
            ),
            tableView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor
            ),
            tableView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            ),
            tableView.bottomAnchor.constraint(
                equalTo: view.bottomAnchor
            ),
            addMateButton.centerXAnchor.constraint(
                equalTo: view.centerXAnchor
            ),
            addMateButton.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -20
            )
        ]
        NSLayoutConstraint.activate(constraints)
    }

    override func bind() {
        presenter?.output.mates
            .receive(on: RunLoop.main)
            .sink { [weak self] mates in
                self?.tableView.reloadData()
                self?.addMateButton.buttonState = .normal
            }
            .store(in: &cancellables)
        presenter?.output.profileImageData
            .receive(on: RunLoop.main)
            .sink { [weak self] (mateID, imageData) in
                self?.imageDataSource[mateID] = imageData
                guard let cell = self?.mateCellDictionary[mateID],
                      let imageData,
                      let profileImage = UIImage(data: imageData) else { return }
                cell.configure(image: profileImage)
            }
            .store(in: &cancellables)
        addMateButton.publisher(event: .touchUpInside)
            .throttle(for: .seconds(EventConstant.throttleInterval),
                      scheduler: RunLoop.main,
                      latest: false)
            .sink { [weak self] _ in
                self?.addMateButton.buttonState = .connecting
                self?.presenter?.startProfileDrop()
            }
            .store(in: &cancellables)
    }
    
    @objc private func showSentAlert() {
        showSNMTextAndImageToast(
            image: UIImage(systemName: "paperplane.fill"),
            text: "전송 완료!",
            animationType: .slideDown
        )
    }

    private func setTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Identifier.mateCellID)
        tableView.separatorStyle = .none
    }
    
    func changeMPCButtonState(to buttonState: AddMateButton.ButtonState) {
        addMateButton.buttonState = buttonState
    }
}

// MARK: - MateListViewController+UITableViewDelegate & UITableViewDataSource

extension MateListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter?.output.mates.value.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: Identifier.mateCellID,
            for: indexPath
        )
        cell.configure(
            image: UIImage.app,
            maximumSize: ItemSize.profileImageSize,
            cornerRadius: ItemSize.profileImageCornerRadius
        )
        if let mate = presenter?.output.mates.value[indexPath.row] {
            if let prev = mateCellDictionary.keys.first(where: { mateCellDictionary[$0] === cell }) {
                mateCellDictionary[prev] = nil
            }
            mateCellDictionary[mate.userID] = cell // 현재 사용하고 있는 cell의 참조값을 저장합니다.
            configureMateListCell(cell: cell, mate: mate)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        ItemSize.cellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // TODO: 에러를 어떻게 전달해야 할까요? Result 타입을 쓰는게 좋을까요?
        guard let mate = presenter?.output.mates.value[indexPath.row] else {return }
        presenter?.didTabMateListCell(mate: mate)
    }

    private func configureMateListCell(cell: UITableViewCell, mate: Mate) {
        if let imageData = imageDataSource[mate.userID],
           let profileImage = UIImage(data: imageData) {
            cell.configure(image: profileImage)
        }
        cell.configure(text: mate.name)
        cell.selectionStyle = .none
    }
}

// MARK: - MateListViewController+UIScrollViewDelegate

extension MateListViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y - 50 >
            scrollView.contentSize.height - scrollView.frame.height {
            presenter?.didScrollToBottom()
        }
    }
}

// MARK: - MateListViewController+Context

extension MateListViewController {
    private enum Context {
        static let title = "메이트"
        static let primaryButtonLabel = "메이트 연결하기"
        static let accessoryButtonLabel = "산책 신청하기"
    }

    private enum Identifier {
        static let mateCellID = "mateCellID"
    }

    private enum ItemSize {
        static let profileImageSize = CGSize(width: 60, height: 60)
        static let profileImageCornerRadius: CGFloat = 30
        static let accessoryButtonSize = CGSize(width: 100, height: 30)
        static let cellHeight: CGFloat = 70
    }
}

// MARK: - UIViewControllerTransitioningDelegate

extension MateListViewController: UIViewControllerTransitioningDelegate {
    func presentationController(
        forPresented presented: UIViewController,
        presenting: UIViewController?,
        source: UIViewController
    ) -> UIPresentationController? {
        CardPresentationController(presentedViewController: presented, presenting: presenting)
    }
}
