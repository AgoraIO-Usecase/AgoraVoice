//
//  Player.h
//  AgoraVoice
//
//  Created by CavanSu on 2020/9/1.
//  Copyright © 2020 Agora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MediaDeviceBase.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(int, PlayerStatus) {
    PlayerStatusStop = 0,
    PlayerStatusPause = 1,
    PlayerStatusPlaying = 2
};

@class Player;
@protocol PlayerDelegate <NSObject>
@optional
- (void)player:(Player *)player didStartPlayFile:(NSString *)url duration:(NSInteger)seconds;
- (void)player:(Player *)player didPausePlayFile:(NSString *)url;
- (void)player:(Player *)player didResumePlayFile:(NSString *)url;
- (void)player:(Player *)player didStopPlayFile:(NSString *)url;
- (void)player:(Player *)player didPlayFileFinish:(NSString *)url;
- (void)player:(Player *)player didOccurError:(NSError *)error;

- (void)player:(Player *)player playingCurrentSecond:(NSInteger)second duration:(NSInteger)seconds;
- (void)player:(Player *)player didChangePlayerStatusFrom:(PlayerStatus)previous to:(PlayerStatus)current;
@end

@interface Player : MediaDeviceBase
@property (nonatomic, copy, nullable) NSString *fileURL;
@property (nonatomic, weak) id<PlayerDelegate> delegate;
@property (nonatomic, assign) PlayerStatus status;

- (BOOL)startWithURL:(NSString *)url;
- (BOOL)pause;
- (BOOL)resume;
- (BOOL)seekWithSecond:(NSInteger)second;
- (BOOL)stop;
@end

NS_ASSUME_NONNULL_END
