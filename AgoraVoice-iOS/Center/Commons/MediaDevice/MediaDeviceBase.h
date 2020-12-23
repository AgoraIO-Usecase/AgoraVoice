//
//  MediaDeviceBase.h
//  AgoraVoice
//
//  Created by CavanSu on 2020/9/14.
//  Copyright © 2020 Agora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EduSDK/RTCManager.h>

NS_ASSUME_NONNULL_BEGIN

@interface MediaDeviceBase : NSObject
@property (nonatomic, weak) RTCManager *agoraKit;
- (instancetype)initWithRtcEngine:(RTCManager *)engine;
@end

NS_ASSUME_NONNULL_END
