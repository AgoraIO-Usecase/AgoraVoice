//
//  AGELock.swift
//  AGECenter
//
//  Created by CavanSu on 2019/7/9.
//  Copyright © 2019 Agora. All rights reserved.
//

import Foundation

class AGELock: NSObject {
    static func synchronized<T>(_ lock: AnyObject, _ closure: () throws -> T ) rethrows -> T {
        objc_sync_enter(lock)
        defer { objc_sync_exit(lock) }
        return try closure()
    }
}
