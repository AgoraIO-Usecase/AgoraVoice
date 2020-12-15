//
//  AGEDataExtension.swift
//  AGEManAGEr
//
//  Created by CavanSu on 2019/4/24.
//  Copyright © 2019 Agora. All rights reserved.
//

#if os(iOS)
import UIKit
#else
import Cocoa
#endif

protocol InfoDic {
    func dic() -> [String: Any]
}

protocol AGEDescription: CustomStringConvertible, CustomDebugStringConvertible {
    func cusDescription() -> String
}

protocol BinaryValue {
    var binaryValue: Int {get}
}

// MARK: - Dictionary
extension Dictionary: AGEDescription {
    var description: String {
        return cusDescription()
    }
    
    var debugDescription: String {
        return cusDescription()
    }
    
    func cusDescription() -> String {
        var desc: String = ""
        
        guard self.count > 0 else {
            desc = "{nil}"
            return desc
        }
        
        desc += "{"
        
        for (key, value) in self {
            var valueDesc: String
            
            if let value = value as? Array<Any> {
                valueDesc = value.description
            } else if let value = value as? Dictionary {
                valueDesc = value.description
            } else {
                valueDesc = "\(value)"
            }
            
            if desc.count == 1 {
                desc += "\(key): \(valueDesc)"
            } else {
                desc += ", \(key): \(valueDesc)"
            }
        }
        desc += "}"
        return desc
    }
    
    func jsonString() throws -> String {
        let data = try JSONSerialization.data(withJSONObject: self,
                                              options: JSONSerialization.WritingOptions.prettyPrinted)
        guard let jsonString = String(data: data, encoding: String.Encoding.utf8) else {
            throw AGEError.convertedTo("Data", "String", extra: "dic: \(self.description)")
        }
        return jsonString
    }
}

// MARK: - Array
extension Array: AGEDescription {
    var description: String {
        return cusDescription()
    }
    
    var debugDescription: String {
        return cusDescription()
    }
    
    func cusDescription() -> String {
        var desc: String = ""
        
        guard self.count > 0 else {
            desc = "[nil]"
            return desc
        }
        
        desc += "["
        for item in self {
            var valueDesc: String
            
            if let item = item as? Array<Any> {
                valueDesc = item.description
            } else if let item = item as? Dictionary<String, Any> {
                valueDesc = item.description
            } else {
                valueDesc = "\(item)"
            }
            
            if desc.count == 1 {
                desc += "\(valueDesc)"
            } else {
                desc += ", \(valueDesc)"
            }
        }
        desc += "]"
        return desc
    }
}

// MARK: - String
extension String {
    func json() throws -> [String: Any] {
        guard let data = self.data(using: .utf8) else {
            throw AGEError.convertedTo("String", "Data", extra: "jsonString: \(self)")
        }
        
        return try data.json()
    }
}

extension Data {
    func json() throws -> [String: Any] {
        let object = try JSONSerialization.jsonObject(with: self, options: [])
        guard let dic = object as? [String: Any] else {
            throw AGEError.convertedTo("Any", "[String: Any]")
        }
        
        return dic
    }
}

// MARK: - UserDefaults
extension UserDefaults {
    var timeout: Double? {
        let max = UserDefaults.standard.value(forKey: "maxRequestTimeout") as? NSNumber
        return max?.doubleValue
    }
    
    func setValueForTimeout(_ value: Double) {
        let max = NSNumber(value: value)
        setValue(max, forKey: "maxRequestTimeout")
    }
}

// MARK: - ImAGE
extension AGEImage {
    var data: Data? {
        #if os(iOS)
        return self.pngData()
        #else
        return self.tiffRepresentation
        #endif
    }
    
    static func initWith(data: Data) throws -> AGEImage {
        if let imAGE = AGEImage(data: data) {
            return imAGE
        } else {
            throw AGEError.fail("ImAGE init error")
        }
    }
    
    func compressQualityWith(maxSize: Int) throws -> Data {
        let compression: Float = 1
        
        #if os(iOS)
        guard let data = self.jpegData(compressionQuality: CGFloat(compression)) else {
            throw AGEError.valueNil("jpegData")
        }
        #else
        guard var data = self.tiffRepresentation else {
            throw AGEError.valueNil("tiffRepresentation")
        }
        
        guard let _ = NSBitmapImAGERep.init(data: data) else {
            throw AGEError.valueNil("NSBitmapImAGERep")
        }
        #endif
        
        if data.count < maxSize {
            return data
        }
        let max = Double(maxSize)
        let devision = Double(data.count)
        let comp = max / devision
        
        #if os(iOS)
        guard let compressData = self.jpegData(compressionQuality: CGFloat(comp)) else {
            throw AGEError.valueNil("jpegData")
        }
        #else
        guard let compressData = compressedPng(with: Double(comp)) else {
            throw AGEError.valueNil("compressedJPEG")
        }
        #endif
        
        return compressData
    }
    
    #if os(macOS)
    func compressedPng(with factor: Double) -> Data? {
        guard let tiff = tiffRepresentation else { return nil }
        guard let imAGERep = NSBitmapImAGERep(data: tiff) else { return nil }
        
        let options: [NSBitmapImAGERep.PropertyKey: Any] = [
            .compressionFactor: factor
        ]
        
        return imAGERep.representation(using: .png, properties: options)
    }
    #endif
}

// MARK: - Date
extension Date {
    enum TimeRange {
        case year, month, day, hour, minute, second
        
        var key: String {
            switch self {
            case .year:   return "YYYY"
            case .month:  return "MM"
            case .day:    return "dd"
            case .hour:   return "HH"
            case .minute: return "mm"
            case .second: return "ss"
            }
        }
        
        static let list: [TimeRange] = [.year, .month, .day, .hour, .minute, .second]
    }
    
    static var millisecondTimestamp: Int {
        return Int(CACurrentMediaTime() * 1000)
    }
    
    static func currentTimeString(range: [TimeRange], separator: String? = nil) -> String {
        let dateFormatter = DateFormatter()
        var format: String = ""
        if range.count > 0 {
            for (index, item) in TimeRange.list.enumerated() {
                if index == 0 {
                    format += item.key
                } else if index > 0, let separator = separator {
                    format += (separator + item.key)
                } else {
                    format += item.key
                }
            }
        } else {
            format = "YYYY-MM-dd-HH-mm-ss"
        }
        
        dateFormatter.dateFormat = format
        let date = dateFormatter.string(from: Date(timeIntervalSinceNow: 0))
        return date
    }
}

extension URL {
    init(path: String) throws {
        if let url = URL(string: path) {
            self = url
        } else {
            throw AGEError.fail("url init error", extra: "string: \(path)")
        }
    }
}
