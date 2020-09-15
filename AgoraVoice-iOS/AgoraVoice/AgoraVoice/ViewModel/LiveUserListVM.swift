//
//  LiveUserListVM.swift
//  AgoraLive
//
//  Created by CavanSu on 2020/3/20.
//  Copyright © 2020 Agora. All rights reserved.
//

import UIKit
import RxSwift
import RxRelay
import AlamoClient

fileprivate enum UserJoinOrLeft: Int {
    case left, join
}

fileprivate extension Array where Element == (UserJoinOrLeft, LiveRoleItem) {
    init(list: [StringAnyDic]) throws {
        var array = [(UserJoinOrLeft, LiveRoleItem)]()
        for item in list {
            let user = try LiveRoleItem(dic: item)
            let join = try item.getEnum(of: "state", type: UserJoinOrLeft.self)
            array.append((join, user))
        }
        self = array
    }
}

fileprivate extension Array where Element == LiveRoleItem {
    init(dicList: [StringAnyDic]) throws {
        var array = [LiveRoleItem]()
        for item in dicList {
            let user = try LiveRoleItem(dic: item)
            array.append(user)
        }
        self = array
    }
}

class LiveUserListVM: CustomObserver {
    private var room: Room

    var giftList = BehaviorRelay(value: [LiveRoleItem]())

    var list = BehaviorRelay(value: [LiveRole]())
    var audienceList = BehaviorRelay(value: [LiveRole]())

    var joined = PublishRelay<[LiveRole]>()
    var left = PublishRelay<[LiveRole]>()
    var total = BehaviorRelay(value: 0)
    
    init(room: Room) {
        self.room = room
        super.init()
        observe()
    }
    
    deinit {
        #if !RELEASE
        print("deinit LiveUserListVM")
        #endif
    }
    
    func updateGiftListWithJson(list: [StringAnyDic]?) {
        guard let list = list, list.count > 0 else {
            return
        }
        
        let tList = try! Array(dicList: list)
        giftList.accept(tList)
    }
    
    func fetch(count: Int = 10, onlyAudience: Bool = true, success: Completion = nil, fail: Completion = nil) {
//        guard let last = self.list.value.last else {
//            return
//        }
//
//        let client = Center.shared().centerProvideRequestHelper()
//        let parameters: StringAnyDic = ["nextId": last.info.userId,
//                                        "count": count,
//                                        "type": onlyAudience ? 2 : 1]
//
//        let url = URLGroup.userList(roomId: room.roomId)
//        let event = RequestEvent(name: "live-user-list")
//        let task = RequestTask(event: event,
//                               type: .http(.get, url: url),
//                               timeout: .low,
//                               header: ["token": Keys.UserToken],
//                               parameters: parameters)
//
//        let successCallback: DicEXCompletion = { [weak self] (json: ([String: Any])) in
//            guard let strongSelf = self else {
//                return
//            }
//
//            let data = try json.getDataObject()
//            let listJson = try data.getListValue(of: "list")
//            let new = try Array(dicList: listJson)
//
//            if onlyAudience {
//                var list = strongSelf.audienceList.value
//                list.append(contentsOf: new)
//                strongSelf.audienceList.accept(list)
//            } else {
//                var list = strongSelf.list.value
//                list.append(contentsOf: new)
//                strongSelf.list.accept(list)
//            }
//
//            if let success = success {
//                success()
//            }
//        }
//        let response = ACResponse.json(successCallback)
//
//        let retry: ACErrorRetryCompletion = { (error: Error) -> RetryOptions in
//            if let fail = fail {
//                fail()
//            }
//            return .resign
//        }
//
//        client.request(task: task, success: response, failRetry: retry)
    }
    
    func refetch(onlyAudience: Bool = true, success: Completion = nil, fail: Completion = nil) {
        let client = Center.shared().centerProvideRequestHelper()
        var parameters: StringAnyDic = ["type": onlyAudience ? 2 : 1]
        
//        if list.value.count != 0 {
//            parameters["count"] = list.value.count
//        }
//
//        let url = URLGroup.userList(roomId: room.roomId)
//        let event = RequestEvent(name: "live-audience-list")
//        let task = RequestTask(event: event,
//                               type: .http(.get, url: url),
//                               timeout: .low,
//                               header: ["token": Keys.UserToken],
//                               parameters: parameters)
//
//        let successCallback: DicEXCompletion = { [weak self] (json: ([String: Any])) in
//            guard let strongSelf = self else {
//                return
//            }
//
//            let data = try json.getDataObject()
//            let listJson = try data.getListValue(of: "list")
//            let list = try Array(dicList: listJson)
//
//            if onlyAudience {
//                strongSelf.audienceList.accept(list)
//            } else {
//                strongSelf.list.accept(list)
//            }
//
//            if let success = success {
//                success()
//            }
//        }
//        let response = ACResponse.json(successCallback)
//
//        let retry: ACErrorRetryCompletion = { (error: Error) -> RetryOptions in
//            if let fail = fail {
//                fail()
//            }
//            return .resign
//        }
//
//        client.request(task: task, success: response, failRetry: retry)
    }
}

private extension LiveUserListVM {
    func observe() {
        message.subscribe(onNext: { (json) in
            
        }).disposed(by: bag)
    }
    
//    func fake(count: Int) -> [LiveRoleItem] {
//        var list = [LiveRoleItem]()
//        for i in 0..<count {
//            let dic: StringAnyDic = ["userId": "1000\(i)",
//                                    "userName": "fakeUserName-\(i)",
//                                    "avatar": "fakeHead",
//                                    "uid": i + 100]
//            let user = try! LiveRoleItem(dic: dic)
//            list.append(user)
//        }
//        return list
//    }
}
