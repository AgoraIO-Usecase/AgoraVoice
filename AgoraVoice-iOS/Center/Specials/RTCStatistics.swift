//
//  MediaInfo.swift
//  OpenVideoCall
//
//  Created by GongYuhua on 4/11/16.
//  Copyright © 2016 Agora. All rights reserved.
//

import Foundation
import AgoraRte

struct RTEStatistics {
    var localAudioStats: AgoraRteLocalAudioStats?
    var sceneStats: AgoraRteSceneStats?
    
    var description: String? {
        var text = ""
        
        if let audio = localAudioStats {
            text += (audio.description + "\n")
        }
        
        if let scene = sceneStats {
            text += scene.description
        }
        
        if text.count > 0 {
            return text
        } else {
            return nil
        }
    }
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

extension AgoraRteSceneStats {
    open override var description: String {
        let join = "\n"
        let lastmileDelay = "Lastmile Delay: \(self.lastmileDelay)"
        let audioSendRecv = "Audio Send/Recv: \(self.txAudioKBitrate)kbps/\(self.rxAudioKBitrate)kbps"
        let cpu = "CPU: App/Total \(self.cpuAppUsage)%/\(self.cpuTotalUsage)%"
        let sendRecvLoss = "Send/Recv Loss: \(self.txPacketLossRate)%/\(self.rxPacketLossRate)%"

        return lastmileDelay + join + audioSendRecv + join + cpu + join + sendRecvLoss
    }
}
