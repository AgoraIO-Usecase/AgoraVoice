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
    private var operatorObj: MediaDevice
    
    let mic = BehaviorRelay<AGESwitch>(value: .off)
    let localAudioLoop = BehaviorRelay<AGESwitch>(value: .off)
    let audioOutput: BehaviorRelay<AudioOutputRouting> = BehaviorRelay(value: AudioOutputRouting.default)
    
    override init() {
        let operatorObj = Center.shared().centerProvideMediaDevice()
        self.operatorObj = operatorObj
        super.init()
        operatorObj.delegate = self
        observe()
    }
}

private extension MediaDeviceVM {
    func observe() {
        localAudioLoop.subscribe(onNext: { [unowned self] (isOn) in
            self.operatorObj.recordAudioLoop(isOn.boolValue)
        }).disposed(by: bag)
    }
}

extension MediaDeviceVM: MediaDeviceDelegate {
    func mediaDevice(_ mediaDevice: MediaDevice, didChangeAudoOutputRouting routing: AudioOutputRouting) {
        audioOutput.accept(routing)
    }
}

extension AudioOutputRouting {
    var isSupportLoop: Bool {
        switch self {
        case .default, .headsetNoMic, .loudspeaker, .speakerphone: return false
        default:                                                   return true
        }
    }
}
