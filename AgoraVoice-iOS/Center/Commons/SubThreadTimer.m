//
//  SubThreadTimer.m
//
//  Created by CavanSu on 2020/7/30.
//  Copyright © 2020 Agora. All rights reserved.
//

#import "SubThreadTimer.h"

@interface SubThreadTimer ()
@property (nonatomic, strong) NSThread *thread;
@property (nonatomic, strong) NSRunLoop *subRunLoop;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, copy) NSString *threadName;
@property (nonatomic, assign) NSTimeInterval interval;
@end

@implementation SubThreadTimer
- (instancetype)initWithThreadName:(NSString *)name
                      timeInterval:(NSTimeInterval)interval {
    if (self = [super init]) {
        self.threadName = name;
        self.interval = interval;
    }
    
    return self;
}

- (void)start {
    if (self.thread) {
        return;
    }
    
    self.thread = [[NSThread alloc] initWithTarget:self
                                          selector:@selector(run)
                                            object:nil];
    self.thread.name = self.threadName;
    [self.thread start];
}

- (void)stop {
    [self.timer invalidate];
    self.timer = nil;
    
    if (self.subRunLoop) {
        CFRunLoopRef runloop = [self.subRunLoop getCFRunLoop];
        CFRunLoopStop(runloop);
        self.subRunLoop = nil;
    }
    
    self.thread = nil;
}

- (void)run {
    self.subRunLoop = [NSRunLoop currentRunLoop];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:self.interval
                                                  target:self
                                                selector:@selector(loop)
                                                userInfo:nil
                                                 repeats:YES];
    
    [self.subRunLoop addTimer:self.timer forMode:NSRunLoopCommonModes];
    [self.subRunLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    [self.subRunLoop runMode:NSRunLoopCommonModes beforeDate:[NSDate distantFuture]];
}

- (void)loop {
    if ([self.delegate respondsToSelector:@selector(perLoop)]) {
        [self.delegate perLoop];
    }
}

@end
