//
//  ChartAxisDecorationView.swift
//  SniffMeet
//
//  Created by Kelly Chui on 5/14/25.
//

import UIKit

/// 차트의 축(Axis)을 그리는 데코레이션 뷰입니다.
///
/// `UICollectionViewCompositionalLayout`에서 Decoration View로 등록되어,
/// X축과 Y축 선을 그려 시각적으로 축을 표시하는 역할을 합니다.
final class ChartAxisDecorationView: UICollectionReusableView {
    
    // MARK: Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Drawing
    /// 축 라인을 직접 그리는 메서드입니다.
    ///
    /// - Parameter rect: 뷰의 전체 영역
    ///
    /// X축은 하단에서 `labelHeight`만큼 위쪽에,
    /// Y축은 왼쪽 끝에서 1pt 오른쪽에 위치하도록 그려집니다.
    /// 0.5pt 보정은 픽셀 정렬을 위한 것입니다.
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.setStrokeColor(UIColor.label.cgColor)
        context.setLineWidth(1)
        
        // X축 선: 0.5 보정으로 픽셀 정렬
        let xAxisY = rect.maxY - 16 + 0.5
        context.move(to: CGPoint(x: rect.minX, y: xAxisY))
        context.addLine(to: CGPoint(x: rect.maxX, y: xAxisY))
        context.strokePath()

        // Y축 선: 0.5 보정으로 픽셀 정렬
        let yAxisX = rect.minX + 0.5
        context.move(to: CGPoint(x: yAxisX, y: rect.minY))
        context.addLine(to: CGPoint(x: yAxisX, y: rect.maxY))
        context.strokePath()
    }
}
