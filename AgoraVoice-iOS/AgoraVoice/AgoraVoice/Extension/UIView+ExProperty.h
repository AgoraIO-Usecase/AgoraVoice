//
//  UIView+ExProperty.h
//  AgoraAudio
//
//  Created by CavanSu on 07/02/2018.
//  Copyright © 2018 Agora. All rights reserved.
//

#import <Foundation/Foundation.h>
#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#else
#import <Cocoa/Cocoa.h>
#endif

#if TARGET_OS_IPHONE
@interface UIView (ExProperty)
@property (nonatomic) IBInspectable UIColor *borderColor;
@property (nonatomic) IBInspectable CGFloat borderWidth;
@property (nonatomic) IBInspectable CGFloat cornerRadius;
@property (nonatomic) IBInspectable BOOL masksToBounds;
@property (nonatomic) IBInspectable NSString *hexBackgroundColor;
@property (nonatomic) IBInspectable NSString *hexBorderColor;
@end

@interface UILabel (ExProperty)
@property (nonatomic) IBInspectable BOOL adjustsFontSizeToFit;
@property (nonatomic) IBInspectable NSString *hexTextColor;
@end

@interface UIButton (ExProperty)
@property (nonatomic) IBInspectable BOOL adjustsFontSizeToFit;
@property (nonatomic) IBInspectable NSString *hexTextColor;
@end

@interface UITextField (ExProperty)
@property (nonatomic) IBInspectable NSString *hexTextColor;
@property (nonatomic) IBInspectable NSString *placeholderColorString;
@end

@interface UISegmentedControl (ExProperty)
@property (nonatomic) IBInspectable NSString *hexTintColor;
@end

@interface UISwitch (ExProperty)
@property (nonatomic) IBInspectable NSString *hexTintColor;
@property (nonatomic) IBInspectable NSString *hexThumbTintColor;
@end

@interface UISlider (ExProperty)
@property (nonatomic) IBInspectable NSString *hexThumbTintColor;
@property (nonatomic) IBInspectable NSString *thumbImage;
@property (nonatomic) IBInspectable NSString *maxTrackColor;
@property (nonatomic) IBInspectable NSString *minTrackColor;
@end

#else
@interface NSView (ExProperty)
@property (nonatomic) IBInspectable NSColor *borderColor;
@property (nonatomic) IBInspectable CGFloat borderWidth;
@property (nonatomic) IBInspectable CGFloat cornerRadius;
@property (nonatomic) IBInspectable BOOL masksToBounds;
//@property (nonatomic) IBInspectable NSColor *layerBackgroundColor;
@property (nonatomic) IBInspectable NSColor *backgroundColor;
@end
#endif

