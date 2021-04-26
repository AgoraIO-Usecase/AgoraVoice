//
//  UIImage+CSClipToCycle.h
//
//  Created by CavanSu on 17/3/21.
//  Copyright © 2017年 CavanSu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (CSClipToCycle)
+ (UIImage * _Nonnull)imageWithClipImage:(UIImage * _Nonnull)image
                             borderWidth:(CGFloat)borderWidth
                             borderColor:(UIColor * _Nullable)color;

+ (UIImage * _Nonnull)imageWithClipImage:(UIImage * _Nonnull)image
                            cornerRadius:(CGFloat)radius
                             borderWidth:(CGFloat)borderWidth
                             borderColor:(UIColor * _Nullable)color;
@end
