//
//  LiveListVM.swift
//  AgoraLive
//
//  Created by CavanSu on 2020/2/21.
//  Copyright © 2020 Agora. All rights reserved.
//

import UIKit
import RxSwift
import RxRelay
import Armin

struct Room {
    var name: String
    var roomId: String
    var imageURL: String
    var personCount: Int
    var image: UIImage
    var owner: LiveRole
    
    init(name: String = "",
         roomId: String,
         imageURL: String = "",
         personCount: Int = 0,
         owner: LiveRole) {
        self.name = name
        self.roomId = roomId
        self.imageURL = imageURL
        self.personCount = personCount
        
        let images = Center.shared().centerProvideImagesHelper()
        let index = Int(Int64(self.roomId)! % Int64(images.roomPreviews.count))
        self.image = images.getRoomPreview(index: index)
        
        self.owner = owner
    }
    
    init(dic: StringAnyDic) throws {
        self.name = try dic.getStringValue(of: "roomName")
        self.roomId = try dic.getStringValue(of: "roomId")
        
        if let personCount = try? dic.getIntValue(of: "onlineUsers") {
            self.personCount = personCount
        } else {
            self.personCount = 0
        }
        
        if let imageURL = try? dic.getStringValue(of: "thumbnail") {
            self.imageURL = imageURL
        } else {
            self.imageURL = ""
        }
        
        let ownerJson = try dic.getDictionaryValue(of: "ownerUserInfo")
        self.owner = try LiveRoleItem(dic: ownerJson)
        
        let index = Int(try dic.getStringValue(of: "backgroundImage")) ?? 1
        let images = Center.shared().centerProvideImagesHelper()
        self.image = images.getRoomPreview(index: index)
    }
}

class LiveListVM: RxObject {
    fileprivate var chatRoomList = [Room]() {
        didSet {
            switch presentingType {
            case .chatRoom: presentingList.accept(chatRoomList)
            }
        }
    }
    
    var presentingType = LiveType.chatRoom {
        didSet {
            switch presentingType {
            case .chatRoom:
                presentingList.accept(chatRoomList)
            }
        }
    }
    
    var presentingList = BehaviorRelay(value: [Room]())
}

extension LiveListVM {
    func fake() {
        var temp = [Room]()
        
        for index in 0..<5 {
            let room = Room(name: "room\(index)",
                roomId: "\(index)",
                personCount: index,
                owner: LiveRoleItem(type: .owner,
                                    info: BasicUserInfo(userId: "index", name: ""),
                                    agUId: "0"))
            temp.append(room)
        }
        
        self.chatRoomList = temp
    }
    
    func fetch(count: Int = 10,
               success: Completion = nil,
               fail: Completion = nil) {
        guard let lastRoom = self.presentingList.value.last else {
            return
        }
        
        let client = Center.shared().centerProvideRequestHelper()
        let requestListType = presentingType
        let parameters: StringAnyDic = ["nextId": lastRoom.roomId,
                                        "count": count]

        let url = URLGroup.roomPage
        let event = ArRequestEvent(name: "room-page")
        let task = ArRequestTask(event: event,
                               type: .http(.get, url: url),
                               timeout: .low,
                               header: ["token": Keys.UserToken],
                               parameters: parameters)

        let successCallback: DicEXCompletion = { [weak self] (json: ([String: Any])) in
            guard let strongSelf = self else {
                return
            }

            let object = try json.getDataObject()
            let jsonList = try object.getValue(of: "list",
                                               type: [StringAnyDic].self)
            let list = try [Room](dicList: jsonList)

            switch requestListType {
            case .chatRoom:
                strongSelf.chatRoomList.append(contentsOf: list)
            }

            if let success = success {
                success()
            }
        }
        let response = ArResponse.json(successCallback)

        let retry: ArErrorRetryCompletion = { (error: Error) -> ArRetryOptions in
            if let fail = fail {
                fail()
            }
            return .resign
        }

        client.request(task: task,
                       success: response,
                       failRetry: retry)
    }
    
    func refetch(success: Completion = nil,
                 fail: Completion = nil) {
        let client = Center.shared().centerProvideRequestHelper()
        let requestListType = presentingType
        let currentCount = presentingList.value.count < 10 ? 10 : presentingList.value.count
        let parameters: StringAnyDic = ["count": currentCount]

        let url = URLGroup.roomPage
        let event = ArRequestEvent(name: "room-page-refetch")
        let task = ArRequestTask(event: event,
                               type: .http(.get, url: url),
                               timeout: .low,
                               header: ["token": Keys.UserToken],
                               parameters: parameters)

        let successCallback: DicEXCompletion = { [weak self] (json: ([String: Any])) in
            guard let strongSelf = self else {
                return
            }

            try json.getCodeCheck()
            let object = try json.getDataObject()
            let jsonList = try object.getValue(of: "list",
                                               type: [StringAnyDic].self)
            let list = try [Room](dicList: jsonList)

            switch requestListType {
            case .chatRoom:
                strongSelf.chatRoomList = list
            }

            if let success = success {
                success()
            }
        }
        let response = ArResponse.json(successCallback)

        let retry: ArErrorRetryCompletion = { (error: Error) -> ArRetryOptions in
            if let fail = fail {
                fail()
            }
            return .resign
        }

        client.request(task: task,
                       success: response,
                       failRetry: retry)
    }
}

fileprivate extension Array where Element == Room {
    init(dicList: [StringAnyDic]) throws {
        var array = [Room]()
        for item in dicList {
            let room = try Room(dic: item)
            array.append(room)
        }
        self = array
    }
}
