//
//  ZipCenter.swift
//  AGEManAGEr
//
//  Created by CavanSu on 2018/10/11.
//  Copyright © 2018 CavanSu. All rights reserved.
//

import Foundation
import SSZipArchive

class ZipTool: NSObject {
    static var fileName: String {
        let date = Date.currentTimeString(range: [.year, .month, .day, .hour, .minute, .second])
        return "Log" + date + ".zip"
    }
    
    static func work(destination path: String, to: String) throws -> String {
        let manager = FileManager.default
        let isExist = manager.fileExists(atPath: path)

        guard isExist == true else {
            throw AGEError.fail("zip path nil")
        }

        let zipFilePath = to + "/" + fileName
        let success = SSZipArchive.createZipFile(atPath: zipFilePath, withContentsOfDirectory: path)

        if success == false {
            throw AGEError.fail("zip fail")
        }
        
        return zipFilePath
    }
}
