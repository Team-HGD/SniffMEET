//
//  WalkRoute.swift
//  SniffMeet
//
//  Created by 윤지성 on 2/19/25.
//
import CoreLocation

struct WalkRoute {
    init(points: [CLLocationCoordinate2D]) {
        self.points = points
    }
    
    private(set) var points: [CLLocationCoordinate2D] = []
    var count: Int { points.count }
}
