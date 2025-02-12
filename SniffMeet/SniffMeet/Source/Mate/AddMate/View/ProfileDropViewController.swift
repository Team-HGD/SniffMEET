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
    private var contentLabel: UILabel = {
        let label = UILabel()
        label.text = Context.contentLabel
        label.textAlignment = .center
        label.font = SNMFont.body
        label.numberOfLines = 0
        return label
    }()
    private var descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = Context.descriptionLabel
        label.textAlignment = .center
        label.font = SNMFont.caption
        label.numberOfLines = 0
        return label
    }()
    private var contentImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "ImagePlaceholder")!
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    private var autoButton = PrimaryButton(title: Context.autoConnect)
    private var manualButton = PrimaryButton(title: Context.manualConnect)
    private var helpLabel: UILabel = {
        let label = UILabel()
        label.text = Context.help
        label.textColor = .lightGray
        label.textAlignment = .center
        label.font = SNMFont.caption2
        let attributedString = NSMutableAttributedString(string: Context.help)
        attributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSMakeRange(0, attributedString.length))
        label.attributedText = attributedString
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func configureAttributes() {
        configureNavigationControllerAttributes()
        if let gifImageView = createGIFImageView(named: "ProfileDrop") {
            contentImageView.removeFromSuperview()
            contentImageView = gifImageView
            contentImageView.contentMode = .scaleAspectFill
        }
    }
    override func configureHierachy() {
        [contentLabel,
         descriptionLabel,
         contentImageView,
         autoButton,
         manualButton,
         helpLabel].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    override func configureConstraints() {
        setConstraint()
    }
    private func configureNavigationControllerAttributes() {
        navigationController?.navigationBar.configureBackButton()
        navigationItem.title = Context.title
        navigationItem.largeTitleDisplayMode = .never
    }
    private func setConstraint() {
        NSLayoutConstraint.activate([
            contentLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: CGFloat(Context.spacing2)),
            contentLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: LayoutConstant.largeVerticalPadding),
            descriptionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            contentImageView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: CGFloat(Context.spacing)),
            contentImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            autoButton.bottomAnchor.constraint(equalTo: helpLabel.topAnchor, constant: -LayoutConstant.smallVerticalPadding),
            autoButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: LayoutConstant.horizontalPadding),
            autoButton.trailingAnchor.constraint(equalTo: manualButton.leadingAnchor, constant: -LayoutConstant.horizontalPadding),
            manualButton.bottomAnchor.constraint(equalTo: helpLabel.topAnchor, constant: -LayoutConstant.smallVerticalPadding),
            manualButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -LayoutConstant.horizontalPadding),
            helpLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -LayoutConstant.largeVerticalPadding),
            helpLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    override func bind() {
    }
}

private extension ProfileDropViewController {
    enum Context {
        static let autoConnect: String = "자동 연결"
        static let manualConnect: String = "수동 연결"
        static let title: String = "프로필 드랍"
        static let contentLabel: String = "자동 연결을 이용해\n원하는 메이트의 핸드폰과\n아래의 동작을 수행해 간편하게\n프로필을 주고 받을 수 있습니다."
        static let descriptionLabel: String = "만약 상대 기기가 수동 연결만 지원한다면,\n함께 수동 연결을 시도하세요."
        static let connectionLabel: String = "연결 상태 표시"
        static let help: String = "기능 관련 자세한 설명을 원하는 경우"
        static let spacing: Int = 100
        static let spacing2: Int = 200
    }
}

private extension ProfileDropViewController {
    func createGIFImageView(named gifName: String) -> UIImageView? {
        guard let gifPath = Bundle.main.path(forResource: gifName, ofType: "gif"),
              let gifData = try? Data(contentsOf: URL(fileURLWithPath: gifPath)),
              let source = CGImageSourceCreateWithData(gifData as CFData, nil) else {
            return nil
        }

        var images = [UIImage]()
        var duration: Double = 0

        let frameCount = CGImageSourceGetCount(source)
        for frame in 0..<frameCount {
            guard let cgImage = CGImageSourceCreateImageAtIndex(source, frame, nil) else { continue }
            images.append(UIImage(cgImage: cgImage))

            let frameProperties = CGImageSourceCopyPropertiesAtIndex(source, frame, nil) as? [String: Any]
            let gifProperties = frameProperties?[kCGImagePropertyGIFDictionary as String] as? [String: Any]
            let frameDuration = gifProperties?[kCGImagePropertyGIFDelayTime as String] as? Double ?? 0
            duration += frameDuration
        }

        let imageView = UIImageView()
        imageView.animationImages = images
        imageView.animationDuration = duration
        imageView.startAnimating()

        return imageView
    }
}
