//
//  AxesBasedChartView.swift
//  SniffMeet
//
//  Created by Kelly Chui on 4/19/25.
//

import UIKit

/// 축(Axis)과 레이블(Label)을 그리는 차트 베이스 뷰입니다.
///
/// Y축 눈금, X축 레이블을 표시하고, 축 라인을 그리는 기능을 제공합니다.
/// BarChart, LineChart 등 다양한 차트 뷰의 기반 클래스로 사용할 수 있습니다.
class AxesBasedChartView: BaseChartView {
    // MARK: Data
    /// 차트에 표시할 데이터 항목 배열
    private var entries: [ChartDataEntry] = []
    /// Y축 눈금에 사용할 값 배열
    private var yAxisValues: [CGFloat] = []
    
    // MARK: Layout Config
    /// 한 화면에 표시할 아이템 수
    var pagingItemCount: Int = 7
    /// Y축 눈금의 개수
    var tickCount: Int = 3
    // 이 아래 값들은 Compositional Layout에서 Decoration View의 한계로 이 부분은 커스텀이 힘들 것 같습니다.
    // 지금처럼 고정 값을 쓰거나, Decoration View를 포기하고 UIView를 쓰거나 혹은 Static var를 쓸수 있을 것 같은데...
    /// Y축 레이블 영역의 고정 폭
    private let yAxisLabelWidth: CGFloat = 30
    /// Y축 레이블과 축 사이의 간격
    private let yAxisLabelPadding: CGFloat = 4
    /// X축 레이블의 높이
    private let labelHeight: CGFloat = 16
    
    // MARK: Style
    /// 축 색상
    var axisLineColor: UIColor = .label
    /// 축 두께
    var axisLineWidth: CGFloat = 1
    /// Y축 눈금 색상
    var tickLineColor: UIColor = .systemGray4
    /// X축 레이블 폰트
    var labelFont: UIFont = .systemFont(ofSize: 10)
    /// X축 레이블 색상
    var labelColor: UIColor = .label
    /// Y축 눈금 레이블 폰트
    var valueFont: UIFont = .systemFont(ofSize: 10)
    /// Y축 눈금 레이블 색상
    var valueColor: UIColor = .label
    
    // MARK: SubViews
    /// 차트 데이터를 렌더링하는 컬렉션 뷰
    private var chartCollectionView: UICollectionView!
    /// Y축 눈금을 표시하는 컬렉션 뷰
    private var yAxisCollectionView: UICollectionView!
    
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
    
    // MARK: Layout
    /// 차트 아이템과 축이 포함된 Compositional Layout을 생성합니다.
    private func createLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionIndex, environment in
            guard let self = self else {
                return self?.emptySectionWithAxis()
            }
            guard pagingItemCount > 0 else {
                return emptySectionWithAxis()
            }
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0 / CGFloat(pagingItemCount)),
                heightDimension: .fractionalHeight(1.0)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0)
            )
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: groupSize,
                subitem: item,
                count: pagingItemCount
            )
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .paging
            let axisDecoration = NSCollectionLayoutDecorationItem.background(elementKind: "ChartAxisDecoration")
            section.decorationItems = [axisDecoration]
            return section
        }

        layout.register(ChartAxisDecorationView.self, forDecorationViewOfKind: "ChartAxisDecoration")
        return layout
    }
    
    /// 축만 있는 빈 레이아웃을 생성합니다.
    private func emptySectionWithAxis() -> NSCollectionLayoutSection {
        let emptyGroupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        let emptyGroup = NSCollectionLayoutGroup.horizontal(
            layoutSize: emptyGroupSize,
            subitems: []
        )
        let section = NSCollectionLayoutSection(group: emptyGroup)
        let axisDecoration = NSCollectionLayoutDecorationItem.background(elementKind: "ChartAxisDecoration")
        section.decorationItems = [axisDecoration]
        return section
    }
    
    /// 차트 컬렉션 뷰, Y축 컬렉션 뷰를 초기화하고 셀을 등록합니다.
    private func setupViews() {
        setupChartCollectionView()
        setupYAxisCollectionView()
        addSubview(chartCollectionView)
        addSubview(yAxisCollectionView)
    }
    
    private func setupChartCollectionView() {
        let layout = createLayout()
        chartCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        chartCollectionView.backgroundColor = .clear
        chartCollectionView.showsHorizontalScrollIndicator = false
        chartCollectionView.showsVerticalScrollIndicator = false
        chartCollectionView.isScrollEnabled = true
        chartCollectionView.isUserInteractionEnabled = true
        chartCollectionView.register(BarChartCell.self, forCellWithReuseIdentifier: Identifier.barChartCell)
        chartCollectionView.delegate = self
        chartCollectionView.dataSource = self
    }
    
    private func setupYAxisCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        yAxisCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        yAxisCollectionView.backgroundColor = .clear
        yAxisCollectionView.isScrollEnabled = false
        yAxisCollectionView.showsVerticalScrollIndicator = false
        yAxisCollectionView.dataSource = self
        yAxisCollectionView.delegate = self
        yAxisCollectionView.register(YAxisTickCell.self, forCellWithReuseIdentifier: Identifier.yAxisTickCell)
    }
    
    /// 차트 컬렉션 뷰 및 Y축 컬렉션 뷰의 오토 레이아웃을 설정합니다.
    private func setupConstraints() {
        chartCollectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            chartCollectionView.topAnchor.constraint(equalTo: topAnchor, constant: topPadding),
            chartCollectionView.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: yAxisLabelWidth // + yAxisLabelPadding
            ),
            chartCollectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            chartCollectionView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -bottomPadding)
        ])
        yAxisCollectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            yAxisCollectionView.topAnchor.constraint(equalTo: chartCollectionView.topAnchor),
            yAxisCollectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            yAxisCollectionView.bottomAnchor.constraint(equalTo: chartCollectionView.bottomAnchor),
            yAxisCollectionView.widthAnchor.constraint(equalToConstant: yAxisLabelWidth)
        ])
    }
    
//    /// 화면 크기에 따라 아이템 레이아웃을 동적으로 조정합니다.
//    /// - Parameter rect: 뷰의 크기
//    func updateItemLayout(for rect: CGRect) {
//        
//    }
    
    /// 차트 데이터를 업데이트하고 뷰를 갱신합니다.
    /// - Parameter entries: 표시할 차트 항목 데이터
    func reloadChart(with entries: [ChartDataEntry]) {
        self.entries = entries
        self.dataSet = ChartDataSet(entries: entries, color: .systemBlue)
        let step = maxValue / CGFloat(tickCount)
        yAxisValues = stride(from: maxValue, through: 0, by: -step).map { $0 }
        chartCollectionView.reloadData()
        yAxisCollectionView.reloadData()
        
        Task { @MainActor in
            let index = IndexPath(item: nearestScrollIndex(for: entries.count), section: 0)
            chartCollectionView.scrollToItem(at: index, at: .centeredHorizontally, animated: false)
        }
    }
    
    func nearestScrollIndex(for totalCount: Int) -> Int {
        guard totalCount >= pagingItemCount else { return 0 }
        return (totalCount / pagingItemCount) * pagingItemCount
    }
}

// MARK: - AxesBasedChartView+UICollectionViewDataSource

extension AxesBasedChartView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case chartCollectionView: entries.count
        case yAxisCollectionView: yAxisValues.count
        default: 0
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView {
        case chartCollectionView:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: Identifier.barChartCell,
                for: indexPath
            ) as? BarChartCell
            cell?.configure(with: entries[indexPath.item], maxValue: maxValue)
            return cell ?? UICollectionViewCell()
        case yAxisCollectionView:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: Identifier.yAxisTickCell,
                for: indexPath
            ) as? YAxisTickCell
            cell?.configure(with: yAxisValues[indexPath.item])
            return cell ?? UICollectionViewCell()
        default:
            return UICollectionViewCell()
        }
    }
}

// MARK: - AxesBasedCharView+UICollectionViewDelegateFlowLayout

extension AxesBasedChartView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard collectionView == chartCollectionView else { return }
        let entry = entries[indexPath.item]
        print("\(entry.label) = \(entry.value)")
    }
    
    func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == yAxisCollectionView {
            let height = (chartCollectionView.bounds.height - labelHeight) / CGFloat(yAxisValues.count - 1)
            return CGSize(width: yAxisLabelWidth, height: height)
        }
        return .zero
    }
}

// MARK: - AxesBasedChartView+Constants

extension AxesBasedChartView {
    enum Identifier {
        static let barChartCell = "BarChartCell"
        static let yAxisTickCell = "YAxisTickCell"
    }
}
