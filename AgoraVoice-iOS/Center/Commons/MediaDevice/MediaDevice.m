//
//  MediaDevice.m
//  AgoraVoice
//
//  Created by CavanSu on 2020/9/1.
//  Copyright © 2020 Agora. All rights reserved.
//

#import "MediaDevice.h"

@interface MediaDevice ()
@property (nonatomic, strong) Player *player;
@property (nonatomic, weak) AgoraRtcEngineKit *agoraKit;
@end

@implementation MediaDevice
- (instancetype)initWithRtcEngine:(AgoraRtcEngineKit *)engine {
    if (self = [super init]) {
        self.agoraKit = engine;
        self.player = [[Player alloc] initWithRtcEngine:engine];
    }
    return self;
}

- (void)recordAudioLoop:(BOOL)enable {
    [self.agoraKit enableInEarMonitoring:enable];
}
@end
