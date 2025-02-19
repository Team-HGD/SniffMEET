//
//  Untitled.swift
//  SniffMeet
//
//  Created by 윤지성 on 2/18/25.
//
import UIKit

protocol TrackWalkRoutable: AnyObject, Routable {
    var presenter: (any TrackWalkPresentable)? { get set }
    
}

final class TrackWalkRouter: TrackWalkRoutable {
    weak var presenter: (any TrackWalkPresentable)?
    
}
