//
//  LogFiles.swift
//  CheckIt
//
//  Created by CavanSu on 2019/7/16.
//  Copyright © 2019 Agora. All rights reserved.
//

#if os(iOS)
import UIKit
#else
import Cocoa
#endif
import Armin

class LogFiles: NSObject {
    private let folderName = "Log"
    
    var folderPath: String {
        return FilesGroup.cacheDirectory + folderName
    }
    
    override init() {
        super.init()
        FilesGroup.check(folderPath: folderPath)
    }
    
    func upload(success: StringCompletion, fail: ErrorCompletion) {
        let rteKit = Center.shared().centerProviderteEngine()
        
        rteKit.uploadSDKLogToAgoraService { (logId) in
            if let success = success {
                success(logId)
            }
        } fail: { (error) in
            if let fail = fail {
                fail(AGEError(rteError: error))
            }
        }
    }
}
