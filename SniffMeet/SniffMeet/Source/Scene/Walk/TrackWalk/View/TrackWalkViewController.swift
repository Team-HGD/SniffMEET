//
//  Untitled.swift
//  SniffMeet
//
//  Created by 윤지성 on 2/18/25.
//
import Combine
import MapKit
import UIKit

protocol TrackWalkViewable: AnyObject {
    var presenter: TrackWalkPresentable? { get set }
    
    func updateRouteLine(with location: WalkRoute)
    func updateWalkRecord()
}

final class TrackWalkViewController: BaseViewController, TrackWalkViewable {
    var presenter: (any TrackWalkPresentable)?
    private var cancellables: Set<AnyCancellable> = []
    private var isStarted: Bool = false
    
    private let mapView: MKMapView = {
        let mapView: MKMapView = MKMapView()
        mapView.showsUserLocation = true
        mapView.cameraZoomRange = .init(
            minCenterCoordinateDistance: 1000,
            maxCenterCoordinateDistance: 5000
        )
        return mapView
    }()
    private let bottomView = UIView()
    private let velocityView = UIView()
    private let distanceView = UIView()
    private let timeTitleLabel = UILabel()
    private let timeValueLabel = UILabel()
    private let numberOfStepsTitleLabel = UILabel()
    private let numberOfStepsValueLabel = UILabel()
    private let distanceTitleLabel = UILabel()
    private let distanceValueLabel = UILabel()
    private let trackingButton = UIButton()
    private let firstHorizontalSeparator = UIView()
    private let verticalSeparator = UIView()
    private var routeMapImageView: UIImageView = UIImageView()

    override func viewWillAppear(_ animated: Bool) {
        trackingButton.layoutIfNeeded()
        trackingButton.makeViewCircular()
    }
    
    override func configureAttributes() {
        [timeTitleLabel, numberOfStepsTitleLabel, distanceTitleLabel].forEach {
            $0.textColor = SNMColor.subGray3
            $0.font = SNMFont.callout
            $0.contentMode = .center
        }
        [timeValueLabel, numberOfStepsValueLabel, distanceValueLabel].forEach {
            $0.textColor = SNMColor.subGray3
            $0.font = UIFont.systemFont(ofSize: 25, weight: .medium)
            $0.contentMode = .center
        }
        [firstHorizontalSeparator, verticalSeparator].forEach {
            $0.backgroundColor = SNMColor.text3
        }
        
        bottomView.backgroundColor = .systemBackground
        timeTitleLabel.text = Context.timeTitle
        timeValueLabel.text = Context.defaultTime
        numberOfStepsTitleLabel.text = Context.velocityTitle
        numberOfStepsValueLabel.text = Context.defaultVelocity
        distanceTitleLabel.text = Context.distanceTitle
        distanceValueLabel.text = Context.defaultDistance
        
        trackingButton.setTitle(Context.trackButtonStartTitle, for: .normal)
        trackingButton.setTitleColor(.white, for: .normal)
        trackingButton.backgroundColor = SNMColor.mainNavy
        trackingButton.titleLabel?.font = .systemFont(ofSize: 19, weight: .semibold)
        
        routeMapImageView.isHidden = true
    }
    override func configureHierachy() {
        [mapView, routeMapImageView, bottomView].forEach{
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        [timeTitleLabel, timeValueLabel, velocityView, distanceView].forEach {
            bottomView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        [numberOfStepsTitleLabel, numberOfStepsValueLabel].forEach {
            velocityView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        [distanceTitleLabel, distanceValueLabel].forEach {
            distanceView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        [trackingButton, firstHorizontalSeparator, verticalSeparator].forEach {
            bottomView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    override func configureConstraints() {
        NSLayoutConstraint.activate([
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.bottomAnchor.constraint(equalTo: bottomView.topAnchor),
            
            routeMapImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            routeMapImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            routeMapImageView.topAnchor.constraint(equalTo: view.topAnchor),
            routeMapImageView.bottomAnchor.constraint(equalTo: bottomView.topAnchor),
            
            bottomView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bottomView.heightAnchor.constraint(equalToConstant: 330)
        ])
        NSLayoutConstraint.activate([
            timeTitleLabel.topAnchor.constraint(
                equalTo: bottomView.topAnchor,
                constant: LayoutConstant.regularVerticalPadding),
            timeTitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            timeValueLabel.topAnchor.constraint(
                equalTo: timeTitleLabel.bottomAnchor,
                constant: LayoutConstant.smallVerticalPadding),
            timeValueLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            firstHorizontalSeparator.topAnchor.constraint(
                equalTo: timeValueLabel.bottomAnchor,
                constant: LayoutConstant.smallVerticalPadding),
            firstHorizontalSeparator.heightAnchor.constraint(equalToConstant: 1),
            firstHorizontalSeparator.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: LayoutConstant.largestVerticalPadding),
            firstHorizontalSeparator.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -LayoutConstant.largestVerticalPadding),
            
            verticalSeparator.widthAnchor.constraint(equalToConstant: 1),
            verticalSeparator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            verticalSeparator.heightAnchor.constraint(equalToConstant: 63),
            verticalSeparator.topAnchor.constraint(
                equalTo: firstHorizontalSeparator.bottomAnchor,
                constant: Context.regularVerticalPadding),
            
            velocityView.topAnchor.constraint(
                equalTo: firstHorizontalSeparator.bottomAnchor,
                constant: Context.regularVerticalPadding),
            velocityView.leadingAnchor.constraint(
                equalTo: bottomView.leadingAnchor,
                constant: LayoutConstant.largestVerticalPadding),
            velocityView.trailingAnchor.constraint(equalTo: verticalSeparator.leadingAnchor),
            velocityView.heightAnchor.constraint(equalToConstant: 63),

            distanceView.topAnchor.constraint(
                equalTo: firstHorizontalSeparator.bottomAnchor,
                constant: Context.regularVerticalPadding),
            distanceView.leadingAnchor.constraint(equalTo: verticalSeparator.trailingAnchor),
            distanceView.trailingAnchor.constraint(
                equalTo: bottomView.trailingAnchor,
                constant: -LayoutConstant.largestVerticalPadding),
            distanceView.heightAnchor.constraint(equalToConstant: 63),
            
            trackingButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            trackingButton.widthAnchor.constraint(equalToConstant: 70),
            trackingButton.heightAnchor.constraint(equalToConstant: 70),
            trackingButton.bottomAnchor.constraint(
                equalTo: view.bottomAnchor,
                constant: -LayoutConstant.xlargeVerticalPadding)
        ])
        NSLayoutConstraint.activate([
            numberOfStepsTitleLabel.topAnchor.constraint(equalTo: velocityView.topAnchor),
            numberOfStepsTitleLabel.centerXAnchor.constraint(equalTo: velocityView.centerXAnchor),

            numberOfStepsValueLabel.topAnchor.constraint(
                equalTo: numberOfStepsTitleLabel.bottomAnchor,
                constant: LayoutConstant.edgePadding),
            numberOfStepsValueLabel.centerXAnchor.constraint(equalTo: velocityView.centerXAnchor),
            numberOfStepsValueLabel.bottomAnchor.constraint(equalTo: velocityView.bottomAnchor)
        ])
        NSLayoutConstraint.activate([
            distanceTitleLabel.topAnchor.constraint(equalTo: distanceView.topAnchor),
            distanceTitleLabel.centerXAnchor.constraint(equalTo: distanceView.centerXAnchor),

            distanceValueLabel.topAnchor.constraint(
                equalTo: distanceTitleLabel.bottomAnchor,
                constant: LayoutConstant.edgePadding),
            distanceValueLabel.centerXAnchor.constraint(equalTo: distanceView.centerXAnchor),
            distanceValueLabel.bottomAnchor.constraint(equalTo: distanceView.bottomAnchor)
        ])
    }
    
    override func bind() {
        trackingButton.publisher(event: .touchUpInside)
            .sink { [weak self] _ in
                guard self?.isStarted == true else {
                    self?.isStarted = true
                    self?.presenter?.startTracking()
                    return
                }
                Task { @MainActor in
                    await self?.stopRecordWalk()
                }
            }
            .store(in: &cancellables)
    }
}

extension TrackWalkViewController {
    func updateRouteLine(with location: WalkRoute) {
        let lineDraw = MKPolyline(coordinates: location.points, count: location.count)
        mapView.addOverlay(lineDraw)
    }
    // TODO: -  1초 마다 업데이트하기
    func updateWalkRecord() {
        
    }
    
    func showRouteResult(with mapImage: UIImage) {
        mapView.isHidden = true
        routeMapImageView.image = mapImage
        routeMapImageView.isHidden = false
    }
    
    func stopRecordWalk() async {
        isStarted = false
        trackingButton.isEnabled = false
        guard let mapImage = screenshot(at: mapView) else {
            presenter?.endTracking()
            return
        }
        showRouteResult(with: mapImage)
        do {
            try await Task.sleep(nanoseconds: 3000000000)
        } catch {
            SNMLogger.error("TrackWalkViewController: \(error.localizedDescription)")
        }
        presenter?.endTracking()
    }
    
    func screenshot(at view: UIView) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: view.bounds.size)
        return renderer.image { context in
            view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        }
    }
}

extension TrackWalkViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let polyLine = overlay as? MKPolyline
        else {
            SNMLogger.log("맵에 경로를 그릴 수 없습니다.")
            return MKOverlayRenderer()
        }
        let renderer = MKPolylineRenderer(polyline: polyLine)
        renderer.strokeColor = .systemOrange
        renderer.lineWidth = 3.0
        renderer.alpha = 1.0
        
        return renderer
    }
}

private extension TrackWalkViewController {
    enum Context {
        static let trackButtonStartTitle = "시작"
        static let trackButtonStopTitle = "종료"
        static let timeTitle = "시간"
        static let velocityTitle = "걸음수"
        static let distanceTitle = "거리"
        static let defaultTime = "00:00:00"
        static let defaultVelocity = "0"
        static let defaultDistance = "0.00"
        static let regularVerticalPadding: CGFloat = 20
    }
}
