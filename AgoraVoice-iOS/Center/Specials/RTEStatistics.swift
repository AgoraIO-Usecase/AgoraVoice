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
        let colon = ": "
        let join = "\n"
        var text = ""
        
        // channels
        let channels = localAudioStats?.numChannels ?? 0
        let channelsText = RTEStatisticLocalizable.audioChannels()
            + colon
            + "\(channels)"
        
        // tx sample rate
        let txSampleRate = localAudioStats?.sentSampleRate ?? 0
        let txSampleRateText = RTEStatisticLocalizable.audioTxSampleRate()
            + colon
            + "\(txSampleRate)"
        
        // tx bitrate
        let txBitrate = sceneStats?.txAudioKBitrate ?? 0
        let txBitrateText = RTEStatisticLocalizable.audioTxBitrate()
            + colon
            + "\(txBitrate)kbps"
        
        // tx packet loss rate
        let txPacketLossRate = sceneStats?.txPacketLossRate ?? 0
        let txPacketLossRateText = RTEStatisticLocalizable.audioTxPacketLossRate()
            + colon
            + "\(txPacketLossRate)%"
        
        // rx bitrate
        let rxBirate = sceneStats?.rxAudioKBitrate ?? 0
        let rxBirateText = RTEStatisticLocalizable.audioRxBitrate()
            + colon
            + "\(rxBirate)kbps"
        
        // rx packet loss rate
        let rxPacketLossRate = sceneStats?.rxPacketLossRate ?? 0
        let rxPacketLossRateText = RTEStatisticLocalizable.audioRxPacketLossRate()
            + colon
            + "\(rxPacketLossRate)%"
        
        // delay
        let delay = sceneStats?.lastmileDelay ?? 0
        let delayText = RTEStatisticLocalizable.delay()
            + colon
            + "\(delay)ms"
        
        text = channelsText + join
            + txSampleRateText + join
            + txBitrateText + join
            + txPacketLossRateText + join
            + rxBirateText + join
            + rxPacketLossRateText + join
            + delayText
            
        return text
    }
}

// MARK: - RTE statistic
class RTEStatisticLocalizable: NSObject {
    // Audio tx
    static func audioChannels() -> String {
        if DeviceAssistant.Language.isChinese {
            return "音频上行声道数"
        } else {
            return "Audio tx channels"
        }
    }
    
    static func audioTxSampleRate() -> String {
        if DeviceAssistant.Language.isChinese {
            return "音频上行采样率"
        } else {
            return "Audio tx sample rate"
        }
    }
    
    static func audioTxBitrate() -> String {
        if DeviceAssistant.Language.isChinese {
            return "音频上行码率"
        } else {
            return "Audio tx bitrate"
        }
    }
    
    static func audioTxPacketLossRate() -> String {
        if DeviceAssistant.Language.isChinese {
            return "音频上行丢包率"
        } else {
            return "Audio tx packet loss rate"
        }
    }
    
    // Audio rx
    static func audioRxBitrate() -> String {
        if DeviceAssistant.Language.isChinese {
            return "音频下行码率"
        } else {
            return "Audio rx bitrate"
        }
    }
    
    static func audioRxPacketLossRate() -> String {
        if DeviceAssistant.Language.isChinese {
            return "音频下行丢包率"
        } else {
            return "Audio rx packet loss rate"
        }
    }
    
    static func delay() -> String {
        if DeviceAssistant.Language.isChinese {
            return "延迟"
        } else {
            return "Delay"
        }
    }
}
