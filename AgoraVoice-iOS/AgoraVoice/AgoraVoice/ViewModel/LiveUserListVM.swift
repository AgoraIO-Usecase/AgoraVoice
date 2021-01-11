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
import Armin

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
    var giftList = BehaviorRelay(value: [LiveRole]())
    var audienceList = BehaviorRelay(value: [LiveRole]())

    var joined = PublishRelay<[LiveRole]>()
    var left = PublishRelay<[LiveRole]>()
    var total = BehaviorRelay(value: 0)
    
    override init() {
        super.init()
        observe()
    }
}

private extension LiveUserListVM {
    func observe() {
        list.map { (list) -> Int in
            return list.count
        }.bind(to: total).disposed(by: bag)
        
        message.subscribe(onNext: { [unowned self] (json) in
            guard let giftJson = try? json.getDictionaryValue(of: "gift"),
                let ranks = try? giftJson.getListValue(of: "ranks") else {
                return
            }
            
            do {
                var temp = [LiveRoleItem]()
                
                for item in ranks {
                    let userId = try item.getStringValue(of: "userId")
                    let userName = try item.getStringValue(of: "userName")
                    let rank = try item.getIntValue(of: "rank")
                    let info = BasicUserInfo(userId: userId,
                                             name: userName)
                    let role = LiveRoleItem(type: .audience,
                                            info: info,
                                            agUId: "0",
                                            giftRank: rank)
                    temp.append(role)
                }
                self.giftList.accept(temp.sorted(by: {$0.giftRank < $1.giftRank}))
            } catch {
                self.log(error: error)
            }
        }).disposed(by: bag)
    }
}
