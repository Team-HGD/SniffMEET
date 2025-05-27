//
//  BarChartCell.swift
//  SniffMeet
//
//  Created by Kelly Chui on 4/20/25.
//

import UIKit


/// 차트의 막대(bar)와 X축 레이블을 표시하는 셀입니다.
///
/// `UICollectionView`를 통해 차트 형태로 표현되는 각 항목을 렌더링할 때 사용됩니다.
/// 내부에는 막대 그래프를 나타내는 `barView`와 X축 레이블을 위한 `xAxisLabel`을 포함합니다.
final class BarChartCell: UICollectionViewCell {
    /// 막대 그래프를 그리는 뷰
    private let barView = UIView()
    /// X축 레이블을 표시하는 라벨
    private let xAxisLabel = UILabel()
    /// 막대의 높이를 조정하는 제약 조건
    private var barHeightConstraint: NSLayoutConstraint!
    
    // MARK: Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View Setup
    /// 셀의 서브 뷰들을 초기화합니다.
    private func setupViews() {
        barView.backgroundColor = .systemBlue
        barView.layer.cornerRadius = 4
        barView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        xAxisLabel.font = .systemFont(ofSize: 10)
        xAxisLabel.textAlignment = .center
        xAxisLabel.textColor = .secondaryLabel
        contentView.addSubview(barView)
        contentView.addSubview(xAxisLabel)
    }
    /// 셀 내부의 오토 레이아웃 제약을 설정합니다.
    private func setupConstraints() {
        barView.translatesAutoresizingMaskIntoConstraints = false
        xAxisLabel.translatesAutoresizingMaskIntoConstraints = false
        barHeightConstraint = barView.heightAnchor.constraint(equalToConstant: 0)
        barHeightConstraint.isActive = true
        NSLayoutConstraint.activate([
            barView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            barView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.7),
            barView.bottomAnchor.constraint(equalTo: xAxisLabel.topAnchor), // , constant: -4),
            xAxisLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            xAxisLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            xAxisLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            xAxisLabel.heightAnchor.constraint(equalToConstant: 16)
        ])
    }
    
    // MARK: Config
    /// 셀을 구성합니다.
    ///
    /// - Parameters:
    ///   - entry: 막대 차트 항목 데이터
    ///   - maxValue: 전체 데이터에서의 최대값 (막대 높이 비율 계산에 사용)
    func configure(with entry: ChartDataEntry, maxValue: CGFloat) {
        let ratio = maxValue > 0 ? entry.value / maxValue : 0
        let availableHeight = contentView.frame.height - 16
        barHeightConstraint.constant = availableHeight * ratio
        xAxisLabel.text = entry.label
    }
}
