//
//  Localizable.swift
//  AgoraVoice
//
//  Created by Cavan on 2020/12/30.
//  Copyright © 2020 Agora. All rights reserved.
//

import UIKit

class LiveVCLocalizable: NSObject {
    static func liveTimeout() -> String {
        if DeviceAssistant.Language.isChinese {
            return "此软件房间最长直播时间为10分钟"
        } else {
            return "The max duration per session is 10 minutes"
        }
    }
}

class MineLocalizable: NSObject {
    static func headSetting() -> String {
        if DeviceAssistant.Language.isChinese {
            return "设置头像"
        } else {
            return "Profile"
        }
    }
    
    static func nicknameSetting() -> String {
        if DeviceAssistant.Language.isChinese {
            return "设置昵称"
        } else {
            return "Nickname"
        }
    }
    
    static func inputName() -> String {
        if DeviceAssistant.Language.isChinese {
            return "输入名字"
        } else {
            return "Input"
        }
    }
    
    static func about() -> String {
        if DeviceAssistant.Language.isChinese {
            return "关于"
        } else {
            return "About"
        }
    }
    
    static func privacy() -> String {
        if DeviceAssistant.Language.isChinese {
            return "隐私条例"
        } else {
            return "Privacy"
        }
    }
    
    static func disclaimer() -> String {
        if DeviceAssistant.Language.isChinese {
            return "产品免责声明"
        } else {
            return "Disclaimer"
        }
    }
    
    static func registerAgoraAccount() -> String {
        if DeviceAssistant.Language.isChinese {
            return "注册声网账号"
        } else {
            return "Agora Account"
        }
    }
    
    static func releaseDate() -> String {
        if DeviceAssistant.Language.isChinese {
            return "发版时间"
        } else {
            return "Release Date"
        }
    }
    
    static func sdkVersion() -> String {
        if DeviceAssistant.Language.isChinese {
            return "SDK 版本"
        } else {
            return "SDK Version"
        }
    }
    
    static func appVersion() -> String {
        if DeviceAssistant.Language.isChinese {
            return "Agora Voice 版本"
        } else {
            return "Agora Voice Version"
        }
    }
    
    static func uploadLog() -> String {
        if DeviceAssistant.Language.isChinese {
            return "上传日志"
        } else {
            return "Upload Log"
        }
    }
}

class ChatRoomLocalizable: NSObject {
    static func doYouRejectApplication(from: String) -> String {
        if DeviceAssistant.Language.isChinese {
            return "你是否要拒绝\(from)的上麦申请?"
        } else {
            return "Do you reject \(from)'s application?"
        }
    }
    
    static func doYouAcceptApplication(from: String) -> String {
        if DeviceAssistant.Language.isChinese {
            return "你是否要接受\(from)的上麦申请?"
        } else {
            return "Do you accept \(from)'s application?"
        }
    }
    
    static func rejectThisInvitation() -> String {
        if DeviceAssistant.Language.isChinese {
            return "拒绝了这次邀请"
        } else {
            return "rejected this invitation"
        }
    }
    
    static func ownerForcedYouToBecomeAudience() -> String {
        if DeviceAssistant.Language.isChinese {
            return "房主强迫你下麦"
        } else {
            return "Owner forced you to becmoe a audience"
        }
    }
    
    static func doYouAgreeToBecomeHost(owner: String) -> String {
        if DeviceAssistant.Language.isChinese {
            return "\(owner)邀请您上麦，是否接受"
        } else {
            return "Do you agree to become a host?"
        }
    }
    
    static func muteSomeOne(userName: String) -> String {
        if DeviceAssistant.Language.isChinese {
            return "禁止\(userName)发言?"
        } else {
            return "Mute \(userName)?"
        }
    }
    
    static func ummuteSomeOne(userName: String) -> String {
        if DeviceAssistant.Language.isChinese {
            return "解除\(userName)禁言?"
        } else {
            return "Unmute \(userName)?"
        }
    }
    
    static func forceBroacasterToBecomeAudience(userName: String) -> String {
        if DeviceAssistant.Language.isChinese {
            return "确定将\(userName)下麦?"
        } else {
            return "Stop \(userName) hosting"
        }
    }
    
    static func blockThisSeat() -> String {
        if DeviceAssistant.Language.isChinese {
            return "将关闭该麦位，如果该位置上有用户，将下麦该用户"
        } else {
            return "Block this seat"
        }
    }
    
    static func unblockThisSeat() -> String {
        if DeviceAssistant.Language.isChinese {
            return "解封此连麦位"
        } else {
            return "Unblock this seat";
        }
    }
    
    static func sendInvitation(to userName: String) -> String {
        if DeviceAssistant.Language.isChinese {
            return "你是否要邀请\(userName)上麦?"
        } else {
            return "Do you send a invitation to \(userName)?"
        }
    }
    
    static func stopBroadcasting() -> String {
        if DeviceAssistant.Language.isChinese {
            return "确定终止连麦？"
        } else {
            return "End Live Streaming?"
        }
    }
    
    static func doYouSendApplication() -> String {
        if DeviceAssistant.Language.isChinese {
            return "你确定要\"申请上麦\"吗？"
        } else {
            return "Do you send a application?"
        }
    }
    
    static func yourApplicationHasBeenSent() -> String {
        if DeviceAssistant.Language.isChinese {
            return "您的上麦申请已发送"
        } else {
            return "Your application has been sent"
        }
    }
}
