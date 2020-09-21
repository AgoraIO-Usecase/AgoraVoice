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
    var list = BehaviorRelay(value: [LiveRole]())
    var giftList = BehaviorRelay(value: [LiveRoleItem]())
    var audienceList = BehaviorRelay(value: [LiveRole]())

    var joined = PublishRelay<[LiveRole]>()
    var left = PublishRelay<[LiveRole]>()
    var total = BehaviorRelay(value: 0)
    
    override init() {
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
}

private extension LiveUserListVM {
    func observe() {
        list.map { (list) -> Int in
            return list.count
        }.bind(to: total).disposed(by: bag)
        
        message.subscribe(onNext: { (json) in
            
        }).disposed(by: bag)
    }
}
