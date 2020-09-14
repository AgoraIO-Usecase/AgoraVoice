//
//  SubThreadTimer.h
//
//  Created by CavanSu on 2020/7/30.
//  Copyright © 2020 Agora. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol SubThreadTimerDelegate <NSObject>
- (void)perLoop;
@end

@interface SubThreadTimer : NSObject
@property (nonatomic, weak, nullable) id<SubThreadTimerDelegate> delegate;
- (instancetype)initWithThreadName:(NSString *)name timeInterval:(NSTimeInterval)interval;
- (void)start;
- (void)stop;
@end

NS_ASSUME_NONNULL_END
