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

struct ElectronicMusic {
    var isAvailable: Bool = false
    var type: Int = 1
    var value: Int = 1
}

class AudioEffectVM: RxObject {
    private lazy var operateObj: AudioEffect = {
        return Center.shared().centerProvideMediaDevice().recordAudioEffect
    }()
    
    private var lastAduioEffectType = AudioEffectType.belCanto
    
    let selectedChatOfBelcanto = BehaviorRelay<ChatOfBelCanto>(value: .disable)
    let selectedSingOfBelcanto = BehaviorRelay<SingOfBelCanto>(value: .disable)
    let selectedTimbre = BehaviorRelay<Timbre>(value: .disable)
    
    let selectedAudioSpace = BehaviorRelay<AudioSpace>(value: .disable)
    let selectedTimbreRole = BehaviorRelay<TimbreRole>(value: .disable)
    let selectedMusicGenre = BehaviorRelay<MusicGenre>(value: .disable)
    
    let selectedElectronicMusic = BehaviorRelay<ElectronicMusic>(value: ElectronicMusic())
    
    let threeDimensionalVoice = BehaviorRelay<Int>(value: 0)
    
    override init() {
        super.init()
        observe()
    }
}

private extension AudioEffectVM {
    func observe() {
        // belCantoType
        selectedChatOfBelcanto.subscribe(onNext: { [unowned self] (item) in
            if item != .disable {
                self.disableElectronicMusic()
                self.disableSoundEffect()
                self.selectedSingOfBelcanto.accept(.disable)
                self.selectedTimbre.accept(.disable)
            }
            
            self.operateObj.setBelCantoWithChat(item)
        }).disposed(by: bag)
        
        selectedSingOfBelcanto.subscribe(onNext: { [unowned self] (item) in
            if item != .disable {
                self.disableElectronicMusic()
                self.disableSoundEffect()
                self.selectedChatOfBelcanto.accept(.disable)
                self.selectedTimbre.accept(.disable)
            }
            
            self.operateObj.setBelCantoWithSing(item)
        }).disposed(by: bag)
        
        selectedTimbre.subscribe(onNext: { [unowned self] (item) in
            if item != .disable {
                self.disableElectronicMusic()
                self.disableSoundEffect()
                self.selectedChatOfBelcanto.accept(.disable)
                self.selectedSingOfBelcanto.accept(.disable)
            }
            
            self.operateObj.setBelCantoWith(item)
        }).disposed(by: bag)
        
        // soundEffectType
        selectedAudioSpace.subscribe(onNext: { [unowned self] (item) in
            if item != .disable {
                self.disableElectronicMusic()
                self.disableBelCanto()
                self.selectedTimbreRole.accept(.disable)
                self.selectedMusicGenre.accept(.disable)
            }
            
            self.operateObj.setSoundWith(item)
        }).disposed(by: bag)
        
        selectedTimbreRole.subscribe(onNext: { [unowned self] (item) in
            if item != .disable {
                self.disableElectronicMusic()
                self.disableBelCanto()
                self.selectedAudioSpace.accept(.disable)
                self.selectedMusicGenre.accept(.disable)
            }
            
            self.operateObj.setSoundWith(item)
        }).disposed(by: bag)
        
        selectedMusicGenre.subscribe(onNext: { [unowned self] (item) in
            if item != .disable {
                self.disableElectronicMusic()
                self.disableBelCanto()
                self.selectedAudioSpace.accept(.disable)
                self.selectedTimbreRole.accept(.disable)
            }
            
            self.operateObj.setSoundWith(item)
        }).disposed(by: bag)
        
        // threeDimensionalVoice
        threeDimensionalVoice.subscribe(onNext: { [unowned self] (value) in
            guard self.selectedAudioSpace.value == .threeDimensionalVoice else {
                return
            }
            self.operateObj.setThreedimVoiceOfSound(value)
        }).disposed(by: bag)
        
        // Electronic Music
        selectedElectronicMusic.subscribe(onNext: { [unowned self] (music) in
            if music.isAvailable {
                self.disableBelCanto()
                self.disableSoundEffect()
                self.operateObj.setElectronicMusicWithType(music.type, value: music.value)
            } else {
                self.operateObj.cancelElectronicMusic()
            }
        }).disposed(by: bag)
    }
}

private extension AudioEffectVM {
    func disableSoundEffect() {
        selectedAudioSpace.accept(.disable)
        selectedTimbreRole.accept(.disable)
        selectedMusicGenre.accept(.disable)
    }
    
    func disableBelCanto() {
        selectedChatOfBelcanto.accept(.disable)
        selectedSingOfBelcanto.accept(.disable)
        selectedTimbre.accept(.disable)
    }
    
    func disableElectronicMusic() {
        self.selectedElectronicMusic.accept(ElectronicMusic(isAvailable: false, type: 1, value: 1))
    }
}
