//
//  UIColor+Hex.h
//  YoYo
//
//  Created by CavanSu on 2018/6/19.
//  Copyright © 2018 CavanSu. All rights reserved.
//

#import <Foundation/Foundation.h>
#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#else
#import <Cocoa/Cocoa.h>
#endif

#if TARGET_OS_IPHONE
@interface UIColor (Hex)
+ (UIColor * _Nonnull)colorWithHexString:(NSString * _Nonnull)color;
@end
#endif
