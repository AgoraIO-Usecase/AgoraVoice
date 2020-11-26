//
//  MediaInfo.swift
//  OpenVideoCall
//
//  Created by GongYuhua on 4/11/16.
//  Copyright © 2016 Agora. All rights reserved.
//

import Foundation
import AgoraRte

struct RTCStatistics {
    var localAudioStats: AgoraRteLocalAudioStats?
}

extension AgoraRteLocalAudioStats {
    open override var description: String {
        let join = "\n"
        let numChannels = "numChannels: \(self.numChannels)"
        let sentSampleRate = "sentSampleRate: \(self.sentSampleRate)"
        let sentBitrate = "sentBitrate: \(self.sentBitrate)"
        
        return numChannels + join + sentSampleRate + join + sentBitrate
    }
}
