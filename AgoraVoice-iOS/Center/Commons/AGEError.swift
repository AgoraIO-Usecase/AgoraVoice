//
//  AGEError.swift
//  AGECenter
//
//  Created by CavanSu on 2019/6/18.
//  Copyright © 2019 Agora. All rights reserved.
//

import Foundation
import AgoraRte
import Armin

public enum AGEErrorType: Error {
    case fail(String)
    case invalidParameter(String)
    case valueNil(String)
    case convertedTo(String, String)
    case timeout(TimeInterval)
    case unknown
    
    var localizedDescription: String {
        switch self {
        case .fail(let reason):             return "\(reason)"
        case .invalidParameter(let para):   return "\(para)"
        case .valueNil(let para):           return "\(para) nil"
        case .convertedTo(let a, let b):    return "\(a) converted to \(b) error"
        case .timeout(let duration):        return "timeout \(duration)"
        case .unknown:                      return "unknown error"
        }
    }
    
    static func ==(left: AGEErrorType, right: AGEErrorType) -> Bool {
        return left.rawValue == right.rawValue
    }
    
    static func !=(left: AGEErrorType, right: AGEErrorType) -> Bool {
        return left.rawValue != right.rawValue
    }
}

private extension AGEErrorType {
    var rawValue: Int {
        switch self {
        case .fail:                 return 0
        case .invalidParameter:     return 1
        case .valueNil:             return 2
        case .convertedTo:          return 3
        case .timeout:              return 5
        case .unknown:              return 8
        }
    }
}

struct AGEError: AGEDescription, Error {
    var description: String {
        return cusDescription()
    }
    
    var debugDescription: String {
        return cusDescription()
    }
    
    var localizedDescription: String {
        return cusDescription()
    }
    
    var type: AGEErrorType
    var code: Int?
    var extra: String?
    
    init(rteError: AgoraRteError) {
        self.type = .fail("rte error")
        self.code = rteError.code
        self.extra = rteError.message
    }
    
    init(arError: ArError) {
        self.type = .fail("armin error")
        self.code = arError.code
        self.extra = arError.localizedDescription
    }
    
    init(type: AGEErrorType, code: Int? = nil, extra: String? = nil) {
        self.type = type
        self.code = code
        self.extra = extra
    }
    
    func cusDescription() -> String {
        var description = type.localizedDescription
        if let code = code {
            description += ", code: \(code)"
        }
        
        if let extra = extra {
            description += ", extra: \(extra)"
        }
        return description
    }
    
    static func fail(_ text: String, code: Int? = nil, extra: String? = nil) -> AGEError {
        return AGEError(type: .fail(text), code: code, extra: extra)
    }
    
    static func invalidParameter(_ text: String, code: Int? = nil, extra: String? = nil) -> AGEError {
        return AGEError(type: .invalidParameter(text), code: code, extra: extra)
    }
    
    static func valueNil(_ text: String, code: Int? = nil, extra: String? = nil) -> AGEError {
        return AGEError(type: .valueNil(text), code: code, extra: extra)
    }
    
    static func timeout(duration: TimeInterval, extra: String? = nil) -> AGEError {
        return AGEError(type: .timeout(duration), extra: extra)
    }
    
    static func unknown(code: Int? = nil, extra: String? = nil) -> AGEError {
        return AGEError(type: .unknown, code: code)
    }
    
    static func convertedTo(_ a: String, _ b: String, code: Int? = nil, extra: String? = nil) -> AGEError {
        return AGEError(type: .convertedTo(a, b), code: code)
    }
    
    static func ==(left: AGEError, right: AGEError) -> Bool {
        return left.type.rawValue == right.type.rawValue
    }
    
    static func !=(left: AGEError, right: AGEError) -> Bool {
        return left.type.rawValue != right.type.rawValue
    }
}
