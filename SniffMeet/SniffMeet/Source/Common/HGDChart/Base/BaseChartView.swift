//
//  BaseChartView.swift
//  SniffMeet
//
//  Created by Kelly Chui on 4/19/25.
//

import UIKit

/// 차트를 그리기 위한 베이스 뷰
///
/// 다양한 차트 뷰의 슈퍼 클래스 역할을 합니다.
/// 공통적으로 사용하는 데이터 셋, 레이아웃, 그리고 데이터 값 범위 계산 기능을 제공합니다.
class BaseChartView: UIView {
    /// 차트를 그리기 위한 데이터 셋
    ///
    /// `dataSet`이 변경되면 차트가 다시 그려지게 됩니다.
    var dataSet: ChartDataSet? {
        didSet {
            setNeedsDisplay()
        }
    }
    /// 차트 상단 여백
    let topPadding: CGFloat = 16
    /// 차트 하단 여백
    let bottomPadding: CGFloat = 24
    /// 데이터 셋에서 가장 큰 값을 리턴합니다.
    ///
    /// y축의 높이를 계산할 때 사용됩니다.
    ///
    /// - Returns: 데이터 셋 내 최대 값. 데이터가 없으면 0 리턴
    var maxValue: CGFloat {
        dataSet?.entries.map { $0.value }.max() ?? 0
    }
}

