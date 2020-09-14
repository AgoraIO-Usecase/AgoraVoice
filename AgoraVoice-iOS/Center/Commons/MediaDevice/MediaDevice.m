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
@end

@implementation MediaDevice
- (instancetype)initWithRtcEngine:(RTCManager *)engine {
    if (self = [super initWithRtcEngine:engine]) {
        self.player = [[Player alloc] initWithRtcEngine:engine];
    }
    return self;
}

- (void)recordAudioLoop:(BOOL)enable {
//    [self.agoraKit enableInEarMonitoring:enable];
}
@end
