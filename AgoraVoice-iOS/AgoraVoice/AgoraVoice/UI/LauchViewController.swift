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

class LauchViewController: RxViewController, ShowAlertProtocol {
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
                Keys.AgoraAppId = appId1
                self.centerRegister()
            } handler2: { [unowned self] (_) in
                Keys.AgoraAppId = appId2
                self.centerRegister()
            }
        }).disposed(by: bag)
        #else
        logoButton.isUserInteractionEnabled = false
        #endif
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.centerRegister()
    }
}

private extension LauchViewController {
    func centerRegister() {
        let center = Center.shared()
        center.registerAndLogin()
    }
}
