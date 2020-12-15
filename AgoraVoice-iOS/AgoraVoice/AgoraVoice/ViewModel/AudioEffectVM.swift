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
    private var lastAduioEffectType = AudioEffectType.belCanto
    
    // Input Rx
    let selectedChatOfBelcanto = BehaviorRelay<ChatOfBelCanto>(value: .disable)
    let selectedSingOfBelcanto = BehaviorRelay<SingOfBelCanto>(value: .disable)
    let selectedTimbre = BehaviorRelay<Timbre>(value: .disable)
    
    let selectedAudioSpace = BehaviorRelay<AudioSpace>(value: .disable)
    let selectedTimbreRole = BehaviorRelay<TimbreRole>(value: .disable)
    let selectedMusicGenre = BehaviorRelay<MusicGenre>(value: .disable)
    
    let selectedElectronicMusic = BehaviorRelay<ElectronicMusic>(value: ElectronicMusic())
    let selectedThreeDimensionalVoice = BehaviorRelay<Int>(value: 0)
    
    // Output Rx
    let outputChatOfBelcanto = PublishRelay<ChatOfBelCanto>()
    let outputSingOfBelcanto = PublishRelay<SingOfBelCanto>()
    let outputTimbre = PublishRelay<Timbre>()
    
    let outputAudioSpace = PublishRelay<AudioSpace>()
    let outputTimbreRole = PublishRelay<TimbreRole>()
    let outputMusicGenre = PublishRelay<MusicGenre>()
    
    let outputElectronicMusic = PublishRelay<ElectronicMusic>()
    let outputThreeDimensionalVoice = PublishRelay<Int>()
    
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
            
            self.outputChatOfBelcanto.accept(item)
        }).disposed(by: bag)
        
        selectedSingOfBelcanto.subscribe(onNext: { [unowned self] (item) in
            if item != .disable {
                self.disableElectronicMusic()
                self.disableSoundEffect()
                self.selectedChatOfBelcanto.accept(.disable)
                self.selectedTimbre.accept(.disable)
            }
            
            self.outputSingOfBelcanto.accept(item)
        }).disposed(by: bag)
        
        selectedTimbre.subscribe(onNext: { [unowned self] (item) in
            if item != .disable {
                self.disableElectronicMusic()
                self.disableSoundEffect()
                self.selectedChatOfBelcanto.accept(.disable)
                self.selectedSingOfBelcanto.accept(.disable)
            }
            
            self.outputTimbre.accept(item)
        }).disposed(by: bag)
        
        // soundEffectType
        selectedAudioSpace.subscribe(onNext: { [unowned self] (item) in
            if item != .disable {
                self.disableElectronicMusic()
                self.disableBelCanto()
                self.selectedTimbreRole.accept(.disable)
                self.selectedMusicGenre.accept(.disable)
            }
            
            self.outputAudioSpace.accept(item)
        }).disposed(by: bag)
        
        selectedTimbreRole.subscribe(onNext: { [unowned self] (item) in
            if item != .disable {
                self.disableElectronicMusic()
                self.disableBelCanto()
                self.selectedAudioSpace.accept(.disable)
                self.selectedMusicGenre.accept(.disable)
            }
            
            self.outputTimbreRole.accept(item)
        }).disposed(by: bag)
        
        selectedMusicGenre.subscribe(onNext: { [unowned self] (item) in
            if item != .disable {
                self.disableElectronicMusic()
                self.disableBelCanto()
                self.selectedAudioSpace.accept(.disable)
                self.selectedTimbreRole.accept(.disable)
            }
            
            self.outputMusicGenre.accept(item)
        }).disposed(by: bag)
        
        // selectedThreeDimensionalVoice
        selectedThreeDimensionalVoice.subscribe(onNext: { [unowned self] (value) in
            guard self.selectedAudioSpace.value == .threeDimensionalVoice else {
                return
            }
            
            self.outputThreeDimensionalVoice.accept(value)
        }).disposed(by: bag)
        
        // Electronic Music
        selectedElectronicMusic.subscribe(onNext: { [unowned self] (music) in
            if music.isAvailable {
                self.disableBelCanto()
                self.disableSoundEffect()
            }
            
            self.outputElectronicMusic.accept(music)
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
