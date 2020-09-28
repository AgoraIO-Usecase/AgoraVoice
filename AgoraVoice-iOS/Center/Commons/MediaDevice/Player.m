//
//  Player.m
//  AgoraVoice
//
//  Created by CavanSu on 2020/9/1.
//  Copyright © 2020 Agora. All rights reserved.
//

#import "Player.h"
#import <EduSDK/RTCManagerDelegate.h>
#import "SubThreadTimer.h"

@interface Player () <SubThreadTimerDelegate, RTCAudioMixingDelegate>
@property (nonatomic, strong) SubThreadTimer *timer;
@property (nonatomic, copy) NSString *lastURL;
@end

@implementation Player
- (instancetype)initWithRtcEngine:(RTCManager *)engine {
    if (self = [super initWithRtcEngine:engine]) {
        self.status = PlayerStatusStop;
        self.timer = [[SubThreadTimer alloc] initWithThreadName:@"MediaDevice-Player-Playing" timeInterval:1.0];
        self.timer.delegate = self;
        engine.audioMixingDelegate = self;
    }
    return self;
}

- (BOOL)startWithURL:(NSString *)url {
    self.status = PlayerStatusStop;
    int result = [self.agoraKit startAudioMixing:url loopback:true replace:false cycle:1];
    BOOL success = result == 0 ? YES : NO;
    if (success) {
        self.fileURL = url;
    }
    return success;
}

- (BOOL)resume {
    int result = [self.agoraKit resumeAudioMixing];
    BOOL success = result == 0 ? YES : NO;
    return success;
}

- (BOOL)pause {
    int result = [self.agoraKit pauseAudioMixing];
    BOOL success = result == 0 ? YES : NO;
    return success;
}

- (BOOL)seekWithSecond:(NSInteger)second {
    int result = [self.agoraKit setAudioMixingPosition:second];
    BOOL success = result == 0 ? YES : NO;
    return success;
}

- (BOOL)stop {
    int result = [self.agoraKit stopAudioMixing];
    BOOL success = result == 0 ? YES : NO;
    return success;
}

- (BOOL)adjustAudioMixingVolume:(NSInteger)volume {
    int result = [self.agoraKit adjustAudioMixingPublishVolume:volume];
    result = [self.agoraKit adjustAudioMixingPlayoutVolume:volume];
    BOOL success = result == 0 ? YES : NO;
    return success;
}

- (NSInteger)getAudioMixingVolume {
    NSInteger volume = [self.agoraKit getAudioMixingPlayoutVolume];
    return volume;
}

#pragma mark - Private
- (void)checkOccurErrorWithAPICallResult:(int)result {
    if (result == 0) {
        return;
    }
    
    NSString *domain = @"Player_Occur_Error";
    NSError *error = [NSError errorWithDomain:domain
                                         code:result
                                     userInfo:nil];
    
    if ([self.delegate respondsToSelector:@selector(player:didOccurError:)]) {
        [self.delegate player:self didOccurError:error];
    }
}

#pragma mark - AudioMixingDelegate
- (void)rtcLocalAudioMixingDidFinish {
    if ([self.delegate respondsToSelector:@selector(player:didPlayFileFinish:)]) {
        [self.delegate player:self didPlayFileFinish:self.fileURL];
    }
    
    if (self.status == PlayerStatusPlaying) {
        self.status = PlayerStatusStop;
    }
}

- (void)setStatus:(PlayerStatus)status {
    if (_status == status) {
        return;
    }
    
    PlayerStatus previous = _status;
    _status = status;
    PlayerStatus current = _status;
    
    if ([self.delegate respondsToSelector:@selector(player:didChangePlayerStatusFrom:to:)]) {
        [self.delegate player:self didChangePlayerStatusFrom:previous to:current];
    }
}

- (void)rtcLocalAudioMixingStateDidChanged:(AgoraAudioMixingStateCode)state errorCode:(AgoraAudioMixingErrorCode)errorCode {
    printf("");
    if ((!self.fileURL && state != AgoraAudioMixingStateFailed)
        && [self.delegate respondsToSelector:@selector(player:didOccurError:)]) {
        NSError *error = [[NSError alloc] initWithDomain:@"Player url nil" code:-1 userInfo:nil];
        [self.delegate player:self didOccurError:error];
        return;
    }
    
    switch (state) {
        case AgoraAudioMixingStatePlaying:
            if (self.status == PlayerStatusStop) {
                self.status = PlayerStatusPlaying;
                if ([self.delegate respondsToSelector:@selector(player:didStartPlayFile:duration:)]) {
                    int duration = [self.agoraKit getAudioMixingDuration];
                    [self.delegate player:self didStartPlayFile:self.fileURL duration:duration];
                }
            } else if (self.status == PlayerStatusPause) {
                self.status = PlayerStatusPlaying;
                if ([self.delegate respondsToSelector:@selector(player:didResumePlayFile:)]) {
                    [self.delegate player:self didResumePlayFile:self.fileURL];
                }
            }
            break;
        case AgoraAudioMixingStatePaused:
            if (self.status == PlayerStatusPlaying) {
                self.status = PlayerStatusPause;
                if ([self.delegate respondsToSelector:@selector(player:didPausePlayFile:)]) {
                    [self.delegate player:self didPausePlayFile:self.fileURL];
                }
            }
            break;
        case AgoraAudioMixingStateStopped:
            if (self.status == PlayerStatusPlaying || self.status == PlayerStatusPause) {
                self.status = PlayerStatusStop;
                if ([self.delegate respondsToSelector:@selector(player:didStopPlayFile:)]) {
                    [self.delegate player:self didStopPlayFile:self.fileURL];
                }
            }
            break;
        case AgoraAudioMixingStateFailed:
            self.status = PlayerStatusStop;
            if ([self.delegate respondsToSelector:@selector(player:didOccurError:)]) {
                NSError *error = [[NSError alloc] initWithDomain:@"Player occured error" code:errorCode userInfo:nil];
                [self.delegate player:self didOccurError:error];
            }
            break;
        default:
            break;
    }
}

#pragma mark - SubThreadTimerDelegate
- (void)perLoop {
    if ([self.delegate respondsToSelector:@selector(player:playingCurrentSecond:duration:)]) {
        int current = [self.agoraKit getAudioMixingCurrentPosition];
        int duration = [self.agoraKit getAudioMixingDuration];
        
        [self.delegate player:self playingCurrentSecond:current duration:duration];
    }
}

@end
