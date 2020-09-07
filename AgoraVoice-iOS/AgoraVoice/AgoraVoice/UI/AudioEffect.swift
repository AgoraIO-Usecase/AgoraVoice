//
//  AudioEffect.swift
//  AgoraVoice
//
//  Created by CavanSu on 2020/9/7.
//  Copyright © 2020 CavanSu. All rights reserved.
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
        case .belCanto:    return "美声"
        case .soundEffect: return "音效"
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
        case .chat:   return "语音美声"
        case .sing:   return "歌唱美声"
        case .timbre: return "音色变换"
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
        case .space:           return "空间塑造"
        case .role:            return "变声音效"
        case .musciGenre:      return "曲风音效"
        case .electronicMusic: return "电音音效"
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
        case .maleMagnetic:   return "maleMagnetic"
        case .femaleFresh:    return "femaleFresh"
        case .femaleVitality: return "femaleVitality"
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
        case .male:    return "male"
        case .female:  return "female"
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
        case .vigorous:    return "male"
        case .deep:        return "female"
        case .mellow:      return "mellow"
        case .falsetto:    return "falsetto"
        case .full:        return "full"
        case .clear:       return "clear"
        case .resounding:  return "resounding"
        case .ringing:     return "ringing"
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
                                                          .ethereal])
    
    var image: UIImage {
        switch self {
        case .KTV:            return UIImage(named: "icon-KTV")!
        case .vocalConcer:    return UIImage(named: "icon-演唱会")!
        case .studio:         return UIImage(named: "icon-录音棚")!
        case .phonograph:     return UIImage(named: "icon-留声机")!
        case .virtualStereo:  return UIImage(named: "icon-虚拟立体声")!
        case .spacial:        return UIImage(named: "icon-空旷")!
        case .ethereal:       return UIImage(named: "icon-空灵")!
        case .disable:        fatalError()
        @unknown default:
            fatalError()
        }
    }
    
    var description: String {
        switch self {
        case .KTV:            return "KTV"
        case .vocalConcer:    return "vocalConcer"
        case .studio:         return "studio"
        case .phonograph:     return "phonograph"
        case .virtualStereo:  return "virtualStereo"
        case .spacial:        return "spacial"
        case .ethereal:       return "ethereal"
        case .disable:        fatalError()
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
        case .uncle:     return "uncle"
        case .oldMan:    return "oldMan"
        case .babyBoy:   return "babyBoy"
        case .sister:    return "sister"
        case .babyGirl:  return "babyGirl"
        case .zhuBaJie:  return "zhuBaJie"
        case .hulk:      return "hulk"
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
        case .RNB:     return "R&B"
        case .popular: return "popular"
        case .rock:    return "rock"
        case .hipHop:  return "hipHop"
        case .disable: fatalError()
        @unknown default:
            fatalError()
        }
    }
}
