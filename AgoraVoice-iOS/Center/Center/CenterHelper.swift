//
//  CenterHelper.swift
//
//  Created by CavanSu on 2020/3/9.
//  Copyright © 2020 Agora. All rights reserved.
//

import Foundation
import AlamoClient

protocol CenterHelper where Self: Center {
    func centerProvideLiveManager() -> EduManager
    func centerProvideLocalUser() -> CurrentUser
    func centerProvideMediaDevice() -> MediaDevice
    func centerProvideRequestHelper() -> AlamoClient
    func centerProvideImagesHelper() -> ImageFiles
    
    func centerProvideFilesGroup() -> FilesGroup
    
    func centerProvideLogTubeHelper() -> LogTube
    func centerProvideUserDataHelper() -> UserDataHelper
    func centerProvideOSSClient() -> AGOSSClient
}
