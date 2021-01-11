//
//  Localizable.swift
//  AgoraVoice
//
//  Created by Cavan on 2020/12/30.
//  Copyright © 2020 Agora. All rights reserved.
//

import UIKit

// MARK: - LiveTypeLocalizable
class LiveTypeLocalizable: NSObject {
    static func startButton() -> String {
        if DeviceAssistant.Language.isChinese {
            return "开始聊天"
        } else {
            return "Start"
        }
    }
    
    static func suggestUpgradeApp() -> String {
        if DeviceAssistant.Language.isChinese {
            return "建议升级应用"
        } else {
            return "Check the new version"
        }
    }
    
    static func mustUpgrateApp() -> String {
        if DeviceAssistant.Language.isChinese {
            return "必须要升级应用才可继续使用"
        } else {
            return "Please update the app"
        }
    }
}

// MARK: - MineLocalizable
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
    
    static func about() -> String {
        if DeviceAssistant.Language.isChinese {
            return "关于"
        } else {
            return "About"
        }
    }
    
    static func inputName() -> String {
        if DeviceAssistant.Language.isChinese {
            return "输入名字"
        } else {
            return "Input"
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
    
    static func uploadLogFail() -> String {
        if DeviceAssistant.Language.isChinese {
            return "上传日志失败"
        } else {
            return "Log upload fails"
        }
    }
    
    static func logIdCopy() -> String {
        if DeviceAssistant.Language.isChinese {
            return "LogId 已经复制到粘贴板"
        } else {
            return "LogId copied to the pasteboard"
        }
    }
    
    static func updateNicknameFail() -> String {
        if DeviceAssistant.Language.isChinese {
            return "更新昵称失败"
        } else {
            return "Nickname update fails"
        }
    }
    
    static func nicknameMaxLengthLimit(_ limit: UInt) -> String {
        if DeviceAssistant.Language.isChinese {
            return "用户名称不能超过\(limit)个字符"
        } else {
            return "Maximum length of user name is \(limit)"
        }
    }
    
    static func nicknameMinLengthLimit() -> String {
        if DeviceAssistant.Language.isChinese {
            return "昵称不可为空"
        } else {
            return "Nickname cannot be blank"
        }
    }
}

// MARK: - LiveListLocalizable
class LiveListLocalizable: NSObject {
    static func createChannelToStart() -> String  {
        if DeviceAssistant.Language.isChinese {
            return "请创建一个房间"
        } else {
            return "Create a channel to start"
        }
    }
    
    static func joinChannelFail() -> String {
        if DeviceAssistant.Language.isChinese {
            return "加入房间失败"
        } else {
            return "Fails to join the room"
        }
    }
    
    static func joinChannelFailWithLimit() -> String {
        if DeviceAssistant.Language.isChinese {
            return "房间最大人数为10人"
        } else {
            return "The max number of participants per channel is 10"
        }
    }
}

// MARK: - CreateLiveLocalizable
class CreateLiveLocalizable: NSObject {
    static func channelName() -> String  {
        if DeviceAssistant.Language.isChinese {
            return "直播间名字: "
        } else {
            return "Channel name: "
        }
    }
    
    static func startButton() -> String  {
        if DeviceAssistant.Language.isChinese {
            return "开始直播"
        } else {
            return "Go live"
        }
    }
    
    static func createChannelFail() -> String {
        if DeviceAssistant.Language.isChinese {
            return "创建房间失败"
        } else {
            return "Fails to create a room"
        }
    }
    
    static func joinChannelFail() -> String {
        if DeviceAssistant.Language.isChinese {
            return "加入房间失败"
        } else {
            return "Fails to join the room"
        }
    }
    
    static func channelNameCannotBebBlank() -> String {
        if DeviceAssistant.Language.isChinese {
            return "房间名不能为空 "
        } else {
            return "Channel name cannot be blank"
        }
    }
    
    static func channelNameLengthLimit(_ limit: UInt) -> String {
        if DeviceAssistant.Language.isChinese {
            return "房间名称不能超过\(limit)个字符"
        } else {
            return "Maximum length of channel name is \(limit)"
        }
    }
}

// MARK: - LiveVCLocalizable
class LiveVCLocalizable: NSObject {
    static func liveStreamingTimeout() -> String {
        if DeviceAssistant.Language.isChinese {
            return "此软件房间最长直播时间为10分钟"
        } else {
            return "The max duration per session is 10 minutes"
        }
    }
    
    static func liveStreamingEnds() -> String {
        if DeviceAssistant.Language.isChinese {
            return "直播结束";
        } else {
            return "Live streaming ends"
        }
    }
    
    static func sendGift(receiver: String) -> String {
        if DeviceAssistant.Language.isChinese {
            return "送\(receiver)"
        } else {
            return "gives \(receiver)"
        }
    }
    
    static func giveGiftAction() -> String {
        if DeviceAssistant.Language.isChinese {
            return "赠送"
        } else {
            return "Give"
        }
    }
    
    static func leaveChannel() -> String {
        if DeviceAssistant.Language.isChinese {
            return "确定退出直播间？"
        } else {
            return "Leave channel?"
        }
    }
    
    static func thisWillEndTheSession() -> String {
        if DeviceAssistant.Language.isChinese {
            return "退出房间会终止您与房主的连线？"
        } else {
            return "This will end the session"
        }
    }
      
    static func liveSteamingEnds() -> String {
        if DeviceAssistant.Language.isChinese {
            return "直播结束"
        } else {
            return "Live streaming ends"
        }
    }
    
    static func doYouWantToEndThisLiveSession() -> String {
        if DeviceAssistant.Language.isChinese {
            return "是否结束直播？"
        } else {
            return "Do you want to end this live session?"
        }
    }
    
    static func someoneJoinedChannel() -> String {
        if DeviceAssistant.Language.isChinese {
            return "加入房间"
        } else {
            return "joined channel"
        }
    }
    
    static func someoneLeftChannel() -> String {
        if DeviceAssistant.Language.isChinese {
            return "离开房间"
        } else {
            return "left channel"
        }
    }
    
    static func sendChatFail() -> String {
        if DeviceAssistant.Language.isChinese {
            return "发送聊天消息失败"
        } else {
            return "Fails to send the text message"
        }
    }
    
    static func giveGiftFail() -> String {
        if DeviceAssistant.Language.isChinese {
            return "赠送礼物失败"
        } else {
            return "Fails the send the gift"
        }
    }
    
    // Bottom tools bar
    static func chatInputPlaceholder() -> String {
        if DeviceAssistant.Language.isChinese {
            return "说点什么..."
        } else {
            return "Say something..."
        }
    }
    
    static func audioLoopButton() -> String {
        if DeviceAssistant.Language.isChinese {
            return "耳返"
        } else {
            return "Monitor"
        }
    }
    
    static func audioLoopButtonAlert() -> String {
        if DeviceAssistant.Language.isChinese {
            return "请插上耳机"
        } else {
            return "Plug in a headset"
        }
    }
    
    static func backgroundButton() -> String {
        return NSLocalizedString("Background")
    }
    
    static func statisticsButton() -> String {
        if DeviceAssistant.Language.isChinese {
            return "实时数据"
        } else {
            return "Statistics"
        }
    }
    
    static func userList() -> String {
        if DeviceAssistant.Language.isChinese {
            return "成员列表"
        } else {
            return "Member listing"
        }
        
    }
    
    static func onlineUser() -> String {
        if DeviceAssistant.Language.isChinese {
            return "在线用户"
        } else {
            return "Users"
        }
    }
    
    static func allUsers() -> String {
        if DeviceAssistant.Language.isChinese {
            return "全部"
        } else {
            return "All"
        }
    }
}

// MARK: - AudioEffectsLocalizable
class AudioEffectsLocalizable: NSObject {
    static func selectTheStartingKey() -> String {
        if DeviceAssistant.Language.isChinese {
            return "选择起始音阶"
        } else {
            return "Select the starting key"
        }
    }
    
    static func selectMode() -> String {
        if DeviceAssistant.Language.isChinese {
            return "选择调式"
        } else {
            return "Select mode"
        }
    }
    
    static func enablePitchCorrection() -> String {
        if DeviceAssistant.Language.isChinese {
            return "启用电音"
        } else {
            return "Enable pitch correction"
        }
    }
    
    static func threeDimensionalVoice() -> String {
        if DeviceAssistant.Language.isChinese {
            return "3D人声"
        } else {
            return "3D voice"
        }
    }
    
    static func threeDimensionalVoiceDescription() -> String {
        if DeviceAssistant.Language.isChinese {
            return "速度调节控制声音旋转速度"
        } else {
            return "Speed adjustment controls the speed of sound rotation"
        }
    }
    
    static func threeDimensionalVoiceDescription2() -> String {
        if DeviceAssistant.Language.isChinese {
            return "最快1s转一圈，最慢60s转一圈"
        } else {
            return "The fastest is 60 rpm, the slowest is 1 rpm"
        }
    }
    
    static func major() -> String {
        if DeviceAssistant.Language.isChinese {
            return "大调"
        } else {
            return "Major"
        }
    }
    
    static func minor() -> String {
        if DeviceAssistant.Language.isChinese {
            return "小调"
        } else {
            return "Minor"
        }
    }
    
    static func japeneseStyle() -> String {
        if DeviceAssistant.Language.isChinese {
            return "和风"
        } else {
            return "Japenese-Pantatonic"
        }
    }
    
    static func comingSoon() -> String {
        if DeviceAssistant.Language.isChinese {
            return "即将发布"
        } else {
            return "Coming soon"
        }
    }
}

// MARK: - ChatRoomLocalizable
class ChatRoomLocalizable: NSObject {
    // Owner
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
    
    static func closeSeatTitle() -> String {
        if DeviceAssistant.Language.isChinese {
            return "确定封麦？"
        } else {
            return "Close seat?"
        }
    }
    
    static func closeSeatDescription() -> String {
        if DeviceAssistant.Language.isChinese {
            return "如果当前麦位上已有主播，将会被下麦"
        } else {
            return "Co-hosting fails if the seat is occupied"
        }
    }
    
    static func openSeat() -> String {
        if DeviceAssistant.Language.isChinese {
            return "解封麦位？"
        } else {
            return "Open seat?";
        }
    }
    
    static func forceBroacasterToBecomeAudience(userName: String) -> String {
        if DeviceAssistant.Language.isChinese {
            return "确定将\(userName)下麦?"
        } else {
            return "Stop \(userName) from co-hosting?"
        }
    }
    
    static func sendInvitation(to userName: String) -> String {
        if DeviceAssistant.Language.isChinese {
            return "你是否要邀请\(userName)上麦?"
        } else {
            return "Co-hosting invitation to \(userName)?"
        }
    }
    
    static func doYouRejectApplication(from: String) -> String {
        if DeviceAssistant.Language.isChinese {
            return "你是否要拒绝\(from)的上麦申请？"
        } else {
            return "Do you reject \(from)'s request?"
        }
    }
    
    static func doYouAcceptApplication(from: String) -> String {
        if DeviceAssistant.Language.isChinese {
            return "你是否要接受\(from)的上麦申请？"
        } else {
            return "Do you accept \(from)'s request?"
        }
    }
    
    static func rejectThisInvitation(from: String) -> String {
        if DeviceAssistant.Language.isChinese {
            return "\(from)拒绝了这次邀请"
        } else {
            return "\(from) rejected Co-hosting invitation"
        }
    }
    
    static func invitationTimeout() -> String {
        if DeviceAssistant.Language.isChinese {
            return "邀请超时"
        } else {
            return "Request timeout"
        }
    }
    
    static func thisSeatHasBeenTakenUp() -> String {
        if DeviceAssistant.Language.isChinese {
            return "麦位已经被占用，请选择其他麦位"
        } else {
            return "Seat is occupied. Please try another seat"
        }
    }
    
    // Broadcaster
    static func ownerForcedYouToBecomeAudience() -> String {
        if DeviceAssistant.Language.isChinese {
            return "您已被下麦"
        } else {
            return "The host changes your role to audience"
        }
    }
    
    static func stopBroadcasting() -> String {
        if DeviceAssistant.Language.isChinese {
            return "确定终止连麦？"
        } else {
            return "Stop co-hosting?"
        }
    }
    
    // Audience
    static func doYouSendApplication() -> String {
        if DeviceAssistant.Language.isChinese {
            return "确定申请上麦？"
        } else {
            return "Request co-hosting?"
        }
    }
    
    static func yourApplicationHasBeenSent() -> String {
        if DeviceAssistant.Language.isChinese {
            return "您的上麦申请已发送"
        } else {
            return "Co-hosting request sent"
        }
    }
    
    static func yourApplicaitonSentFail() -> String {
        if DeviceAssistant.Language.isChinese {
            return "上麦申请发送失败"
        } else {
            return "Co-hosting request fails"
        }
    }
    
    static func ownerAcceptedYourApplication() -> String {
        if DeviceAssistant.Language.isChinese {
            return "房主已通过您的上麦申请"
        } else {
            return "Co-hosting request approved"
        }
    }
    
    static func ownerRejectedYourApplication() -> String {
        if DeviceAssistant.Language.isChinese {
            return "房主已拒绝您的上麦申请"
        } else {
            return "Co-hosting request rejected"
        }
    }
    
    static func doYouAgreeToBecomeHost(owner: String) -> String {
        if DeviceAssistant.Language.isChinese {
            return "\(owner)邀请您上麦，是否接受？"
        } else {
            return "Do you accept the invitation to become a co-host?"
        }
    }
    
    // Others
    static func someoneStartCoHosting() -> String {
        if DeviceAssistant.Language.isChinese {
            return "上麦"
        } else {
            return "becomes a co-host"
        }
    }
    
    static func someoneStopCoHosting() -> String {
        if DeviceAssistant.Language.isChinese {
            return "下麦"
        } else {
            return "becomes an audience"
        }
    }
    
    static func applicationList() -> String {
        if DeviceAssistant.Language.isChinese {
            return "申请上麦"
        } else {
            return "Request for co-hosting"
        }
    }
    
    static func coHostingActionFail() -> String {
        if DeviceAssistant.Language.isChinese {
            return "操作失败"
        } else {
            return "Operation fails"
        }
    }
}

// MARK: - NetworkLocalizable
class NetworkLocalizable: NSObject {
    static func lostConnection() -> String {
        if DeviceAssistant.Language.isChinese {
            return "网络异常"
        } else {
            return "Network error"
        }
    }
    
    static func lostConnectionDescription() -> String {
        if DeviceAssistant.Language.isChinese {
            return "当前网络连接错误，请稍后再试"
        } else {
            return "Cannot connect to network now. Please retry later"
        }
    }
    
    static func lostConnectionRetry() -> String {
        if DeviceAssistant.Language.isChinese {
            return "网络不给力，请稍后再试"
        } else {
            return "Connection lost. Please retry later"
        }
    }
    
    static func useCellularData() -> String {
        if DeviceAssistant.Language.isChinese {
            return "当前网络无WIFI，继续使用可能产生流量费用"
        } else {
            return "Use cellular data instead of WIFI. May incur data charges"
        }
    }
}
