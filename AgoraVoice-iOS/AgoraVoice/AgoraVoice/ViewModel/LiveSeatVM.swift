//
//  LiveSeatVM.swift
//  AgoraLive
//
//  Created by CavanSu on 2020/3/26.
//  Copyright © 2020 Agora. All rights reserved.
//

import UIKit
import RxSwift
import RxRelay
import AlamoClient

// state: 0空位 1正常 2封麦
enum SeatState {
    case empty, normal(LiveRole), close
    
    var rawValue: Int {
        switch self {
        case .empty:  return 0
        case .normal: return 1
        case .close:  return 2
        }
    }
    
    static func !=(right: SeatState, left: SeatState) -> Bool {
        return right.rawValue != left.rawValue
    }
}

struct LiveSeat {
    var index: Int // 1 ... 6
    var state: SeatState
    
    init(index: Int, state: SeatState) {
        self.index = index
        self.state = state
    }
    
    init(dic: StringAnyDic) throws {
        let seatJson = try dic.getDictionaryValue(of: "seat")
        self.index = try seatJson.getIntValue(of: "no")
        
        let state = try seatJson.getIntValue(of: "state")
        
        switch state {
        case 0:
            self.state = .empty
        case 1:
            let broadcaster = try dic.getDictionaryValue(of: "user")
            let user = try LiveRoleItem(dic: broadcaster)
            self.state = .normal(user)
        case 2:
            self.state = .close
        default:
            assert(false)
            throw AGEError.fail("LiveSeat init fail", extra: "json: \(dic)")
        }
    }
}
/*
class LiveSeatVM: CustomObserver {
    private var room: Room
    private(set) var list: BehaviorRelay<[LiveSeat]>
    
    init(room: Room, list: [StringAnyDic]) throws {
        self.room = room
        
        var tempList = [LiveSeat]()
        
        for item in list {
            let seat = try LiveSeat(dic: item)
            tempList.append(seat)
        }
        
        self.list = BehaviorRelay(value: tempList.sorted(by: {$0.index < $1.index}))
        
        super.init()
        observe()
    }
    
    deinit {
        #if !RELEASE
        print("deinit LiveSeatVM")
        #endif
    }
    
    func update(state: SeatState, index: Int, fail: ErrorCompletion) {
        let client = Center.shared().centerProvideRequestHelper()
        let task = RequestTask(event: RequestEvent(name: "multi-seat-state \(state)"),
                               type: .http(.post, url: URLGroup.liveSeatCommand(roomId: room.roomId)),
                               timeout: .medium,
                               header: ["token": ALKeys.ALUserToken],
                               parameters: ["no": index, "state": state.rawValue])
        client.request(task: task) { (error) -> RetryOptions in
            if let fail = fail {
                fail(error)
            }
            return .resign
        }
    }
}

private extension LiveSeatVM {
    func observe() {
        let rtm = Center.shared().centerProvideRTMHelper()
        
        rtm.addReceivedChannelMessage(observer: self.address) { [weak self] (json) in
            guard let cmd = try? json.getEnum(of: "cmd", type: ALChannelMessage.AType.self),
                cmd == .seatList,
                let strongSelf = self else {
                return
            }
            
            let list = try json.getListValue(of: "data")
            var tempList = [LiveSeat]()
            for item in list {
                let seat = try LiveSeat(dic: item)
                tempList.append(seat)
            }
            strongSelf.list.accept(tempList.sorted(by: {$0.index < $1.index}))
        }
    }
}
*/
