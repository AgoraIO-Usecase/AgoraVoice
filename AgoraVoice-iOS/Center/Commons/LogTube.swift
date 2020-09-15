//
//  LogTube.swift
//  AGEManAGEr
//
//  Created by CavanSu on 2018/9/14.
//  Copyright © 2018 CavanSu. All rights reserved.
//

import Foundation

class LogTube: NSObject {
    private lazy var lock: NSObject = NSObject()
    
    override init() {
        super.init()
        LCLLogFile.setEscapesLineFeeds(false)
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
            let funcName = "Func: \(formatter.funcName)"
            
            self.debugPrint(className, type: formatter.type)
            self.debugPrint(funcName, type: formatter.type)
            
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
            self.debugPrint("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~", type: formatter.type)
        }
    }
    
    func writeToFile(log: String, type: LogType) {
        var level: AgoraLogLevel
        
        switch type {
        case .info:
            level = .info
        case .warning:
            level = .warn
        case .error:
            level = .error
        }
        
        AgoraLogManager.logMessage(log, level: level)
    }
        
    func debugPrint(_ log: String, type: LogType) {
        #if !RELEASE
        NSLog("%@", log)
        #endif
        writeToFile(log: log, type: type)
    }
}
