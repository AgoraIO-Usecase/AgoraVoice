//
//  AppDelegate.swift
//  AgoraVoice
//
//  Created by CavanSu on 2020/8/31.
//  Copyright © 2020 CavanSu. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        _ = Center.shared()
        return true
    }
}

