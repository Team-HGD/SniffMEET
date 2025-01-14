//
//  FindMateUseCase.swift
//  SniffMeet
//
//  Created by Kelly Chui on 1/14/25.
//

import Foundation
import NearbyInteraction

protocol TryProfileDropUseCase {
    func execute()
    func loadProfileData()
}

final class TryProfileDropUseCaseImpl: NSObject, TryProfileDropUseCase {
    let dataManager: DataLoadable
    let niManager: NIManager
    let encoder: JSONEncoder
    var profileData: Data? = nil
    
    init(
        dataManager: DataLoadable,
        niManager: NIManager
    ) {
        self.dataManager = dataManager
        self.niManager = niManager
        self.encoder = JSONEncoder()
        
        super.init()
        niManager.niSession?.delegate = self
    }
    
    func execute()  {
        loadProfileData()
        niManager.mpcManager.isAvailableToBeConnected = true
    }
    
    func loadProfileData() {
        do {
            let dog = try dataManager.loadData(forKey: "dogInfo", type: UserInfo.self)
            guard let userID = SessionManager.shared.session?.user?.userID else { return }
            let dogProfileDTO = DogProfileDTO(
                id: userID,
                name: dog.name,
                keywords: dog.keywords,
                profileImage: dog.profileImage
            )
            let dataToSend = MPCProfileDropDTO(token: nil, profile: dogProfileDTO, transitionMessage: nil)
            profileData = try encoder.encode(dataToSend)
        } catch {
            SNMLogger.error("loadData error : \(error)")
        }
    }
}

extension TryProfileDropUseCaseImpl: NISessionDelegate {
    func session(_ session: NISession, didUpdate nearbyObjects: [NINearbyObject]) {
        guard let nearbyObject = nearbyObjects.first else { return }
        let distance = nearbyObject.distance ?? 1
        let direction = nearbyObject.direction ?? simd_float3(0.1, 0.1, 0.1)

        SNMLogger.info("Distance and Direction to peer: \(distance) and \(direction)")

        if distance > Context.minDistance && distance < Context.maxDistance {
            guard let profileData else {
                SNMLogger.log("보낼 데이터가 없다. ")
                return
            }
            SNMLogger.log("거리와 방향 조건 만족")

            Task { @MainActor in
                niManager.mpcManager.sendData(data: profileData)
                niManager.isViewTransitioning.send(true)
                niManager.viewTransitionInfo.insert("send")
                niManager.mpcManager.send(viewTransitionInfo: "receive")
            }
        }
    }

    func sessionWasSuspended(_ session: NISession) {
        SNMLogger.log("NearbyInteraction session suspended.")
    }

    func sessionSuspensionEnded(_ session: NISession) {
        SNMLogger.log("NearbyInteraction session suspension ended.")
    }

    func session(_ session: NISession, didInvalidateWith error: Error) {
        SNMLogger.error("NearbyInteraction session invalidated: \(error)")
    }
}

extension TryProfileDropUseCaseImpl {
    private enum Context {
        static let minDistance: Float = 0.09
        static let maxDistance: Float = 0.15
        static let minDirection: simd_float3 = simd_float3(-0.6, -0.3, -1.0)
        static let maxDirection: simd_float3 = simd_float3(0.6, 0.3, -0.8)
    }
}

