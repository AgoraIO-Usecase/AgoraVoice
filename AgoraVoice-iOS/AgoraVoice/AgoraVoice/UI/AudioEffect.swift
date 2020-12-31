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
        case .belCanto:    return NSLocalizedString("Voice_Beautifier")
        case .soundEffect: return NSLocalizedString("Audio_Effects")
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
        case .chat:   return NSLocalizedString("Chat_Beautifier")
        case .sing:   return NSLocalizedString("Singing_Beautifier")
        case .timbre: return NSLocalizedString("Timbre_Transformation")
        }
    }
}

enum SoundEffectType {
    case space, role, musciGenre, electronicMusic
    
    static var list = BehaviorRelay<[SoundEffectType]>(value: [.space,
                                                               .role,
                                                               .musciGenre,
                                                               .electronicMusic])
    
    var description: String {
        switch self {
        case .space:           return NSLocalizedString("Room_Acoustics")
        case .role:            return NSLocalizedString("Voice_Changer_Effect")
        case .musciGenre:      return NSLocalizedString("Style_Transformation")
        case .electronicMusic: return NSLocalizedString("Pitch_Correction")
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
        case .maleMagnetic:   return NSLocalizedString("Male_Magnetic")
        case .femaleFresh:    return NSLocalizedString("Female_Fresh")
        case .femaleVitality: return NSLocalizedString("Female_Vitality")
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
        var value: Int
        
        switch self {
        case .male:
            value = 1
        case .female:
            value = 2
        case .disable:
            return "{\"che.audio.morph.reverb_preset\":0}"
        }
        
        let parameters = "{\"che.audio.morph.beauty_sing\":\(value)}"
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
        case .vigorous:    return NSLocalizedString("Vigorous")
        case .deep:        return NSLocalizedString("Deep")
        case .mellow:      return NSLocalizedString("Mellow")
        case .falsetto:    return NSLocalizedString("Falsetto")
        case .full:        return NSLocalizedString("Full")
        case .clear:       return NSLocalizedString("Clear")
        case .resounding:  return NSLocalizedString("Resounding")
        case .ringing:     return NSLocalizedString("Ringing")
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
        case .ktv:                    return NSLocalizedString("KTV")
        case .vocalConcer:            return NSLocalizedString("Vocal_Concert")
        case .studio:                 return NSLocalizedString("Studio")
        case .phonograph:             return NSLocalizedString("Phonograph")
        case .virtualStereo:          return NSLocalizedString("Virtual_Stereo")
        case .spacial:                return NSLocalizedString("Spacial")
        case .ethereal:               return NSLocalizedString("Ethereal")
        case .threeDimensionalVoice:  return NSLocalizedString("Three_Dimensional_Voice")
        case .disable:                fatalError()
        }
    }
    
    var parameters: String {
        var value: Int
        var parameters: String
        
        switch self {
        case .ktv:
            value = 1
            parameters = "{\"che.audio.morph.voice_changer\":\(value)}"
        case .vocalConcer:
            value = 2
            parameters = "{\"che.audio.morph.voice_changer\":\(value)}"
        case .studio:
            value = 5
            parameters = "{\"che.audio.morph.voice_changer\":\(value)}"
        case .phonograph:
            value = 8
            parameters = "{\"che.audio.morph.voice_changer\":\(value)}"
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
                                                          .babyGirl,
                                                          .sister,
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
        case .uncle:     return NSLocalizedString("Uncle")
        case .oldMan:    return NSLocalizedString("Old_Man")
        case .babyBoy:   return NSLocalizedString("Boy")
        case .sister:    return NSLocalizedString("Sister")
        case .babyGirl:  return NSLocalizedString("Girl")
        case .zhuBaJie:  return NSLocalizedString("Pig_King")
        case .hulk:      return NSLocalizedString("Hulk")
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
        case .rnb:     return NSLocalizedString("RNB")
        case .popular: return NSLocalizedString("Popular")
        case .rock:    return NSLocalizedString("Rock")
        case .hiphop:  return NSLocalizedString("HipHop")
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
