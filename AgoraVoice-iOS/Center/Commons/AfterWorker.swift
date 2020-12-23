//
//  AfterWorker.swift
//  AGECenter_iOS
//
//  Created by CavanSu on 2019/7/7.
//  Copyright © 2019 Agora. All rights reserved.
//

import Foundation

class AfterWorker {
    private var pendingRequestWorkItem: DispatchWorkItem?
    
    func perform(after: TimeInterval, on queue: DispatchQueue, _ block: @escaping (() -> Void)) {
        // Cancel the currently pending item
        pendingRequestWorkItem?.cancel()
        
        // Wrap our request in a work item
        let requestWorkItem = DispatchWorkItem(block: block)
        pendingRequestWorkItem = requestWorkItem
        queue.asyncAfter(deadline: .now() + after, execute: requestWorkItem)
    }
    
    func cancel() {
        pendingRequestWorkItem?.cancel()
    }
}

