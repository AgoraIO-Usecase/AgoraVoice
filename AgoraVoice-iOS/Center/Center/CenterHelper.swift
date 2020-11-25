//
//  CenterHelper.swift
//
//  Created by CavanSu on 2020/3/9.
//  Copyright © 2020 Agora. All rights reserved.
//

import Foundation
import Armin

protocol CenterHelper where Self: Center {
    func centerProvideLocalUser() -> CurrentUser
    func centerProvideMediaDevice() -> MediaDevice
    func centerProvideRequestHelper() -> Armin
    func centerProvideImagesHelper() -> ImageFiles
    func centerProvideAppAssistant() -> AppAssistant
    
    func centerProvideFilesGroup() -> FilesGroup
    
    func centerProvideLogTubeHelper() -> LogTube
    func centerProvideUserDataHelper() -> UserDataHelper
}
