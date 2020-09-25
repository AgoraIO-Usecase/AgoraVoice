//
//  LiveSeatsVM.swift
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
    case empty, normal(LiveStream), close
    
    var rawValue: Int {
        switch self {
        case .empty:  return 0
        case .normal: return 1
        case .close:  return 2
        }
    }
    
    var stream: LiveStream? {
        switch self {
        case .empty:              return nil
        case .normal(let stream): return stream
        case .close:              return nil
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
}

class LiveSeatsVM: CustomObserver {
    private let seatCount = 8
    private var room: Room
    let fail = PublishRelay<String>()
    let streamList = BehaviorRelay(value: [LiveStream]())
    let seatList = BehaviorRelay(value: [LiveSeat]())
    
    init(room: Room) {
        self.room = room
        super.init()
        observe()
    }
    
    deinit {
        #if !RELEASE
        print("deinit LiveSeatsVM")
        #endif
    }
    
    func update(state: SeatState, index: Int) {
        let client = Center.shared().centerProvideRequestHelper()
        let task = RequestTask(event: RequestEvent(name: "multi-seat-state \(state)"),
                               type: .http(.post, url: URLGroup.liveSeatStatus(roomId: room.roomId)),
                               timeout: .medium,
                               header: ["token": Keys.UserToken],
                               parameters: ["no": index, "state": state.rawValue])
        client.request(task: task) { [weak self] (error) -> RetryOptions in
            guard let strongSelf = self else {
                return .resign
            }
            
            switch state {
            case .empty: strongSelf.fail.accept("un-lock seat fail")
            case .close: strongSelf.fail.accept("lock seat fail")
            default:
                assert(false)
                break
            }
            return .resign
        }
    }
}

private extension LiveSeatsVM {
    func observe() {        
        streamList.subscribe(onNext: { [unowned self] (streams) in
            self.streamMatchSeat()
        }).disposed(by: bag)
        
        message.subscribe(onNext: { [unowned self] (json) in
            print("LiveSeatsVM json: \(json.description)")
            guard let seatsJson = try? json.getListValue(of: "seats") else {
                return
            }
            
            do {
                guard seatsJson.count == self.seatCount else {
                    throw AGEError.fail("seat count invalid", extra:"count: \(seatsJson.count)")
                }
                
                var list = [LiveSeat]()
                
                for item in seatsJson {
                    let index = try item.getIntValue(of: "no")
                    let intState = try item.getIntValue(of: "state")
                    var state: SeatState
                    
                    switch intState {
                    case 0:
                        state = .empty
                    case 1:
                        let userId = try item.getStringValue(of: "userId")
                        let userName = try item.getStringValue(of: "userName")
                        let info = BasicUserInfo(userId: userId, name: userName)
                        let user = LiveRoleItem(type: .broadcaster, info: info, agUId: "0")
                        let stream = self.seatMatchStreamWith(role: user)
                        state = .normal(stream)
                    case 2:
                        state = .close
                    default:
                        throw AGEError.fail("seat state invalid")
                    }
                    
                    let seat = LiveSeat(index: index, state: state)
                    list.append(seat)
                }
                
                self.seatList.accept(list)
            } catch {
                self.log(error: error)
            }
        }).disposed(by: bag)
    }
    
    func seatMatchStreamWith(role: LiveRole) -> LiveStream {
        var stream: LiveStream?
        for item in streamList.value where item.owner.info.userId == role.info.userId {
            stream = item
        }
        
        if let tStream = stream {
            return tStream
        } else {
            return LiveStream(streamId: role.agUId, hasAudio: true, owner: role)
        }
    }
    
    func streamMatchSeat() {
        var newSeats = seatList.value
        let preSeats = seatList.value
        
        for stream in streamList.value {
            for seat in preSeats  {
                guard let streamId = seat.state.stream?.streamId,
                    streamId == stream.streamId else {
                    continue
                }
                
                var new = seat
                new.state = .normal(stream)
                newSeats[seat.index - 1] = new
                break
            }
        }
        
        seatList.accept(newSeats)
    }
}
