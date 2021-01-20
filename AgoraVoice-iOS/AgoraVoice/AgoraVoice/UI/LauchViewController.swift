//
//  LauchViewController.swift
//  AgoraVoice
//
//  Created by Cavan on 2020/12/24.
//  Copyright © 2020 Agora. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class LauchViewController: MaskViewController {
    @IBOutlet weak var logoButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        #if !RELEASE
        logoButton.rx.controlEvent(.touchUpInside).subscribe(onNext: { [unowned self] in
            let appId1 = ""
            let appId1Short = ""
            
            let appId2 = ""
            let appId2Short = ""
            
            self.showAlert("Reset AppId",
                           action1: appId1Short,
                           action2: appId2Short) { [unowned self] (_) in
                self.showHUD()
                Keys.AgoraAppId = appId1
                self.centerRegister()
            } handler2: { [unowned self] (_) in
                self.showHUD()
                Keys.AgoraAppId = appId2
                self.centerRegister()
            }
        }).disposed(by: bag)
        #else
        logoButton.isUserInteractionEnabled = false
        #endif
        
        checkAppNeedUpdaate()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        #if !RELEASE
        self.showHUD()
        self.centerRegister()
        #endif
    }
}

private extension LauchViewController {
    func centerRegister() {
        let center = Center.shared()
        center.registerAndLogin()
    }
    
    func checkAppNeedUpdaate() {
        let app = Center.shared().centerProvideAppAssistant()
        app.updateNotification.subscribe(onNext: { [unowned self] (update) in
            self.ifNeedUpdateApp(update)
        }).disposed(by: bag)
                
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(appDidBecomeActiveCheckAppUpdate),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
    }
    
    @objc func appDidBecomeActiveCheckAppUpdate() {
        let app = Center.shared().centerProvideAppAssistant()
        self.ifNeedUpdateApp(app.update.value)
    }
    
    func ifNeedUpdateApp(_ update: AppUpdate) {
        guard update != .noNeed else {
            return
        }
        
        func openURL() {
            let urlString = URLGroup.appStore(AppAssistant.idOfAppStore)
            let url = URL(string: urlString)
            UIApplication.shared.privateOpenURL(url!)
        }
        
        switch update {
        case .noNeed:
            break
        case .advise:
            self.showAlert(LiveTypeLocalizable.suggestUpgradeApp(),
                           action1: NSLocalizedString("Cancel"),
                           action2: NSLocalizedString("Accept"),
                           handler2:  { (_) in
                            openURL()
                           })
        case .need:
            self.showAlert(LiveTypeLocalizable.mustUpgrateApp()) { (_) in
                openURL()
            }
        }
    }
}
