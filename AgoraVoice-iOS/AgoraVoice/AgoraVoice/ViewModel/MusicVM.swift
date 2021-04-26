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
import Armin
import AgoraRte

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
    
    init(name: String,
         singer: String,
         isPlaying: Bool = false,
         url: String) {
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
    private(set) var lastMusic: Music? = nil
    
    let playerStatus = BehaviorRelay(value: AgoraRteMediaPlayerState.stopped)
    let list = BehaviorRelay(value: [Music]())
    let volume = BehaviorRelay<UInt>(value: 100)
    
    let playAction = PublishRelay<Music>()
    let pauseAction = PublishRelay<Music>()
    let resumeAction = PublishRelay<Music>()
    let stopAction = PublishRelay<Music>()
    
    func refetch() {
        let client = Center.shared().centerProvideRequestHelper()
        let event = ArRequestEvent(name: "music-list")
        let url = URLGroup.musicList
        let task = ArRequestTask(event: event,
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
        
        let fail: ArErrorRetryCompletion = { (error) in
            return .resign
        }
        
        let response = ArResponse.json(success)
        client.request(task: task, success: response, failRetry: fail)
    }
    
    func play(music: Music) {
        playAction.accept(music)
        
        if let item = lastMusic {
            updateMusicStatusOfList(music: item,
                                    isPlaying: false)
        }
        
        updateMusicStatusOfList(music: music,
                                isPlaying: true)
        
        lastMusic = music
    }
    
    func pause(music: Music) {
        pauseAction.accept(music)
        
        updateMusicStatusOfList(music: music,
                                isPlaying: false)
    }
    
    func resume(music: Music) {
        resumeAction.accept(music)
        
        updateMusicStatusOfList(music: music,
                                isPlaying: true)
    }
    
    func stop() {
        if let music = lastMusic {
            stopAction.accept(music)
            updateMusicStatusOfList(music: music,
                                    isPlaying: false)
        }
        
        lastMusic = nil
    }
}

private extension MusicVM {
    func updateMusicStatusOfList(music: Music,
                                 isPlaying: Bool) {
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

extension AgoraRteMediaPlayerState {
    var description: String {
        switch self {
        case .pause:      return "pause"
        case .playing:    return "playing"
        case .stopped:    return "stop"
        case .finish:     return "finish"
        @unknown default: fatalError()
        }
    }
}
