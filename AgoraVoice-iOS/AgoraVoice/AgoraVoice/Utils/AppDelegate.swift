//
//  AppDelegate.swift
//  AgoraVoice
//
//  Created by CavanSu on 2020/8/31.
//  Copyright © 2020 Agora. All rights reserved.
//

import UIKit
import Bugly

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        enableBugly()
        
        return true
    }
    
    func enableBugly() {
        let config = BuglyConfig()
        let buglyId = Keys.BuglyId
        Bugly.start(withAppId: buglyId,
                    config: config)
    }
}

