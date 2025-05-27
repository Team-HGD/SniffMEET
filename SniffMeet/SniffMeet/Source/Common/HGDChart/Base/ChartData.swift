//
//  ChartData.swift
//  SniffMeet
//
//  Created by Kelly Chui on 4/19/25.
//

import UIKit

/// 단일 차트 항목을 나타내는 데이터 모델입니다.
///
/// X축에 표시할 `label`과, Y축에 해당하는 `value`를 포함합니다.
struct ChartDataEntry: Hashable {
    let label: String
    let value: CGFloat
}

/// 차트에 표시할 데이터의 집합입니다.
///
/// 차트는 보통 여러 개의 항목(`ChartDataEntry`)을 포함하며,
/// 이 스트럭처는 그 목록과 함께 공통적으로 적용할 색상 정보도 담고 있습니다.
struct ChartDataSet {
    let entries: [ChartDataEntry]
    var color: UIColor
}
