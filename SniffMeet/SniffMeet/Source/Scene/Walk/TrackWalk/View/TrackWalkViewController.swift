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
}

final class TrackWalkViewController: BaseViewController, TrackWalkViewable {
    var presenter: (any TrackWalkPresentable)?
    
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
    private let velocityTitleLabel = UILabel()
    private let velocityValueLabel = UILabel()
    private let distanceTitleLabel = UILabel()
    private let distanceValueLabel = UILabel()
    private let trackingButton = UIButton()
    private let firstHorizontalSeparator = UIView()
    private let verticalSeparator = UIView()

    override func viewWillAppear(_ animated: Bool) {
        trackingButton.layoutIfNeeded()
        trackingButton.makeViewCircular()
    }
    
    override func configureAttributes() {
        [timeTitleLabel, velocityTitleLabel, distanceTitleLabel].forEach {
            $0.textColor = SNMColor.subGray3
            $0.font = SNMFont.callout
            $0.contentMode = .center
        }
        [timeValueLabel, velocityValueLabel, distanceValueLabel].forEach {
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
        velocityTitleLabel.text = Context.velocityTitle
        velocityValueLabel.text = Context.defaultVelocity
        distanceTitleLabel.text = Context.distanceTitle
        distanceValueLabel.text = Context.defaultDistance
        
        trackingButton.setTitle(Context.trackButtonStartTitle, for: .normal)
        trackingButton.setTitleColor(.white, for: .normal)
        trackingButton.backgroundColor = SNMColor.mainNavy
        trackingButton.titleLabel?.font = .systemFont(ofSize: 19, weight: .semibold)
    }
    override func configureHierachy() {
        [mapView, bottomView].forEach{
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        [timeTitleLabel, timeValueLabel, velocityView, distanceView].forEach {
            bottomView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        [velocityTitleLabel, velocityValueLabel].forEach {
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
            
            bottomView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bottomView.heightAnchor.constraint(equalToConstant: 330)
        ])
        NSLayoutConstraint.activate([
            timeTitleLabel.topAnchor.constraint(equalTo: bottomView.topAnchor, constant: LayoutConstant.regularVerticalPadding),
            timeTitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            timeValueLabel.topAnchor.constraint(equalTo: timeTitleLabel.bottomAnchor, constant: LayoutConstant.smallVerticalPadding),
            timeValueLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            firstHorizontalSeparator.topAnchor.constraint(equalTo: timeValueLabel.bottomAnchor, constant: LayoutConstant.smallVerticalPadding),
            firstHorizontalSeparator.heightAnchor.constraint(equalToConstant: 1),
            firstHorizontalSeparator.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: LayoutConstant.largestVerticalPadding),
            firstHorizontalSeparator.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -LayoutConstant.largestVerticalPadding),
            
            verticalSeparator.widthAnchor.constraint(equalToConstant: 1),
            verticalSeparator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            verticalSeparator.heightAnchor.constraint(equalToConstant: 63),
            verticalSeparator.topAnchor.constraint(equalTo: firstHorizontalSeparator.bottomAnchor, constant: Context.regularVerticalPadding),
            
            velocityView.topAnchor.constraint(equalTo: firstHorizontalSeparator.bottomAnchor, constant: Context.regularVerticalPadding),
            velocityView.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor, constant: LayoutConstant.largestVerticalPadding),
            velocityView.trailingAnchor.constraint(equalTo: verticalSeparator.leadingAnchor),
            velocityView.heightAnchor.constraint(equalToConstant: 63),

            distanceView.topAnchor.constraint(equalTo: firstHorizontalSeparator.bottomAnchor, constant: Context.regularVerticalPadding),
            distanceView.leadingAnchor.constraint(equalTo: verticalSeparator.trailingAnchor),
            distanceView.trailingAnchor.constraint(equalTo: bottomView.trailingAnchor, constant: -LayoutConstant.largestVerticalPadding),
            distanceView.heightAnchor.constraint(equalToConstant: 63),
            
            trackingButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            trackingButton.widthAnchor.constraint(equalToConstant: 70),
            trackingButton.heightAnchor.constraint(equalToConstant: 70),
            trackingButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -LayoutConstant.xlargeVerticalPadding)
        ])
        NSLayoutConstraint.activate([
            velocityTitleLabel.topAnchor.constraint(equalTo: velocityView.topAnchor),
            velocityTitleLabel.centerXAnchor.constraint(equalTo: velocityView.centerXAnchor),

            velocityValueLabel.topAnchor.constraint(equalTo: velocityTitleLabel.bottomAnchor, constant: LayoutConstant.edgePadding),
            velocityValueLabel.centerXAnchor.constraint(equalTo: velocityView.centerXAnchor),
            velocityValueLabel.bottomAnchor.constraint(equalTo: velocityView.bottomAnchor)
        ])
        NSLayoutConstraint.activate([
            distanceTitleLabel.topAnchor.constraint(equalTo: distanceView.topAnchor),
            distanceTitleLabel.centerXAnchor.constraint(equalTo: distanceView.centerXAnchor),

            distanceValueLabel.topAnchor.constraint(equalTo: distanceTitleLabel.bottomAnchor, constant: LayoutConstant.edgePadding),
            distanceValueLabel.centerXAnchor.constraint(equalTo: distanceView.centerXAnchor),
            distanceValueLabel.bottomAnchor.constraint(equalTo: distanceView.bottomAnchor)
        ])
    }
    override func bind() {}
}

extension TrackWalkViewController: MKMapViewDelegate {
    
}

private extension TrackWalkViewController {
    enum Context {
        static let trackButtonStartTitle = "시작"
        static let trackButtonStopTitle = "종료"
        static let timeTitle = "시간"
        static let velocityTitle = "평균 속도"
        static let distanceTitle = "거리"
        static let defaultTime = "00:00:00"
        static let defaultVelocity = "0.00"
        static let defaultDistance = "0.00"
        static let regularVerticalPadding: CGFloat = 20
    }
}
