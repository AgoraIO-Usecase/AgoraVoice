//
//  Utils.swift
//  Center
//
//  Created by CavanSu on 2020/2/13.
//  Copyright © 2020 CavanSu. All rights reserved.
//

import Foundation

enum AGESwitch: Int, AGEDescription {
    case off = 0, on = 1
    
    var description: String {
        return cusDescription()
    }
    
    var debugDescription: String {
        return cusDescription()
    }
    
    var boolValue: Bool {
        switch self {
        case .on:  return true
        case .off: return false
        }
    }
    
    var intValue: Int {
        switch self {
        case .on:  return 1
        case .off: return 0
        }
    }
    
    func cusDescription() -> String {
        switch self {
        case .on:  return "on"
        case .off: return "off"
        }
    }
}

enum AGEChannelStatus: AGEDescription {
    case ing, out
    
    var description: String {
        return cusDescription()
    }
    
    var debugDescription: String {
        return cusDescription()
    }
    
    func cusDescription() -> String {
        switch self {
        case .ing:  return "inChannel"
        case .out:  return "outChannel"
        }
    }
}
