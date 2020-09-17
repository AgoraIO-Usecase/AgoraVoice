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
    
    init(name: String, singer: String, isPlaying: Bool = false, url: String) {
        self.name = name
        self.singer = singer
        self.isPlaying = isPlaying
        self.url = url
    }
    
    init(dic: StringAnyDic) throws {
        self.singer = try dic.getStringValue(of: "singer")
        self.name = try dic.getStringValue(of: "musicName")
        self.url = try dic.getStringValue(of: "url")
        self.isPlaying = false
    }
    
    static func==(left: Music, right: Music) -> Bool {
        return left.url == right.url
    }
}

class MusicVM: RxObject {
    private var operatorObj: Player
    private(set) var lastMusic: Music? = nil
    
    let playerStatus = BehaviorRelay(value: PlayerStatus.stop)
    let list = BehaviorRelay(value: [Music]())
    
    override init() {
        operatorObj = Center.shared().centerProvideMediaDevice().player
        super.init()
        operatorObj.delegate = self
    }
    
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
    
    func play(music: Music) {
        guard operatorObj.start(withURL: music.url) else {
            assert(false)
            return
        }
        
        if let item = lastMusic {
            updateMusicStatusOfList(music: item, isPlaying: false)
        }
        
        updateMusicStatusOfList(music: music, isPlaying: true)
        
        lastMusic = music
    }
    
    func pause(music: Music) {
        guard operatorObj.pause() else {
            assert(false)
            return
        }
        
        updateMusicStatusOfList(music: music, isPlaying: false)
    }
    
    func resume(music: Music) {
        guard operatorObj.resume() else {
            assert(false)
            return
        }
        
        updateMusicStatusOfList(music: music, isPlaying: true)
    }
    
    func stop() {
        guard operatorObj.stop() else {
            assert(false)
            return
        }
        
        if let music = lastMusic {
            updateMusicStatusOfList(music: music, isPlaying: false)
        }
        
        lastMusic = nil
    }
}

private extension MusicVM {
    func updateMusicStatusOfList(music: Music, isPlaying: Bool) {
        var musicList = list.value
        let index = musicList.firstIndex { (item) -> Bool in
            return item == music
        }
        
        guard let tIndex = index else {
            assert(false)
            return
        }
        
        var tMusic = music
        tMusic.isPlaying = isPlaying
        musicList[tIndex] = tMusic
        list.accept(musicList)
    }
    
    func nextSong(previousURL: String) {
        var musicList = list.value
        var music: Music?
        var musicIndex: Int?
        
        for (index, item) in musicList.enumerated() where item.url == previousURL {
            music = item
            musicIndex = index
            break
        }
        
        guard var item = music,
            let index = musicIndex else  {
            return
        }
        
        item.isPlaying = false
        
        musicList[index] = item
        list.accept(musicList)
        
        lastMusic = nil
        
        // next song
        if (index + 1) < musicList.count {
            let next = musicList[index + 1]
            play(music: next)
        }
    }
}

extension MusicVM: PlayerDelegate {
    func player(_ player: Player, didPlayFileFinish url: String) {
        nextSong(previousURL: url)
    }
    
    func player(_ player: Player, didStartPlayFile url: String, duration seconds: Int) {
        
    }
    
    func player(_ player: Player, didPausePlayFile url: String) {
        
    }
    
    func player(_ player: Player, didResumePlayFile url: String) {
        
    }
    
    func player(_ player: Player, didStopPlayFile url: String) {
        nextSong(previousURL: url)
    }
    
    func player(_ player: Player, didChangePlayerStatusFrom previous: PlayerStatus, to current: PlayerStatus) {
        playerStatus.accept(current)
    }
}

extension PlayerStatus {
    var description: String {
        switch self {
        case .pause:      return "pause"
        case .playing:    return "playing"
        case .stop:       return "stop"
        @unknown default: fatalError()
        }
    }
}
