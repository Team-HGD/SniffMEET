//
//  QuitProfileDropUseCase.swift
//  SniffMeet
//
//  Created by Kelly Chui on 1/14/25.
//

import Foundation

protocol QuitProfileDropUseCase {
    func execute()
}

struct QuitProfileDropUseCaseImpl: QuitProfileDropUseCase {
    let niManager: NIManager
    
    init(niManager: NIManager) {
        self.niManager = niManager
    }
    
    func execute() {
        Task(priority: .high) {
            niManager.endSession()
        }
    }
}
