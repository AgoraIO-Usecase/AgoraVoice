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
    let mic = BehaviorRelay<AGESwitch>(value: .off)
    let localAudioLoop = BehaviorRelay<AGESwitch>(value: .off)
    let audioOutput: BehaviorRelay<AgoraRteAudioOutputRouting> = BehaviorRelay(value: AgoraRteAudioOutputRouting.default)
}

extension AgoraRteAudioOutputRouting {
    var isSupportLoop: Bool {
        switch self {
        case .default, .headsetNoMic, .loudspeaker, .speakerphone: return false
        default:                                                   return true
        }
    }
}
