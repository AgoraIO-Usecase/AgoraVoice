//
//  AudioEffect.swift
//  AgoraVoice
//
//  Created by CavanSu on 2020/9/7.
//  Copyright © 2020 Agora. All rights reserved.
//

import UIKit
import RxSwift
import RxRelay

class AudioEffectVM: RxObject {
    private lazy var operateObj: AudioEffect = {
        return Center.shared().centerProvideMediaDevice().recordAudioEffect
    }()
    
    let audioEffectType = BehaviorRelay<AudioEffectType>(value: .belCanto)
    
    let selectedChatOfBelcanto = BehaviorRelay<ChatOfBelCanto>(value: .disable)
    let selectedSingOfBelcanto = BehaviorRelay<SingOfBelCanto>(value: .disable)
    let selectedTimbre = BehaviorRelay<Timbre>(value: .disable)
    
    let selectedAudioSpace = BehaviorRelay<AudioSpace>(value: .disable)
    let selectedTimbreRole = BehaviorRelay<TimbreRole>(value: .disable)
    let selectedMusicGenre = BehaviorRelay<MusicGenre>(value: .disable)
}

private extension AudioEffectVM {
    func observe() {
        audioEffectType.subscribe(onNext: { [unowned self] (type) in
            switch type {
            case .belCanto:
                self.selectedAudioSpace.accept(.disable)
                self.selectedTimbreRole.accept(.disable)
                self.selectedMusicGenre.accept(.disable)
            case .soundEffect:
                self.selectedChatOfBelcanto.accept(.disable)
                self.selectedSingOfBelcanto.accept(.disable)
                self.selectedTimbre.accept(.disable)
            }
        }).disposed(by: bag)
        
        // belCantoType
        selectedChatOfBelcanto.subscribe(onNext: { [unowned self] (item) in
            if item != .disable {
                self.selectedSingOfBelcanto.accept(.disable)
                self.selectedTimbre.accept(.disable)
            }
            
            self.operateObj.setBelCantoWithChat(item)
        }).disposed(by: bag)
        
        selectedSingOfBelcanto.subscribe(onNext: { [unowned self] (item) in
            if item != .disable {
                self.selectedChatOfBelcanto.accept(.disable)
                self.selectedTimbre.accept(.disable)
            }
            
            self.operateObj.setBelCantoWithSing(item)
        }).disposed(by: bag)
        
        selectedTimbre.subscribe(onNext: { [unowned self] (item) in
            if item != .disable {
                self.selectedChatOfBelcanto.accept(.disable)
                self.selectedSingOfBelcanto.accept(.disable)
            }
            
            self.operateObj.setBelCantoWith(item)
        }).disposed(by: bag)
        
        // soundEffectType
        selectedAudioSpace.subscribe(onNext: { [unowned self] (item) in
            
        }).disposed(by: bag)
        
        selectedTimbreRole.subscribe(onNext: { [unowned self] (item) in
            
        }).disposed(by: bag)
        
        selectedMusicGenre.subscribe(onNext: { [unowned self] (item) in
            
        }).disposed(by: bag)
    }
}
