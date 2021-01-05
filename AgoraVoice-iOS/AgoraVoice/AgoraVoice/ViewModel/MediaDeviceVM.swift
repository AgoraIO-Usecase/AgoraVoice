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
import AgoraRte

class MediaDeviceVM: RxObject {
    let micStatus = BehaviorRelay<AGESwitch>(value: .off)
    let micAction = PublishRelay<AGESwitch>()
    let localAudioLoop = BehaviorRelay<AGESwitch>(value: .off)
    let audioOutput = BehaviorRelay(value: AgoraRteAudioOutputRouting.default)
    
    override init() {
        super.init()
        observe()
    }
    
    private func observe() {
        audioOutput.subscribe(onNext: { [unowned self] (routing) in
            if !routing.isSupportLoop {
                self.localAudioLoop.accept(.off)
            }
        }).disposed(by: bag)
    }
}

extension AgoraRteAudioOutputRouting {
    var isSupportLoop: Bool {
        switch self {
        case .default, .headsetNoMic, .loudspeaker, .speakerphone: return false
        default:                                                   return true
        }
    }
}
