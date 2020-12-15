//
//  LogTube.swift
//  AGEManAGEr
//
//  Created by CavanSu on 2018/9/13.
//  Copyright © 2018 CavanSu. All rights reserved.
//

import Foundation

enum LogConsole {
    case no, socket, http, media, all
}

enum LogType {
    case info(String), warning(String), error(String)
}

struct AGELogFormatter {
    var className: String
    var funcName: String
    var logOnConsole: LogConsole = .all
    var type: LogType
    var extra: String?
    
    init(type: LogType, className: String, funcName: String, extra: String? = nil) {
        self.type = type
        self.className = className
        self.funcName = funcName
        self.extra = extra
    }
}

protocol AGELogBase {
    var logTube: LogTube {get set}
    
    func logOutputInfo(_ info: String, extra: String?, className: AnyClass, funcName: String)
    func logOutputWarning(_ warning: String, extra: String?, className: AnyClass, funcName: String)
    func logOutputError(_ error: Error, extra: String?, className: AnyClass, funcName: String)
}

extension AGELogBase {
    func logOutputInfo(_ info: String, extra: String?, className: AnyClass, funcName: String) {
        let type = LogType.info(info)
        sendLogToTube(type: type, extra: extra, className: className, funcName: funcName)
    }
    
    func logOutputWarning(_ warning: String, extra: String?, className: AnyClass, funcName: String) {
        let type = LogType.warning(warning)
        sendLogToTube(type: type, extra: extra, className: className, funcName: funcName)
    }
    
    func logOutputError(_ error: Error, extra: String?, className: AnyClass, funcName: String) {
        var type: LogType
        if let error = error as? AGEError {
            type = LogType.error(error.localizedDescription)
        } else {
            type = LogType.error(error.localizedDescription)
        }
        sendLogToTube(type: type, extra: extra, className: className, funcName: funcName)
    }
}

private extension AGELogBase {
    func sendLogToTube(type: LogType, extra: String?, className: AnyClass, funcName: String) {
        let className = NSStringFromClass(className.self)
        
        let formatter = AGELogFormatter(type: type,
                                        className: className,
                                        funcName: funcName,
                                        extra: extra)
        
        logTube.logFromClass(formatter: formatter)
    }
}

struct OptionsDescription {
    static func any<any>(_ any: any?) -> String where any: CustomStringConvertible {
        return any != nil ? any!.description : "nil"
    }
}
