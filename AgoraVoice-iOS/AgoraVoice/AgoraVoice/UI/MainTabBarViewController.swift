//
//  MainTabBarViewController.swift
//  AgoraLive
//
//  Created by CavanSu on 2020/3/3.
//  Copyright © 2020 Agora. All rights reserved.
//

import UIKit
import RxSwift

class MainTabBarViewController: MaskTabBarController {
    let bag = DisposeBag()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        for child in children {
            if let item = child as? CSNavigationController {
                item.statusBarStyle = .lightContent
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UITabBar.appearance().barTintColor = .black
        tabBar.isUserInteractionEnabled = false
        showHUD()

        Center.shared().isWorkNormally.subscribe(onNext: { [unowned self] (normal) in
            if normal {
                self.tabBar.isUserInteractionEnabled = true
                self.hiddenHUD()
            }
        }).disposed(by: bag)
    }
    
    func findFirstChild<T: Any>(of class: T.Type) -> T? {
        var target: T?
        
        for child in children {
            if child is T {
                target = child as? T
                break
            }
            
            for item in child.children where item is T {
                target = item as? T
                break
            }
            
            if let _ = target {
                break
            }
        }
        
        return target
    }
}

extension UITabBar {
    static var height: CGFloat {
        return (UIScreen.main.isNotch ? 83 : 49)
    }
}
