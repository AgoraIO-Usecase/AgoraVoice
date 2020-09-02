//
//  InfoDatAGEtable.swift
//  Wayang
//
//  Created by GongYuhua on 2018/6/1.
//  Copyright © 2018年 Agora. All rights reserved.
//

#if os(iOS)
import UIKit
#else
import Cocoa
#endif

protocol DictionaryGetable {
    func getValue<T: Any>(of key: String, type: T.Type, funcName: String) throws -> T
}

extension DictionaryGetable {
    func getIntValue(of key: String, funcName: String = #function) throws -> Int {
        return try getValue(of: key, type: Int.self, funcName: funcName)
    }
    
    func getInt64Value(of key: String, funcName: String = #function) throws -> Int64 {
        return try getValue(of: key, type: Int64.self, funcName: funcName)
    }
    
    func getUIntValue(of key: String, funcName: String = #function) throws -> UInt {
        let value = try getValue(of: key, type: Int.self, funcName: funcName)
        if value >= 0 {
            return UInt(value)
        } else {
            throw AGEError.invalidParameter(key)
        }
    }
    
    func getUInt32Value(of key: String, funcName: String = #function) throws -> UInt32 {
        let value = try getValue(of: key, type: Int.self, funcName: funcName)
        if value >= 0 {
            return UInt32(value)
        } else {
            throw AGEError.invalidParameter(key)
        }
    }
    
    func getDoubleValue(of key: String, funcName: String = #function) throws -> Double {
        if let doubleValue = try? getValue(of: key, type: Double.self, funcName: funcName) {
            return doubleValue
        } else if let intValue = try? getIntValue(of: key) {
            return Double(intValue)
        } else {
            throw AGEError.invalidParameter(key)
        }
    }
    
    func getFloatInfoValue(of key: String, funcName: String = #function) throws -> Float {
        let value = try getDoubleValue(of: key)
        return Float(value)
    }
    
    func getCGFloatInfoValue(of key: String, funcName: String = #function) throws -> CGFloat {
        let value = try getDoubleValue(of: key)
        return CGFloat(value)
    }
    
    func getBoolInfoValue(of key: String, funcName: String = #function) throws -> Bool {
        return try getValue(of: key, type: Bool.self, funcName: funcName)
    }
    
    func getStringValue(of key: String, funcName: String = #function) throws -> String {
        return try getValue(of: key, type: String.self, funcName: funcName)
    }
    
    func getDictionaryValue(of key: String, funcName: String = #function) throws -> [String: Any] {
        return try getValue(of: key, type: [String: Any].self, funcName: funcName)
    }
    
    func getListValue(of key: String, funcName: String = #function) throws -> [[String: Any]] {
        return try getValue(of: key, type: [[String: Any]].self, funcName: funcName)
    }
    
    func getEnum<T: RawRepresentable>(of key: String, type: T.Type, funcName: String = #function) throws -> T where T.RawValue == Int {
        let rawValue = try getIntValue(of: key)
        guard let value = T.init(rawValue: rawValue) else {
            throw AGEError.invalidParameter(key)
        }
        return value
    }
    
    func getEnum<T: RawRepresentable>(of key: String, type: T.Type, funcName: String = #function) throws -> T where T.RawValue == UInt {
        let rawValue = try getUIntValue(of: key)
        guard let value = T.init(rawValue: rawValue) else {
            throw AGEError.invalidParameter(key)
        }
        return value
    }
}

extension Dictionary: DictionaryGetable where Key == String, Value == Any {
    func getValue<T: Any>(of key: String, type: T.Type, funcName: String = #function) throws -> T {
        guard let value = self[key] as? T else {
            throw AGEError.invalidParameter("invalidParameter:" + key, extra: "parse json type error, call fucname: \(funcName)")
        }
        return value
    }
}
