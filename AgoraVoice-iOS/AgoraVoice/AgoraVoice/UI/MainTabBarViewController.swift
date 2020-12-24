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
    private lazy var lauchVC: LauchViewController = {
        let vc = UIStoryboard.initViewController(of: "LauchViewController",
                                                 class: LauchViewController.self,
                                                 on: "Popover")
        return vc
    }()
    
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
        UITabBar.appearance().barTintColor = UIColor(hexString: "#161D27")
        tabBar.isUserInteractionEnabled = false
        
        presentLauchScreen()
        
        #if RELEASE
        let center = Center.shared()
        center.registerAndLogin()
        #endif
        
        Center.shared().isWorkNormally.subscribe(onNext: { [unowned self] (normal) in
            if normal {
                self.tabBar.isUserInteractionEnabled = true
                self.dimissLauchScreen()
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

private extension MainTabBarViewController {
    func presentLauchScreen() {
        lauchVC.view.frame = UIScreen.main.bounds
        view.addSubview(lauchVC.view)
    }
    
    func dimissLauchScreen() {
        lauchVC.view.removeFromSuperview()
    }
}

extension UITabBar {
    static var height: CGFloat {
        return (UIScreen.main.isNotch ? 83 : 49)
    }
}
