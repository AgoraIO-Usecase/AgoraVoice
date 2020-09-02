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
            self.debugPrint("--------------------------------------------------------------------------")
            let className = "Class: \(formatter.className)"
            let funcName = "Func: \(formatter.funcName)"
            
            self.debugPrint(className)
            self.debugPrint(funcName)
            
            var typeContent: String
            
            switch formatter.type {
            case .info(let text):    typeContent = "Info: \(text)"
            case .warning(let text): typeContent = "Warning: \(text)"
            case .error(let text):   typeContent = "Error: \(text)"
            }
            
            debugPrint(typeContent)
           
            if let extra = formatter.extra {
                let extraContent = "Extra: \(extra)"
                self.debugPrint(extraContent)
            }
            self.debugPrint("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
        }
    }
    
    func writeToFile(log: String) {
        var identifier: Int8 = 0
        LCLLogFile.log(withIdentifier: &identifier, level: 0, path: nil,
                       line: 0, function: &identifier, message: log)
    }
        
    func debugPrint(_ log: String) {
//        #if DEBUG
        NSLog("%@", log)
//        #endif
        writeToFile(log: log)
    }
}
