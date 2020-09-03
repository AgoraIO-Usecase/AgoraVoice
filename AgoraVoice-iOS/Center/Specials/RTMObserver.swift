//
//  RTMObserver.swift
//  AgoraLive
//
//  Created by CavanSu on 2020/8/11.
//  Copyright © 2020 Agora. All rights reserved.
//

import UIKit
import RxSwift
import RxRelay

class RTMObserver: NSObject {
    let bag = DisposeBag()
    var address: String!
    
    override init() {
        super.init()
        self.address = String(format: "%p", self)
    }
    
    deinit {
//        let rtm = Center.shared().centerProvideRTMHelper()
//        rtm.removeReceivedPeerMessage(observer: self.address)
//        rtm.removeReceivedChannelMessage(observer: self.address)
    }
}
