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
    let selectedIndex = BehaviorRelay<Int>(value: 0)
    let selectedImage = BehaviorRelay<UIImage>(value: Center.shared().centerProvideImagesHelper().roomBackgrounds.first!)
    let fail = PublishRelay<String>()
    
    override init() {
        super.init()
        observe()
    }
    
    func commit(index: Int) {
        let lastIndex = selectedIndex.value
        selectedIndex.accept(index)
        
        let client = Center.shared().centerProvideRequestHelper()
    
        let parameters: StringAnyDic = ["": 0]

        let url = ""
        let event = RequestEvent(name: "update-room-background")
        let task = RequestTask(event: event,
                               type: .http(.post, url: url),
                               timeout: .low,
                               header: ["token": Keys.UserToken],
                               parameters: parameters)
        
        client.request(task: task, success: ACResponse.json({ (_) in
            
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
        message.subscribe(onNext: { (json) in
            
        }).disposed(by: bag)
        
        selectedIndex.map { (index) -> UIImage in
            return Center.shared().centerProvideImagesHelper().roomBackgrounds[index]
        }.bind(to: selectedImage).disposed(by: bag)
    }
}
