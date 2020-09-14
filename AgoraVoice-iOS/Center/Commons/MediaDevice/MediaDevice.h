//
//  MediaDevice.h
//  AgoraVoice
//
//  Created by CavanSu on 2020/9/1.
//  Copyright © 2020 Agora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MediaDeviceBase.h"
#import "Player.h"
#import "AudioEffect.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(int, AudioOutputRouting) {
    /** Default. */
    AudioOutputRoutingDefault = -1,
    /** Headset.*/
    AudioOutputRoutingHeadset = 0,
    /** Earpiece. */
    AudioOutputRoutingEarpiece = 1,
    /** Headset with no microphone. */
    AudioOutputRoutingHeadsetNoMic = 2,
    /** Speakerphone. */
    AudioOutputRoutingSpeakerphone = 3,
    /** Loudspeaker. */
    AudioOutputRoutingLoudspeaker = 4,
    /** Bluetooth headset. */
    AudioOutputRoutingHeadsetBluetooth = 5
};

@class MediaDevice;
@protocol MediaDeviceDelegate <NSObject>
@optional
- (void)mediaDevice:(MediaDevice *)mediaDevice didChangeAudoOutputRouting:(AudioOutputRouting)routing;
- (void)mediaDevice:(MediaDevice *)mediaDevice didOccurError:(NSError *)error;
@end

@interface MediaDevice : MediaDeviceBase
@property (nonatomic, strong, readonly) Player *player;
//@property (nonatomic, strong, readonly) AudioEffect *recordAudioEffect;

- (void)recordAudioLoop:(BOOL)enable;
@end



NS_ASSUME_NONNULL_END
