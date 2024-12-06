//
//  CancellableExecutor.swift
//  TestTaskIcons
//
//  Created by Konstantin on 05.12.2024.
//

import Foundation

protocol CancellableExecutorProtocol: AnyObject {
    func execute(delay: DispatchTimeInterval, cancelationStatusHandler: @escaping (Bool) -> ())
}

final class CancellableExecutor: CancellableExecutorProtocol {
    private var pendingWorkItem: DispatchWorkItem?
    
    deinit {
        cancel()
    }
    
    func execute(delay: DispatchTimeInterval, cancelationStatusHandler: @escaping (Bool) -> ()) {
        cancel()
                
        pendingWorkItem = DispatchWorkItem { [weak self] in
            guard let self else { return }
            
            cancelationStatusHandler(pendingWorkItem?.isCancelled ?? true)
            self.pendingWorkItem = nil
        }
                
        pendingWorkItem.map {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: $0)
        }
    }

    private func cancel() {
        pendingWorkItem?.cancel()
        pendingWorkItem = nil
    }
}
