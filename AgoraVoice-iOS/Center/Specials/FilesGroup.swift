//
//  FilesGroup.swift
//
//  Created by CavanSu on 2019/6/18.
//  Copyright © 2019 Agora. All rights reserved.
//

import Foundation
import AliyunOSSiOS

// MARK: - FilesGroup
class FilesGroup: NSObject {
    static let cacheDirectory: String = {
        #if os(iOS)
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! + "/"
        #else
        let path = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first! + "/"
        #endif
        return path
    }()
    
    private var ossClient: OSSClient!
    
    var images = ImageFiles()
    var logs = LogFiles()
    
    override init() {
        super.init()
        checkUselessZipFile()
    }
    
    static func check(folderPath: String) {
        let manager = FileManager.default
        
        if !manager.fileExists(atPath: folderPath, isDirectory: nil) {
            try? manager.createDirectory(atPath: folderPath, withIntermediateDirectories: true, attributes: nil)
        }
    }
    
    func removeUselessZip(_ path: String) {
        let manager = FileManager.default
        try? manager.removeItem(atPath: path)
    }
    
    func checkUselessZipFile() {
        let manager = FileManager.default
        let rootPath = FilesGroup.cacheDirectory
        let direcEnumerator = manager.enumerator(atPath: rootPath)
        var zipsList = [String]()
        
        while let file = direcEnumerator?.nextObject() as? String {
            if !file.contains(".zip") {
                continue
            }
            
            let fullPath = "\(rootPath)/\(file)"
            zipsList.append(fullPath)
        }
        
        for item in zipsList {
            removeUselessZip(item)
        }
    }
}
