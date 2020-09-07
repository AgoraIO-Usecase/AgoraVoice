//
//  AudioEffect.h
//  AgoraVoice
//
//  Created by CavanSu on 2020/9/7.
//  Copyright © 2020 CavanSu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(int, ChatOfBelCanto) {
    ChatOfBelCantoDisable,
    ChatOfBelCantoMaleMagnetic,
    ChatOfBelCantoFemaleFresh,
    ChatOfBelCantoFemaleVitality
};

typedef NS_ENUM(int, SingOfBelCanto) {
    SingOfBelCantoDisable,
    SingOfBelCantoMale,
    SingOfBelCantoFemale
};

typedef NS_ENUM(int, Timbre) {
    TimbreDisable,
    TimbreVigorous,
    TimbreDeep,
    TimbreMellow,
    TimbreFalsetto,
    TimbreFull,
    TimbreClear,
    TimbreResounding,
    TimbreRinging
};

typedef NS_ENUM(int, AudioSpace) {
    AudioSpaceDisable,
    AudioSpaceKTV,
    AudioSpaceVocalConcer,
    AudioSpaceStudio,
    AudioSpacePhonograph,
    AudioSpaceVirtualStereo,
    AudioSpaceSpacial,
    AudioSpaceEthereal
};

typedef NS_ENUM(int, TimbreRole) {
    TimbreRoleDisable,
    TimbreRoleUncle,
    TimbreRoleOldMan,
    TimbreRoleBabyBoy,
    TimbreRoleSister,
    TimbreRoleBabyGirl,
    TimbreRoleZhuBaJie,
    TimbreRoleHulk
};

typedef NS_ENUM(int, MusicGenre) {
    MusicGenreDisable,
    MusicGenreRNB,
    MusicGenrePopular,
    MusicGenreRock,
    MusicGenreHipHop,
};

@interface AudioEffect : NSObject
#pragma mark - Bel Canto 美声类
// 语聊美声
- (void)setBelCantoWithChat:(ChatOfBelCanto)chat;
// 歌唱美声
- (void)setBelCantoWithSing:(SingOfBelCanto)sing;

// 音色变换
- (void)setBelCantoWithTimbre:(Timbre)timbre;

#pragma mark - Sound Effect 音效类
// 空间塑造
- (void)setSoundEffectWithSpace:(AudioSpace)space;
- (void)setThreedimVoiceOfSoundEffect;

// 变声音效
- (void)setSoundEffectWithRole:(TimbreRole)role;

// 曲风音效
- (void)setSoundEffectWithMusicGenre:(MusicGenre)genre;
@end

NS_ASSUME_NONNULL_END
