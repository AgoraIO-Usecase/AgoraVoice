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
        @unknown default:
            fatalError()
        }
    }
    
    var description: String {
        switch self {
        case .maleMagnetic:   return NSLocalizedString("Male_Magnetic")
        case .femaleFresh:    return NSLocalizedString("Female_Fresh")
        case .femaleVitality: return NSLocalizedString("Female_Vitality")
        case .disable:        fatalError()
        @unknown default:
            fatalError()
        }
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
        @unknown default:
            fatalError()
        }
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
        @unknown default:
            fatalError()
        }
    }
}

extension AudioSpace {
    static var list = BehaviorRelay<[AudioSpace]>(value: [.KTV,
                                                          .vocalConcer,
                                                          .studio,
                                                          .phonograph,
                                                          .virtualStereo,
                                                          .spacial,
                                                          .ethereal,
                                                          .threeDimensionalVoice])
    
    var image: UIImage {
        switch self {
        case .KTV:                    return UIImage(named: "icon-KTV")!
        case .vocalConcer:            return UIImage(named: "icon-演唱会")!
        case .studio:                 return UIImage(named: "icon-录音棚")!
        case .phonograph:             return UIImage(named: "icon-留声机")!
        case .virtualStereo:          return UIImage(named: "icon-虚拟立体声")!
        case .spacial:                return UIImage(named: "icon-空旷")!
        case .ethereal:               return UIImage(named: "icon-空灵")!
        case .threeDimensionalVoice:  return UIImage(named: "icon-3D人声")!
        case .disable:                fatalError()
        @unknown default:
            fatalError()
        }
    }
    
    var description: String {
        switch self {
        case .KTV:                    return NSLocalizedString("KTV")
        case .vocalConcer:            return NSLocalizedString("Vocal_Concert")
        case .studio:                 return NSLocalizedString("Studio")
        case .phonograph:             return NSLocalizedString("Phonograph")
        case .virtualStereo:          return NSLocalizedString("Virtual_Stereo")
        case .spacial:                return NSLocalizedString("Spacial")
        case .ethereal:               return NSLocalizedString("Ethereal")
        case .threeDimensionalVoice:  return NSLocalizedString("Three_Dimensional_Voice")
        case .disable:                fatalError()
        @unknown default:
            fatalError()
        }
    }
}

extension TimbreRole {
    static var list = BehaviorRelay<[TimbreRole]>(value: [.uncle,
                                                          .oldMan,
                                                          .babyBoy,
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
        @unknown default:
            fatalError()
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
        @unknown default:
            fatalError()
        }
    }
}

extension MusicGenre {
    static var list = BehaviorRelay<[MusicGenre]>(value: [.RNB,
                                                          .popular,
                                                          .rock,
                                                          .hipHop])
    
    var image: UIImage {
        switch self {
        case .RNB:     return UIImage(named: "icon-R&B")!
        case .popular: return UIImage(named: "icon-流行")!
        case .rock:    return UIImage(named: "icon-摇滚")!
        case .hipHop:  return UIImage(named: "icon-嘻哈")!
        case .disable: fatalError()
        @unknown default:
            fatalError()
        }
    }
    
    var description: String {
        switch self {
        case .RNB:     return NSLocalizedString("RNB")
        case .popular: return NSLocalizedString("Popular")
        case .rock:    return NSLocalizedString("Rock")
        case .hipHop:  return NSLocalizedString("HipHop")
        case .disable: fatalError()
        @unknown default:
            fatalError()
        }
    }
}
