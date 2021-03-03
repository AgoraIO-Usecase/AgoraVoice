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

enum AudioEffectType {
    case belCanto, soundEffect
    
    static var list = BehaviorRelay<[AudioEffectType]>(value: [.belCanto,
                                                            .soundEffect])
    
    var description: String {
        switch self {
        case .belCanto:    return DeviceAssistant.Language.isChinese ? "美声" : "Voice beautifier"
        case .soundEffect: return DeviceAssistant.Language.isChinese ? "音效" : "Audio effects"
        }
    }
}

enum BelCantoType {
    case chat, sing, timbre
    
    static var list = BehaviorRelay<[BelCantoType]>(value: [.chat,
                                                            .sing,
                                                            .timbre])
    
    var description: String {
        switch self {
        case .chat:   return DeviceAssistant.Language.isChinese ? "语聊美声" : "Chat beautifier"
        case .sing:   return DeviceAssistant.Language.isChinese ? "歌唱美声" : "Singing beautifier"
        case .timbre: return DeviceAssistant.Language.isChinese ? "音色变换" : "Timbre transformation"
        }
    }
}

enum SoundEffectType {
    case space, voiceChangerEffect, styleTransformation, pitchCorrection, magicTone
    
    static var list = BehaviorRelay<[SoundEffectType]>(value: [.space,
                                                               .voiceChangerEffect,
                                                               .styleTransformation,
                                                               .pitchCorrection,
                                                               .magicTone])
    
    var description: String {
        switch self {
        case .space:               return DeviceAssistant.Language.isChinese ? "空间塑造" : "Room acoustics"
        case .voiceChangerEffect:  return DeviceAssistant.Language.isChinese ? "变声音效" : "Voice changer effect"
        case .styleTransformation: return DeviceAssistant.Language.isChinese ? "曲风音效" : "Style transformation"
        case .pitchCorrection:     return DeviceAssistant.Language.isChinese ? "电音音效" : "Pitch correction"
        case .magicTone:           return DeviceAssistant.Language.isChinese ? "魔力音阶" : "Magic tone"
        }
    }
}

enum ChatOfBelCanto {
    case disable, maleMagnetic, femaleFresh, femaleVitality
}

enum SingOfBelCanto {
    case disable, male, female
}

enum Timbre {
    case disable, vigorous, deep, mellow, falsetto, full, clear, resounding, ringing
}

enum AudioSpace {
    case disable, ktv, vocalConcer, studio, phonograph, virtualStereo, spacial, ethereal, threeDimensionalVoice
}

enum TimbreRole {
    case disable, uncle, oldMan, babyBoy, babyGirl, sister, zhuBaJie, hulk
}

enum MusicGenre {
    case disable, rnb, popular, rock, hiphop
}

struct ElectronicMusic {
    var isAvailable: Bool = false
    var type: Int = 1
    var value: Int = 4
}

extension ChatOfBelCanto {
    static var list = BehaviorRelay<[ChatOfBelCanto]>(value: [.maleMagnetic,
                                                              .femaleFresh,
                                                              .femaleVitality])
    
    var image: UIImage {
        switch self {
        case .maleMagnetic:   return UIImage(named: "icon-大叔磁性")!
        case .femaleFresh:    return UIImage(named: "icon-清新女")!
        case .femaleVitality: return UIImage(named: "icon-活力女")!
        case .disable:        fatalError()
        }
    }
    
    var description: String {
        switch self {
        case .maleMagnetic:   return DeviceAssistant.Language.isChinese ? "磁性(男)" : "Magnetic(Male)"
        case .femaleFresh:    return DeviceAssistant.Language.isChinese ? "清新(女)" : "Fresh(Female)"
        case .femaleVitality: return DeviceAssistant.Language.isChinese ? "活力(女)" : "Vitality(Female)"
        case .disable:        fatalError()
        }
    }
    
    var parameters: String {
        var value: Int
        
        switch self {
        case .maleMagnetic:
            value = 1
        case .femaleFresh:
            value = 2
        case .femaleVitality:
            value = 3
        case .disable:
            return "{\"che.audio.morph.reverb_preset\":0}"
        }
        
        let parameters = "{\"che.audio.morph.beauty_voice\":\(value)}"
        return parameters
    }
}

extension SingOfBelCanto {
    static var list = BehaviorRelay<[SingOfBelCanto]>(value: [.male,
                                                             .female])
    
    var description: String {
        switch self {
        case .male:    return NSLocalizedString("Male")
        case .female:  return NSLocalizedString("Female")
        case .disable: fatalError()
        }
    }
    
    var parameters: String {
        var key: Int
        var value: Int
        
        switch self {
        case .male:
            key = 1
            value = 1
        case .female:
            key = 2
            value = 1
        case .disable:
            return "{\"che.audio.morph.reverb_preset\":0}"
        }
        
        let parameters = "{\"che.audio.morph.beauty_sing\":{\"key\":\(key),\"value\":\(value)}}"
        return parameters
    }
}

extension Timbre {
    static var list = BehaviorRelay<[Timbre]>(value: [.vigorous,
                                                      .deep,
                                                      .mellow,
                                                      .falsetto,
                                                      .full,
                                                      .clear,
                                                      .resounding,
                                                      .ringing])
    
    var description: String {
        switch self {
        case .vigorous:    return DeviceAssistant.Language.isChinese ? "浑厚" : "Vigorous"
        case .deep:        return DeviceAssistant.Language.isChinese ? "低沉" : "Deep"
        case .mellow:      return DeviceAssistant.Language.isChinese ? "圆润" : "Mellow"
        case .falsetto:    return DeviceAssistant.Language.isChinese ? "假音" : "Falsetto"
        case .full:        return DeviceAssistant.Language.isChinese ? "饱满" : "Full"
        case .clear:       return DeviceAssistant.Language.isChinese ? "清澈" : "Clear"
        case .resounding:  return DeviceAssistant.Language.isChinese ? "高亢" : "Resounding"
        case .ringing:     return DeviceAssistant.Language.isChinese ? "嘹亮" : "Ringing"
        case .disable:     fatalError()
        }
    }
    
    var parameters: String {
        var value: Int
        
        switch self {
        case .vigorous:
            value = 7
        case .deep:
            value = 8
        case .mellow:
            value = 9
        case .falsetto:
            value = 10
        case .full:
            value = 11
        case .clear:
            value = 12
        case .resounding:
            value = 13
        case .ringing:
            value = 14
        case .disable:
            return "{\"che.audio.morph.reverb_preset\":0}"
        }
        
        let parameters = "{\"che.audio.morph.voice_changer\":\(value)}"
        return parameters
    }
}

extension AudioSpace {
    static var list = BehaviorRelay<[AudioSpace]>(value: [.ktv,
                                                          .vocalConcer,
                                                          .studio,
                                                          .phonograph,
                                                          .virtualStereo,
                                                          .spacial,
                                                          .ethereal,
                                                          .threeDimensionalVoice])
    
    var image: UIImage {
        switch self {
        case .ktv:                    return UIImage(named: "icon-KTV")!
        case .vocalConcer:            return UIImage(named: "icon-演唱会")!
        case .studio:                 return UIImage(named: "icon-录音棚")!
        case .phonograph:             return UIImage(named: "icon-留声机")!
        case .virtualStereo:          return UIImage(named: "icon-虚拟立体声")!
        case .spacial:                return UIImage(named: "icon-空旷")!
        case .ethereal:               return UIImage(named: "icon-空灵")!
        case .threeDimensionalVoice:  return UIImage(named: "icon-3D人声")!
        case .disable:                fatalError()
        }
    }
    
    var description: String {
        switch self {
        case .ktv:                    return "KTV"
        case .vocalConcer:            return DeviceAssistant.Language.isChinese ? "演唱会" : "Vocal concert"
        case .studio:                 return DeviceAssistant.Language.isChinese ? "录音棚" : "Studio"
        case .phonograph:             return DeviceAssistant.Language.isChinese ? "留声机" : "Phonograph"
        case .virtualStereo:          return DeviceAssistant.Language.isChinese ? "虚拟立体声" : "Virtual stereo"
        case .spacial:                return DeviceAssistant.Language.isChinese ? "空旷" : "Spacial"
        case .ethereal:               return DeviceAssistant.Language.isChinese ? "空灵" : "Ethereal"
        case .threeDimensionalVoice:  return DeviceAssistant.Language.isChinese ? "3D人声" : "3D Voice"
        case .disable:                fatalError()
        }
    }
    
    var parameters: String {
        var value: Int
        var parameters: String
        
        switch self {
        case .ktv:
            value = 1
            parameters = "{\"che.audio.morph.reverb_preset\":\(value)}"
        case .vocalConcer:
            value = 2
            parameters = "{\"che.audio.morph.reverb_preset\":\(value)}"
        case .studio:
            value = 5
            parameters = "{\"che.audio.morph.reverb_preset\":\(value)}"
        case .phonograph:
            value = 8
            parameters = "{\"che.audio.morph.reverb_preset\":\(value)}"
        case .spacial:
            value = 15
            parameters = "{\"che.audio.morph.voice_changer\":\(value)}"
        case .ethereal:
            value = 5
            parameters = "{\"che.audio.morph.voice_changer\":\(value)}"
        case .virtualStereo:
            parameters = "{\"che.audio.morph.virtual_stereo\":1}"
        case .threeDimensionalVoice:
            parameters = "{\"che.audio.morph.threedim_voice\":\(10)}"
        case .disable:
            parameters = "{\"che.audio.morph.reverb_preset\":0}"
        }
        
        return parameters
    }
}

extension TimbreRole {
    static var list = BehaviorRelay<[TimbreRole]>(value: [.uncle,
                                                          .oldMan,
                                                          .babyBoy,
                                                          .sister,
                                                          .babyGirl,
                                                          .zhuBaJie,
                                                          .hulk])
    
    var image: UIImage {
        switch self {
        case .uncle:     return UIImage(named: "icon-大叔磁性")!
        case .oldMan:    return UIImage(named: "icon-老年人")!
        case .babyBoy:   return UIImage(named: "icon-小男孩")!
        case .sister:    return UIImage(named: "icon-小姐姐")!
        case .babyGirl:  return UIImage(named: "icon-小女孩")!
        case .zhuBaJie:  return UIImage(named: "icon-猪八戒")!
        case .hulk:      return UIImage(named: "icon-绿巨人")!
        case .disable:   fatalError()
        }
    }
    
    var description: String {
        switch self {
        case .uncle:     return DeviceAssistant.Language.isChinese ? "大叔" : "Uncle"
        case .oldMan:    return DeviceAssistant.Language.isChinese ? "老男人" : "Old man"
        case .babyBoy:   return DeviceAssistant.Language.isChinese ? "小男孩" : "Boy"
        case .sister:    return DeviceAssistant.Language.isChinese ? "小姐姐" : "Sister"
        case .babyGirl:  return DeviceAssistant.Language.isChinese ? "小女孩" : "Girl"
        case .zhuBaJie:  return DeviceAssistant.Language.isChinese ? "猪八戒" : "Pig king"
        case .hulk:      return DeviceAssistant.Language.isChinese ? "绿巨人" : "Hulk"
        case .disable:   fatalError()
        }
    }
    
    var parameters: String {
        var value: Int
        var parameters: String
        
        switch self {
        case .uncle:
            value = 3
            parameters = "{\"che.audio.morph.reverb_preset\":\(value)}"
        case .oldMan:
            value = 1
            parameters = "{\"che.audio.morph.voice_changer\":\(value)}"
        case .babyBoy:
            value = 2
            parameters = "{\"che.audio.morph.voice_changer\":\(value)}"
        case .sister:
            value = 4
            parameters = "{\"che.audio.morph.reverb_preset\":\(value)}"
        case .babyGirl:
            value = 3
            parameters = "{\"che.audio.morph.voice_changer\":\(value)}"
        case .zhuBaJie:
            value = 4
            parameters = "{\"che.audio.morph.voice_changer\":\(value)}"
        case .hulk:
            value = 6
            parameters = "{\"che.audio.morph.voice_changer\":\(value)}"
        case .disable:
            parameters = "{\"che.audio.morph.reverb_preset\":0}"
        }
        
        return parameters
    }
}

extension MusicGenre {
    static var list = BehaviorRelay<[MusicGenre]>(value: [.rnb,
                                                          .popular,
                                                          .rock,
                                                          .hiphop])
    
    var image: UIImage {
        switch self {
        case .rnb:     return UIImage(named: "icon-R&B")!
        case .popular: return UIImage(named: "icon-流行")!
        case .rock:    return UIImage(named: "icon-摇滚")!
        case .hiphop:  return UIImage(named: "icon-嘻哈")!
        case .disable: fatalError()
        }
    }
    
    var description: String {
        switch self {
        case .rnb:     return "R&B"
        case .popular: return DeviceAssistant.Language.isChinese ? "流行" : "Popular"
        case .rock:    return DeviceAssistant.Language.isChinese ? "摇滚" : "Rock"
        case .hiphop:  return DeviceAssistant.Language.isChinese ? "嘻哈" : "HipHop"
        case .disable: fatalError()
        }
    }
    
    var parameters: String {
        var value: Int
        var parameters: String
        
        switch self {
        case .rnb:
            value = 7
            parameters = "{\"che.audio.morph.reverb_preset\":\(value)}"
        case .popular:
            value = 6
            parameters = "{\"che.audio.morph.reverb_preset\":\(value)}"
        case .rock:
            value = 11
            parameters = "{\"che.audio.morph.reverb_preset\":\(value)}"
        case .hiphop:
            value = 12
            parameters = "{\"che.audio.morph.reverb_preset\":\(value)}"
        case .disable:
            parameters = "{\"che.audio.morph.reverb_preset\":0}"
        }
        
        return parameters
    }
}

extension ElectronicMusic {
    var parameters: String {
        let parameters = "{\"che.audio.morph.electronic_voice\":{\"key\":\(self.type),\"value\":\(self.value)}}"
        return parameters
    }
}
