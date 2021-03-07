//
//  JsonParse.swift
//
//  Created by CavanSu on 2020/3/10.
//  Copyright © 2020 Agora. All rights reserved.
//

import Foundation

extension DictionaryGetable {
    func getDataObject(funcName: String = #function) throws -> [String: Any] {
        let object = try self.getDictionaryValue(of: "data", funcName: funcName)
        return object
    }
    
    func getCodeCheck(funcName: String = #function) throws {
        let code = try self.getIntValue(of: "code")
        if code != 0 {
            let message = try? self.getStringValue(of: "msg")
            throw AGEError.fail("request fail",
                                code: code,
                                extra: "message: \(OptionsDescription.any(message)), call fucname: \(funcName)")
        }
    }
}
