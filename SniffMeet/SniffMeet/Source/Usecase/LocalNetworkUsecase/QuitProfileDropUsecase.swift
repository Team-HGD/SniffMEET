//
//  QuitProfileDropUsecase.swift
//  SniffMeet
//
//  Created by Kelly Chui on 1/14/25.
//

import Foundation

protocol QuitProfileDropUsecase {
    func execute()
    mutating func reset(niManager: NIManager)
}

struct QuitProfileDropUsecaseImpl: QuitProfileDropUsecase {
    private var niManager: NIManager
    
    init(niManager: NIManager) {
        self.niManager = niManager
    }
    
    mutating func reset(niManager: NIManager) {
        self.niManager = niManager
    }
    
    func execute() {
        Task(priority: .high) {
            niManager.endSession()
        }
    }
}
