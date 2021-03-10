//
//  CenterHelper.swift
//
//  Created by CavanSu on 2020/3/9.
//  Copyright © 2020 Agora. All rights reserved.
//

import Foundation
import Armin
import AgoraRte

protocol CenterHelper where Self: Center {
    func centerProviderteEngine() -> AgoraRteEngine
    func centerProvideLocalUser() -> CurrentUser
    func centerProvideRequestHelper() -> Armin
    func centerProvideImagesHelper() -> ImageFiles
    func centerProvideAppAssistant() -> AppAssistant
    
    func centerProvideFilesGroup() -> FilesGroup
    
    func centerProvideLogTubeHelper() -> LogTube
    func centerProvideUserDataHelper() -> UserDataHelper
}
