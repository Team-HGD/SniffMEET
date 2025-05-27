//
//  YAxisTickCell.swift
//  SniffMeet
//
//  Created by Kelly Chui on 5/14/25.
//

import UIKit

/// Y축 눈금 레이블을 표시하는 셀입니다.
///
/// `UICollectionView`를 통해 Y축 방향으로 눈금을 표시할 때 사용됩니다.
/// 주로 차트의 왼쪽에 고정된 형태로 위치하며, 각 셀은 눈금 값 하나를 담당합니다.
final class YAxisTickCell: UICollectionViewCell {
    /// 눈금 값을 표시하는 레이블
    private let label = UILabel()
    
    // MARK: Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View Setup

    /// UI 요소를 구성합니다.
    ///
    /// 레이블의 폰트, 색상, 정렬을 설정하고 서브뷰에 추가합니다.
    private func setupViews() {
        label.font = .systemFont(ofSize: 10)
        label.textColor = .secondaryLabel
        label.textAlignment = .right
        contentView.addSubview(label)
    }
    /// 오토 레이아웃 제약을 설정합니다.
    ///
    /// 레이블은 셀의 상단에 위치하며 좌우로 꽉 차게 배치됩니다.
    private func setupConstraints() {
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            label.topAnchor.constraint(equalTo: contentView.topAnchor)
        ])
    }
    

    // MARK: Configuration

    /// 눈금 값을 적용합니다.
    ///
    /// - Parameter value: Y축에 표시할 숫자 값. 정수로 포맷됩니다.
    func configure(with value: CGFloat) {
        label.text = String(format: "%.0f", value)
    }
}
