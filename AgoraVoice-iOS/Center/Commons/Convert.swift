//
//  Convert.swift
//  AGECenter
//
//  Created by CavanSu on 2019/6/19.
//  Copyright © 2019 Agora. All rights reserved.
//

import Foundation

class Convert: NSObject {
    static func force<T: Any>(instance: Any, to type: T.Type) throws -> T {
        if let converted = instance as? T {
            return converted
        } else {
            throw AGEError.fail("convert fail")
        }
    }
}
