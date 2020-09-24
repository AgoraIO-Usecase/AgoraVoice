//
//  RoomBackgroundVM.swift
//  AgoraVoice
//
//  Created by CavanSu on 2020/9/16.
//  Copyright © 2020 Agora. All rights reserved.
//

import UIKit
import RxSwift
import RxRelay
import AlamoClient

class RoomBackgroundVM: CustomObserver {
    var room: Room
    let selectedIndex = BehaviorRelay<Int>(value: 0)
    let selectedImage = BehaviorRelay<UIImage>(value: Center.shared().centerProvideImagesHelper().roomBackgrounds.first!)
    let fail = PublishRelay<String>()
    
    init(room: Room) {
        self.room = room
        super.init()
        observe()
    }
    
    func commit(index: Int) {
        let lastIndex = selectedIndex.value
        guard lastIndex != index else {
            return
        }
        
        selectedIndex.accept(index)
        
        let client = Center.shared().centerProvideRequestHelper()
    
        let parameters: StringAnyDic = ["backgroundImage": "\(index)"]

        let url = URLGroup.roomBackground(roomId: room.roomId)
        let event = RequestEvent(name: "update-room-background")
        let task = RequestTask(event: event,
                               type: .http(.put, url: url),
                               timeout: .low,
                               header: ["token": Keys.UserToken],
                               parameters: parameters)
        
        client.request(task: task, success: ACResponse.json({ [weak self] (_) in
            guard let strongSelf = self else {
                return
            }
            strongSelf.selectedIndex.accept(index)
        })) { [weak self] (_) -> RetryOptions in
            guard let strongSelf = self else {
                return .resign
            }
            strongSelf.selectedIndex.accept(lastIndex)
            strongSelf.fail.accept("update room background fail")
            return .resign
        }
    }
}

private extension RoomBackgroundVM {
    func observe() {
        message.subscribe(onNext: { [unowned self] (json) in
            do {
                let basic = try json.getDictionaryValue(of: "basic")
                let index = try basic.getStringValue(of: "backgroundImage")
                self.selectedIndex.accept(Int(index)!)
            } catch {
                self.log(error: error)
            }
        }).disposed(by: bag)
        
        selectedIndex.map { (index) -> UIImage in
            return Center.shared().centerProvideImagesHelper().roomBackgrounds[index]
        }.bind(to: selectedImage).disposed(by: bag)
    }
}
