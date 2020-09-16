//
//  AppDelegate.swift
//  AgoraVoice
//
//  Created by CavanSu on 2020/8/31.
//  Copyright © 2020 Agora. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let center = Center.shared()
        let appAssistant = center.centerProvideAppAssistant()
        appAssistant.checkMinVersion()
        center.registerAndLogin()
        return true
    }
}

