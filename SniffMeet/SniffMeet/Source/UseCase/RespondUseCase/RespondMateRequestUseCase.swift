//
//  AcceptMateRequestUseCase.swift
//  SniffMeet
//
//  Created by 윤지성 on 11/27/24.
//
import Foundation

protocol RespondMateRequestUseCase {
    func execute(mateId: UUID, isAccepted: Bool) async
}

struct RespondMateRequestUseCaseImpl: RespondMateRequestUseCase {
    private let localDataManager: DataStorable & DataLoadable
    private let remoteDBManager: any RemoteDBManageable
    private let sessionManager: any SessionManageable
    
    init(
        localDataManager: DataStorable & DataLoadable,
        remoteDataManger: any RemoteDBManageable,
        sessionManager: any SessionManageable
    ) {
        self.localDataManager = localDataManager
        self.remoteDBManager = remoteDataManger
        self.sessionManager = sessionManager
    }
    
    func execute(mateId: UUID, isAccepted: Bool) async {
        if isAccepted {
            await addMate(mateId: mateId)
        }
    }
    
    private func addMate(mateId: UUID) async {
        var mateList: [UUID] =  []
        let encoder = JSONEncoder()
        do {
            mateList = try localDataManager.loadData(forKey: Environment.UserDefaultsKey.mateList, type: [UUID].self)
        } catch {
            mateList = []
        }
        do {
            let userID = try sessionManager.userID.get()
            mateList.append(mateId)
            mateList = Array(Set(mateList))
            let mateListData = try encoder.encode(MateListDTO(mates: mateList))
            try await remoteDBManager.insertData()
                .setTable(Environment.SupabaseTableName.matelist)
                .setData(mateListData)
                .setQuery(.equal("id", userID))
                .request()
            
            try localDataManager.storeData(data:mateList, key: Environment.UserDefaultsKey.mateList)
        } catch {
            SNMLogger.error("AcceptMateRequestUsecaseError: \(error.localizedDescription)")
        }
    }
}
