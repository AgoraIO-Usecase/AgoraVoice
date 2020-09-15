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
import AlamoClient
import AliyunOSSiOS

class LogFiles: NSObject {
    private let fileName: String = {
        let date = Date.currentTimeString(range: [.month, .day, .hour, .minute, .second])
        let name = "app" + date + ".log"
        return name
    }()
    
    private let folderName = "Log"
    private let maxAppLogsCount: Int = 5
    
    var folderPath: String {
        return FilesGroup.cacheDirectory + folderName
    }
    
    override init() {
        super.init()
        let configuration = AgoraLogConfiguration()
        configuration.logDirectoryPath = fileName
        AgoraLogManager.setupLog(configuration)
        FilesGroup.check(folderPath: folderPath)
        checkEarliestFile()
    }
    
    func upload(success: StringCompletion, fail: ErrorCompletion) {
        do {
            try privateUpload(success: success, fail: fail)
        } catch {
            if let fail = fail {
                fail(error)
            }
        }
    }
}

private extension LogFiles {
    func privateUpload(success: StringCompletion, fail: ErrorCompletion) throws {
        let options = AgoraLogUploadOptions()
        options.appId = Keys.AgoraAppId
        AgoraLogManager.uploadLog(with: options, progress: nil, success: { (logId) in
            if let success = success {
                success(logId)
            }
        }) { (error) in
            if let fail = fail {
                fail(error)
            }
        }
    }
    
    func checkEarliestFile() {
        let manager = FileManager.default
        
        let direcEnumerator = manager.enumerator(atPath: folderPath)
        var logsList = [String]()
        
        while let file = direcEnumerator?.nextObject() as? String {
            if !file.contains("app") {
                continue
            }
            
            let fullPath = "\(folderPath)/\(file)"
            logsList.append(fullPath)
        }
        
        guard logsList.count >= maxAppLogsCount else {
            return
        }
        
        var earliest = 0
        var lastFileCreatedDate: Date?
        
        for (index, item)  in logsList.enumerated() {
            guard let fileDic = try? manager.attributesOfItem(atPath: item) else {
                continue
            }
            
            guard let fileDate = fileDic[FileAttributeKey.creationDate] as? Date else {
                continue
            }
            
            if let lastDate = lastFileCreatedDate,
                lastDate.compare(fileDate) == ComparisonResult.orderedDescending {
                lastFileCreatedDate = fileDate
                earliest = index
            } else {
                lastFileCreatedDate = fileDate
            }
        }
        
        guard let _ = lastFileCreatedDate else {
            return
        }
        
        let removeFile = logsList[earliest]
        try? manager.removeItem(atPath: removeFile)
    }
}
