//
//  deviceVM.swift
//  AgoraLive
//
//  Created by CavanSu on 2020/4/18.
//  Copyright © 2020 Agora. All rights reserved.
//

import UIKit
import RxSwift
import RxRelay

class MediaDeviceVM: RxObject {
    var mic: AGESwitch = .on
   
//
//    var mic: AGESwitch {
//        get {
//            let mediaKit = Center.shared().centerProvideMediaHelper()
//            return mediaKit.capture.audio
//        }
//
//        set {
//            let mediaKit = Center.shared().centerProvideMediaHelper()
//            mediaKit.capture.audio = newValue
//        }
//    }
//
//    var localAudioLoop: AGESwitch {
//        get {
//            let mediaKit = Center.shared().centerProvideMediaHelper()
//            return mediaKit.player.isLocalAudioLoop ? .on : .off
//        }
//
//        set {
//            let mediaKit = Center.shared().centerProvideMediaHelper()
//            mediaKit.player.localInputAudioLoop(newValue)
//        }
//    }
//
//    var audioOutput: BehaviorRelay<AudioOutputRouting> = BehaviorRelay(value: AudioOutputRouting.default)
//
//    func audioLoop(_ action: AGESwitch) {
//        let mediaKit = Center.shared().centerProvideMediaHelper()
//        mediaKit.player.localInputAudioLoop(action)
//    }
//
    
    override init() {
        super.init()
        
    }
}
