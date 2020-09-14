//
//  AudioEffect.m
//  AgoraVoice
//
//  Created by CavanSu on 2020/9/7.
//  Copyright © 2020 Agora. All rights reserved.
//

#import "AudioEffect.h"
#import <AgoraRtcEngineKit/AgoraRtcEngineKit.h>

@implementation AudioEffect
// 语聊美声
- (void)setBelCantoWithChat:(ChatOfBelCanto)chat {
    switch (chat) {
        case ChatOfBelCantoMaleMagnetic:
            // AgoraAudioVoiceChanger
            break;
        case ChatOfBelCantoFemaleFresh:
            break;
        case ChatOfBelCantoFemaleVitality:
            break;
        case ChatOfBelCantoDisable:
            break;
    }
}

// 歌唱美声
- (void)setBelCantoWithSing:(SingOfBelCanto)sing {
    switch (sing) {
        case SingOfBelCantoMale:
            break;
        case SingOfBelCantoFemale:
            break;
        case SingOfBelCantoDisable:
            break;
    }
}

// 音色变换
- (void)setBelCantoWithTimbre:(Timbre)timbre {
    switch (timbre) {
        case TimbreDeep:
            break;
        case TimbreFull:
            break;
        case TimbreClear:
            break;
        case TimbreMellow:
            break;
        case TimbreRinging:
            break;
        case TimbreFalsetto:
            break;
        case TimbreVigorous:
            break;
        case TimbreResounding:
            break;
        case TimbreDisable:
            break;
    }
}

#pragma mark - Sound Effect 音效类
// 空间塑造
- (void)setSoundEffectWithSpace:(AudioSpace)space {
    switch (space) {
        case AudioSpaceKTV:
            break;
        case AudioSpaceVocalConcer:
            break;
        case AudioSpaceStudio:
            break;
        case AudioSpacePhonograph:
            break;
        case AudioSpaceVirtualStereo:
            break;
        case AudioSpaceSpacial:
            break;
        case AudioSpaceEthereal:
            break;
        case AudioSpaceThreeDimensionalVoice:
            break;
        case AudioSpaceDisable:
            break;
    }
}

- (void)setThreedimVoiceOfSoundEffect {
    
}

// 变声音效
- (void)setSoundEffectWithRole:(TimbreRole)role {
    switch (role) {
        case TimbreRoleUncle:
            break;
        case TimbreRoleOldMan:
            break;
        case TimbreRoleBabyBoy:
            break;
        case TimbreRoleSister:
            break;
        case TimbreRoleBabyGirl:
            break;
        case TimbreRoleZhuBaJie:
            break;
        case TimbreRoleHulk:
            break;
        case TimbreRoleDisable:
            break;
    }
}

// 曲风音效
- (void)setSoundEffectWithMusicGenre:(MusicGenre)genre {
    switch (genre) {
        case MusicGenreRNB:
            break;
        case MusicGenrePopular:
            break;
        case MusicGenreRock:
            break;
        case MusicGenreHipHop:
            break;
        case MusicGenreDisable:
            break;
    }
}
@end
