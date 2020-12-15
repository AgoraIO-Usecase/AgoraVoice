//
//  CustomObserver.swift
//  AgoraLive
//
//  Created by CavanSu on 2020/8/11.
//  Copyright © 2020 Agora. All rights reserved.
//

import UIKit
import RxSwift
import RxRelay

class CustomObserver: RxObject, AGELogBase {
    lazy var logTube: LogTube = {
        return Center.shared().centerProvideLogTubeHelper()
    }()
    
    let message = PublishRelay<[String : Any]>()
    let fail = PublishRelay<String>()
}

extension CustomObserver {
    func log(info: String, extra: String? = nil, funcName: String = #function) {
        let className = type(of: self)
        logOutputInfo(info, extra: extra, className: className, funcName: funcName)
    }
    
    func log(warning: String, extra: String? = nil, funcName: String = #function) {
        let className = type(of: self)
        logOutputWarning(warning, extra: extra, className: className, funcName: funcName)
    }
    
    func log(error: Error, extra: String? = nil, funcName: String = #function) {
        let className = type(of: self)
        logOutputError(error, extra: extra, className: className, funcName: funcName)
    }
}
