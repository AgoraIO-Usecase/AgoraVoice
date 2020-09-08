//
//  Player.m
//  AgoraVoice
//
//  Created by CavanSu on 2020/9/1.
//  Copyright © 2020 Agora. All rights reserved.
//

#import "Player.h"

@interface Player ()
@property (nonatomic, weak) AgoraRtcEngineKit *agoraKit;
@end

@implementation Player
- (instancetype)initWithRtcEngine:(AgoraRtcEngineKit *)engine {
    if (self = [super init]) {
        self.agoraKit = engine;
        self.status = PlayerStatusStop;
    }
    return self;
}

- (BOOL)startWithURL:(NSString *)url {
    int result = [self.agoraKit startAudioMixing:url loopback:true replace:false cycle:1];
    BOOL success = result == 0 ? YES : NO;
    if (success) {
        self.status = PlayerStatusPlaying;
    }
    return (result == 0 ? YES : NO);
}

- (BOOL)resume {
    int result = [self.agoraKit resumeAudioMixing];
    BOOL success = result == 0 ? YES : NO;
    if (success) {
        self.status = PlayerStatusPlaying;
    }
    return success;
}

- (BOOL)pause {
    int result = [self.agoraKit pauseAudioMixing];
    BOOL success = result == 0 ? YES : NO;
    if (success) {
        self.status = PlayerStatusPause;
    }
    return success;
}

- (BOOL)seekWithSecond:(NSInteger)second {
    int result = [self.agoraKit setAudioMixingPosition:second];
    BOOL success = result == 0 ? YES : NO;
    if (success) {
        self.status = PlayerStatusPlaying;
    }
    return success;
}

- (BOOL)stop {
    int result = [self.agoraKit stopAudioMixing];
    BOOL success = result == 0 ? YES : NO;
    if (success) {
        self.status = PlayerStatusStop;
    }
    return success;
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
@end
