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
        FilesGroup.check(folderPath: folderPath)
        checkEarliestFile()
        createFile()
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
        let zipPath = try ZipTool.work(destination: folderPath, to: FilesGroup.cacheDirectory)
        let fileName = zipPath.components(separatedBy: "/").last!
        let url = URL(fileURLWithPath: zipPath)
        let fileData = try Data(contentsOf: url)
        
        let client = Center.shared().centerProvideRequestHelper()
        let parameters: StringAnyDic = ["appId": Keys.AgoraAppId,
                                        "osType": 1,
                                        "appVersion": AppAssistant.version,
                                        "appCode": "ent-super",
                                        "fileExt": "zip"]
        
        let event = RequestEvent(name: "upload-oss-parameters")
        let task = RequestTask(event: event,
                               type: .http(.get, url: URLGroup.ossUpload),
                               timeout: .medium,
                               parameters: parameters)
        
        let successCallback: DicEXCompletion = { (json: ([String: Any])) in
            let data = try json.getDataObject()
            let bucketName = try data.getStringValue(of: "bucketName")
            let callbackBody = try data.getStringValue(of: "callbackBody")
            let callbackContentType = try data.getStringValue(of: "callbackContentType")
            let ossEndpoint = try data.getStringValue(of: "ossEndpoint")
            
            let object = AGOSSObject()
            object.bucket = bucketName
            object.fileData = fileData
            object.objectKey = fileName
            object.callbackParam = ["callbackUrl": URLGroup.ossUploadCallback,
                                    "callbackBody": callbackBody,
                                    "callbackBodyType": callbackContentType]
            
            let oss = Center.shared().centerProvideOSSClient()
            oss.updateAuthServerURL(URLGroup.ossSTS, endpoint: ossEndpoint)
            
            oss.upload(with: object, success: { (logId) in
                DispatchQueue.main.async {
                    if let success = success {
                        success(logId)
                    }
                }
            }) { (error) in
                DispatchQueue.main.async {
                    if let fail = fail {
                        fail(error)
                    }
                }
            }
        }
        
        let response = ACResponse.json(successCallback)
        
        let retry: ACErrorRetryCompletion = { (error: Error) -> RetryOptions in
            if let fail = fail {
                fail(error)
            }
            return .resign
        }
        
        client.request(task: task, success: response, failRetry: retry)
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
    
    func createFile() {
        let filePath = folderPath + "/" + fileName
        LCLLogFile.setEscapesLineFeeds(true)
        LCLLogFile.setPath(filePath)
    }
}
