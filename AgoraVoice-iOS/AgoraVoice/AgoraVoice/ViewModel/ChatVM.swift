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
import Armin

struct Chat {
    var textSize: CGSize
    var content: NSAttributedString
    var image: UIImage?
    
    init(name: String, text: String, image: UIImage? = nil, widthLimit: CGFloat) {
        let tName = name
        let content = (tName + text) as NSString
        let textRect = content.boundingRect(with: CGSize(width: widthLimit, height: CGFloat(MAXFLOAT)),
                                            options: .usesLineFragmentOrigin,
                                            attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14, weight: .medium)],
                                            context: nil)
        
        let attrContent = NSMutableAttributedString(string: (content as String))
        
        attrContent.addAttributes([.foregroundColor: UIColor.white,
                                   .font: UIFont.systemFont(ofSize: 14, weight: .medium)],
                                  range: NSRange(location: 0, length: tName.count))
        
        attrContent.addAttributes([.foregroundColor: UIColor.white,
                                   .font: UIFont.systemFont(ofSize: 14)],
                                  range: NSRange(location: tName.count, length: text.utf16.count))
        
        var adjustSize = textRect.size
        adjustSize.width = adjustSize.width + 2
        self.textSize = adjustSize
        self.content = attrContent
        self.image = image
    }
}

class ChatVM: CustomObserver {
    var chatWidthLimit: CGFloat = UIScreen.main.bounds.width - 60
    var list = BehaviorRelay(value: [Chat]())
    
    func newMessages(_ chats: [Chat]) {
        var new = self.list.value
        new.insert(contentsOf: chats, at: 0)
        self.list.accept(new)
    }
}

private extension ChatVM {    
    func fake() {
        var list = [Chat]()
        for i in 0 ..< 40 {
            let name = "name\(i)"
            let message = "message\(i)vkdsavklnasdvkasvlknsdvklasdvnkldsvklnsdlkvnsdjb;dfabfa;ob;adnba;bjas;"
            let chat = Chat(name: name, text: message, widthLimit: chatWidthLimit)
            list.append(chat)
        }
        
        self.list.accept(list)
    }
}
