//
//  MultiQueue.swift
//  AgoraLive
//
//  Created by CavanSu on 2020/7/30.
//  Copyright © 2020 Agora. All rights reserved.
//

import UIKit
import RxSwift
import RxRelay

class TimestampQueue: NSObject {
    private var timer: SubThreadTimer
    
    private(set) var list = [TimestampModel]() {
        didSet {
            if list.count > 0 {
                self.timer.start()
            } else {
                self.timer.stop()
            }
            
            queueChanged.accept(list)
        }
    }
    
    let queueChanged = PublishRelay<[TimestampModel]>()
    let timeout = PublishRelay<[TimestampModel]>()
    
    var max = 10
    
    init(name: String) {
        self.timer = SubThreadTimer(threadName: name)
        super.init()
        self.timer.delegate = self
    }
    
    func append(_ item: TimestampModel) {
        guard list.count < max else {
            return
        }
        
        list.append(item)
    }
    
    func remove(_ item: TimestampModel) {
        let index = list.firstIndex { (model) -> Bool in
            return model.id == item.id
        }
        
        guard let tIndex = index else {
            return
        }
        
        list.remove(at: tIndex)
    }
}

extension TimestampQueue: SubThreadTimerDelegate {
    func perLoop() {
        let currentTimestamp = NSDate().timeIntervalSince1970
        var needRemoveIndex: Int? = nil
        
        for (index, item) in list.enumerated() {
            if (currentTimestamp - item.timestamp) >= Double(30) {
                needRemoveIndex = index
            } else {
                break
            }
        }
        
        if let needRemoveIndex = needRemoveIndex {
            DispatchQueue.main.async { [unowned self] in
                let timeouts = self.list.prefix(needRemoveIndex + 1)
                self.timeout.accept(Array(timeouts))
                if self.list.count > 0 {
                    self.list.removeSubrange(0...needRemoveIndex)
                }
            }
        }
    }
}
