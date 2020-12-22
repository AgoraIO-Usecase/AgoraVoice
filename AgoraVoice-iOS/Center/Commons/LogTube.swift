//
//  LogTube.swift
//  AGEManAGEr
//
//  Created by CavanSu on 2018/9/14.
//  Copyright © 2018 CavanSu. All rights reserved.
//

import Foundation
import AgoraLog

class LogTube: NSObject {
    private lazy var logger = AgoraLogger(folderPath: FilesGroup.cacheDirectory + folderName,
                                          filePrefix: AppAssistant.name,
                                          maximumNumberOfFiles: 5)
    private lazy var lock: NSObject = NSObject()
    let folderName = "Log"
    
    override init() {
        super.init()
        logger.setPrintOnConsoleType(.all)
    }
    
    func logFromClass(formatter: AGELogFormatter) {
        log(formatter: formatter)
    }
}

private extension LogTube {
    func log(formatter: AGELogFormatter) {
        AGELock.synchronized(self.lock) { [unowned self] in
            self.debugPrint("--------------------------------------------------------------------------", type: formatter.type)
            let className = "Class: \(formatter.className)"
            
            self.debugPrint(className, type: formatter.type)
            
            var typeContent: String
            
            switch formatter.type {
            case .info(let text):    typeContent = "Info: \(text)"
            case .warning(let text): typeContent = "Warning: \(text)"
            case .error(let text):   typeContent = "Error: \(text)"
            }
            
            debugPrint(typeContent, type: formatter.type)
           
            if let extra = formatter.extra {
                let extraContent = "Extra: \(extra)"
                self.debugPrint(extraContent, type: formatter.type)
            }
        }
    }
    
    func writeToFile(log: String, type: LogType) {
        var level: AgoraLogType

        switch type {
        case .info:
            level = .info
        case .warning:
            level = .warning
        case .error:
            level = .error
        }

        self.logger.log(log, type: level)
    }
        
    func debugPrint(_ log: String, type: LogType) {
        writeToFile(log: log, type: type)
    }
}
