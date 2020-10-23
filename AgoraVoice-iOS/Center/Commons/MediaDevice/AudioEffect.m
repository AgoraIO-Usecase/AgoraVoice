//
//  AudioEffect.m
//  AgoraVoice
//
//  Created by CavanSu on 2020/9/7.
//  Copyright © 2020 Agora. All rights reserved.
//

#import "AudioEffect.h"
#import <AgoraRtcKit/AgoraRtcEngineKit.h>

@implementation AudioEffect
// 语聊美声
- (void)setBelCantoWithChat:(ChatOfBelCanto)chat {
    switch (chat) {
        case ChatOfBelCantoMaleMagnetic:
            [self.agoraKit setLocalVoiceChanger:AgoraAudioGeneralBeautyVoiceMaleMagnetic];
            break;
        case ChatOfBelCantoFemaleFresh:
            [self.agoraKit setLocalVoiceChanger:AgoraAudioGeneralBeautyVoiceFemaleFresh];
            break;
        case ChatOfBelCantoFemaleVitality:
            [self.agoraKit setLocalVoiceChanger:AgoraAudioGeneralBeautyVoiceFemaleVitality];
            break;
        case ChatOfBelCantoDisable:
            [self cancelAudioEffect];
            break;
    }
}

// 歌唱美声
- (void)setBelCantoWithSing:(SingOfBelCanto)sing {
    switch (sing) {
        case SingOfBelCantoMale:
            [self.agoraKit setLocalVoiceChanger:AgoraAudioGeneralBeautySingMale];
            break;
        case SingOfBelCantoFemale:
            [self.agoraKit setLocalVoiceChanger:AgoraAudioGeneralBeautySingFemale];
            break;
        case SingOfBelCantoDisable:
            [self cancelAudioEffect];
            break;
    }
}

// 音色变换
- (void)setBelCantoWithTimbre:(Timbre)timbre {
    switch (timbre) {
        case TimbreDeep:
            [self.agoraKit setLocalVoiceChanger:AgoraAudioVoiceBeautyDeep];
            break;
        case TimbreFull:
            [self.agoraKit setLocalVoiceChanger:AgoraAudioVoiceBeautyFull];
            break;
        case TimbreClear:
            [self.agoraKit setLocalVoiceChanger:AgoraAudioVoiceBeautyClear];
            break;
        case TimbreMellow:
            [self.agoraKit setLocalVoiceChanger:AgoraAudioVoiceBeautyMellow];
            break;
        case TimbreRinging:
            [self.agoraKit setLocalVoiceChanger:AgoraAudioVoiceBeautyRinging];
            break;
        case TimbreFalsetto:
            [self.agoraKit setLocalVoiceChanger:AgoraAudioVoiceBeautyFalsetto];
            break;
        case TimbreVigorous:
            [self.agoraKit setLocalVoiceChanger:AgoraAudioVoiceBeautyVigorous];
            break;
        case TimbreResounding:
            [self.agoraKit setLocalVoiceChanger:AgoraAudioVoiceBeautyResounding];
            break;
        case TimbreDisable:
            [self cancelAudioEffect];
            break;
    }
}

#pragma mark - Sound Effect 音效类
// 空间塑造
- (void)setSoundEffectWithSpace:(AudioSpace)space {
    switch (space) {
        case AudioSpaceKTV:
            [self.agoraKit setLocalVoiceReverbPreset:AgoraAudioReverbPresetFxKTV];
            break;
        case AudioSpaceVocalConcer:
            [self.agoraKit setLocalVoiceReverbPreset:AgoraAudioReverbPresetFxVocalConcert];
            break;
        case AudioSpaceStudio:
            [self.agoraKit setLocalVoiceReverbPreset:AgoraAudioReverbPresetFxStudio];
            break;
        case AudioSpacePhonograph:
            [self.agoraKit setLocalVoiceReverbPreset:AgoraAudioReverbPresetFxPhonograph];
            break;
        case AudioSpaceVirtualStereo:
            [self.agoraKit setLocalVoiceReverbPreset:AgoraAudioReverbPresetVirtualStereo];
            break;
        case AudioSpaceSpacial:
            [self.agoraKit setLocalVoiceChanger:AgoraAudioVoiceBeautySpacial];
            break;
        case AudioSpaceEthereal:
            [self.agoraKit setLocalVoiceChanger:AgoraAudioVoiceChangerEthereal];
            break;
        case AudioSpaceThreeDimensionalVoice:
            [self.agoraKit setLocalVoiceReverbPreset:AgoraAudioReverbPresetThreeDimVoice];
            break;
        case AudioSpaceDisable:
            [self cancelAudioEffect];
            break;
    }
}

- (void)setThreedimVoiceOfSoundEffect:(NSInteger)value {
    NSString *parameters = [NSString stringWithFormat:@"{\"che.audio.morph.threedim_voice\":%ld}", value];
    [self.agoraKit setParameters:parameters];
}

// 变声音效
- (void)setSoundEffectWithRole:(TimbreRole)role {
    switch (role) {
        case TimbreRoleUncle:
            [self.agoraKit setLocalVoiceReverbPreset:AgoraAudioReverbPresetFxUncle];
            break;
        case TimbreRoleOldMan:
            [self.agoraKit setLocalVoiceChanger:AgoraAudioVoiceChangerOldMan];
            break;
        case TimbreRoleBabyBoy:
            [self.agoraKit setLocalVoiceChanger:AgoraAudioVoiceChangerBabyBoy];
            break;
        case TimbreRoleSister:
            [self.agoraKit setLocalVoiceReverbPreset:AgoraAudioReverbPresetFxSister];
            break;
        case TimbreRoleBabyGirl:
            [self.agoraKit setLocalVoiceChanger:AgoraAudioVoiceChangerBabyGirl];
            break;
        case TimbreRoleZhuBaJie:
            [self.agoraKit setLocalVoiceChanger:AgoraAudioVoiceChangerZhuBaJie];
            break;
        case TimbreRoleHulk:
            [self.agoraKit setLocalVoiceChanger:AgoraAudioVoiceChangerHulk];
            break;
        case TimbreRoleDisable:
            [self cancelAudioEffect];
            break;
    }
}

// 曲风音效
- (void)setSoundEffectWithMusicGenre:(MusicGenre)genre {
    switch (genre) {
        case MusicGenreRNB:
            [self.agoraKit setLocalVoiceReverbPreset:AgoraAudioReverbPresetFxRNB];
            break;
        case MusicGenrePopular:
            [self.agoraKit setLocalVoiceReverbPreset:AgoraAudioReverbPresetFxPopular];
            break;
        case MusicGenreRock:
            [self.agoraKit setLocalVoiceReverbPreset:AgoraAudioReverbPresetRock];
            break;
        case MusicGenreHipHop:
            [self.agoraKit setLocalVoiceReverbPreset:AgoraAudioReverbPresetHipHop];
            break;
        case MusicGenreDisable:
            [self cancelAudioEffect];
            break;
    }
}

// 电音
- (void)setElectronicMusicWithType:(NSInteger)type value:(NSInteger)value {
    NSString *parameters = [NSString stringWithFormat:@"{\"che.audio.morph.electronic_voice\":{\"key\":%ld,\"value\":%ld}}", type, value];
    [self.agoraKit setParameters:parameters];
}

- (void)cancelElectronicMusic {
    [self cancelAudioEffect];
}

- (void)cancelAudioEffect {
    [self.agoraKit setLocalVoiceReverbPreset:AgoraAudioReverbPresetOff];
    [self.agoraKit setLocalVoiceChanger:AgoraAudioVoiceChangerOff];
}

@end
