//
//  ChatVM.swift
//  AgoraLive
//
//  Created by CavanSu on 2020/3/26.
//  Copyright © 2020 Agora. All rights reserved.
//

import UIKit
import RxSwift
import RxRelay
import AlamoClient

struct Chat {
    var textSize: CGSize
    var content: NSAttributedString
    var image: UIImage?
    
    init(name: String, text: String, image: UIImage? = nil) {
        let tName = name
        let content = (tName + text) as NSString
        let width = UIScreen.main.bounds.width - 60
        let textRect = content.boundingRect(with: CGSize(width: width, height: CGFloat(MAXFLOAT)),
                                            options: .usesLineFragmentOrigin,
                                            attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14, weight: .medium)],
                                            context: nil)
        
        let attrContent = NSMutableAttributedString(string: (content as String))
        
        attrContent.addAttributes([.foregroundColor: UIColor.white,
                                   .font: UIFont.systemFont(ofSize: 14, weight: .medium)],
                                  range: NSRange(location: 0, length: tName.count))
        
        attrContent.addAttributes([.foregroundColor: UIColor.white,
                                   .font: UIFont.systemFont(ofSize: 14)],
                                  range: NSRange(location: tName.count, length: text.count))
        
        var adjustSize = textRect.size
        adjustSize.width = adjustSize.width + 2
        self.textSize = adjustSize
        self.content = attrContent
        self.image = image
    }
}

class ChatVM: RTMObserver {
    var list = BehaviorRelay(value: [Chat]())
    
    override init() {
        super.init()
        observe()
    }
    
    deinit {
        #if !RELEASE
        print("deinit ChatVM")
        #endif
    }
    
    func newMessages(_ chats: [Chat]) {
        var new = self.list.value
        new.insert(contentsOf: chats, at: 0)
        self.list.accept(new)
    }
    
    func sendMessage(_ text: String, local: BasicUserInfo, needSparate: Bool = true, fail: ErrorCompletion = nil) {
//        let rtm = Center.shared().centerProvideRTMHelper()
//
//        let chat = ALChannelMessage.AType.chat.rawValue
//        let subJson: [String: Any] = ["fromUserId": local.userId, "fromUserName": local.name, "message": text]
//        let json: [String: Any] = ["cmd": chat, "data": subJson]
//        let jsonString = try! json.jsonString()
//
//        try? rtm.writeChannel(message: jsonString, of: RequestEvent(name: "chat-message"), success: { [weak self] in
//            guard let strongSelf = self else {
//                return
//            }
//            let new = Chat(name: local.name + ": ", text: text)
//            strongSelf.newMessages([new])
//        }, fail: fail)
    }
}

private extension ChatVM {
    func observe() {
//        let rtm = Center.shared().centerProvideRTMHelper()
//        rtm.addReceivedChannelMessage(observer: self.address) { [weak self] (json) in
//            guard let cmd = try? json.getEnum(of: "cmd", type: ALChannelMessage.AType.self) else {
//                return
//            }
//
//            guard cmd == .chat, let strongSelf = self else {
//                return
//            }
//
//            let data = try json.getDictionaryValue(of: "data")
//            let name = try data.getStringValue(of: "fromUserName")
//            let text = try data.getStringValue(of: "message")
//            let chat = Chat(name: name + ": ", text: text)
//            strongSelf.newMessages([chat])
//        }
    }
    
    func fake() {
        var list = [Chat]()
        for i in 0 ..< 40 {
            let name = "name\(i)"
            let message = "message\(i)vkdsavklnasdvkasvlknsdvklasdvnkldsvklnsdlkvnsdjb;dfabfa;ob;adnba;bjas;"
            let chat = Chat(name: name, text: message)
            list.append(chat)
        }
        
        self.list.accept(list)
    }
}
