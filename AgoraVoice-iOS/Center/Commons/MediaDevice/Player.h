//
//  Player.h
//  AgoraVoice
//
//  Created by CavanSu on 2020/9/1.
//  Copyright © 2020 Agora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AgoraRtcEngineKit/AgoraRtcEngineKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(int, PlayerStatus) {
    PlayerStatusStop = 0,
    PlayerStatusPause = 1,
    PlayerStatusPlaying = 2
};

@class Player;
@protocol PlayerDelegate <NSObject>
@optional
- (void)player:(Player *)player didReceivedFileDuration:(NSInteger)seconds;
- (void)player:(Player *)player playingCurrentSecond:(NSInteger)second;
- (void)player:(Player *)player didStartPlayFile:(NSString *)url;
- (void)player:(Player *)player didPausePlayFile:(NSString *)url;
- (void)player:(Player *)player didStopPlayFile:(NSString *)url;
- (void)player:(Player *)player didOccurError:(NSError *)error;
@end

@interface Player : NSObject
@property (nonatomic, weak) id<PlayerDelegate> delegate;
@property (atomic, assign) PlayerStatus status;

- (instancetype)initWithRtcEngine:(AgoraRtcEngineKit *)engine;
- (BOOL)startWithURL:(NSString *)url;
- (BOOL)pause;
- (BOOL)resume;
- (BOOL)seekWithSecond:(NSInteger)second;
- (BOOL)stop;
@end

NS_ASSUME_NONNULL_END
