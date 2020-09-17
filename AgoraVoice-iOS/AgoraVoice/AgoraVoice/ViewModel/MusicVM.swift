//
//  MusicVM.swift
//  AgoraLive
//
//  Created by CavanSu on 2020/3/31.
//  Copyright © 2020 Agora. All rights reserved.
//

import UIKit
import RxSwift
import RxRelay
import AlamoClient

fileprivate extension Array where Element == Music {
    init(list: [StringAnyDic]) throws {
        var array = [Music]()
        
        for item in list {
            let music = try Music(dic: item)
            array.append(music)
        }
        
        self = array
    }
}

struct Music {
    var name: String
    var singer: String
    var isPlaying: Bool
    var url: String
    
    init(dic: StringAnyDic) throws {
        self.singer = try dic.getStringValue(of: "singer")
        self.name = try dic.getStringValue(of: "musicName")
        self.url = try dic.getStringValue(of: "url")
        self.isPlaying = false
    }
}

class MusicVM: NSObject {
    private let bag = DisposeBag()
    
    var listSelectedIndex: Int? {
        didSet {
            guard let index = listSelectedIndex else {
                isPlaying.accept(false)
                return
            }
            
            isPlaying.accept(true)
            playItem(oldValue, selected: index)
        }
    }
    
    let isPlaying = BehaviorRelay(value: false)
    
    let list = BehaviorRelay(value: [Music]())
    
    func refetch() {
        let client = Center.shared().centerProvideRequestHelper()
        let event = RequestEvent(name: "music-list")
        let url = URLGroup.musicList
        let task = RequestTask(event: event,
                               type: .http(.get, url: url),
                               timeout: .medium)
        
        let success: DicEXCompletion = { [weak self] (json) in
            guard let strongSelf = self else {
                return
            }
            
            let data = try json.getListValue(of: "data")
            let list = try Array(list: data)
            strongSelf.list.accept(list)
        }
        
        let fail: ACErrorRetryCompletion = { (error) in
            return .resign
        }
        
        let response = ACResponse.json(success)
        client.request(task: task, success: response, failRetry: fail)
    }
}

private extension MusicVM {
    func playItem(_ last: Int?, selected: Int) {
        var musicList = self.list.value
       
        let device = Center.shared().centerProvideMediaDevice()
        
        defer {
            // send notification to view
            list.accept(musicList)
        }
        
        var item = musicList[selected]
        item.isPlaying.toggle()
        musicList[selected] = item
        
        // pause / resume
        if let last = last, selected == last {
            if item.isPlaying {
                _ = device.player.resume()
            } else {
                _ = device.player.pause()
            }
            listSelectedIndex = nil
            return
        
        // cancel last playing state
        } else if let last = last {
            var lastItem = musicList[last]
            lastItem.isPlaying.toggle()
            musicList[last] = lastItem
        }
        
        // play
        let player = Center.shared().centerProvideMediaDevice().player
        
//        mediaKit.player.startMixingFileAudio(url: item.url) { [weak self] in
//            guard let strongSelf = self,
//                let selectedIndex = strongSelf.listSelectedIndex else {
//                return
//            }
//
//            guard var musicList = strongSelf.list?.value else {
//                assert(false)
//                return
//            }
//
//            let next = selectedIndex + 1
//            if next < musicList.count {
//                strongSelf.listSelectedIndex = next
//            } else {
//                strongSelf.listSelectedIndex = nil
//
//                var item = musicList[selected]
//                item.isPlaying.toggle()
//                musicList[selected] = item
//                strongSelf.list?.accept(musicList)
//            }
//        }
    }
}
