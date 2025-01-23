//
//  TaskSerialQueue.swift
//  SniffMeet
//
//  Created by sole on 1/22/25.
//

actor TaskSerialQueue {
    private var tasks: [() async -> Void] = []
    private var isProcessing = false

    func addTask(_ task: @escaping () async -> Void) async {
        tasks.append(task)
        await processNextTaskIfNeeded()
    }

    private func processNextTaskIfNeeded() async {
        guard !isProcessing else { return }
        isProcessing = true

        while !tasks.isEmpty {
            let task = tasks.removeFirst()
            await task()
        }

        isProcessing = false
    }
}
