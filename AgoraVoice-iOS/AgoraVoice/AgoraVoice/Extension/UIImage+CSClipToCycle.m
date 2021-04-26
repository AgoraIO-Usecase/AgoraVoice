//
//  UIImage+CSClipToCycle.m
//
//  Created by CavanSu on 17/3/21.
//  Copyright © 2017年 CavanSu. All rights reserved.
//

#import "UIImage+CSClipToCycle.h"

@implementation UIImage (CSClipToCycle)
+ (UIImage * _Nonnull)imageWithClipImage:(UIImage * _Nonnull)image
                             borderWidth:(CGFloat)borderWidth
                             borderColor:(UIColor * _Nullable)color {
    // 图片的宽度和高度
    CGFloat imageWH = image.size.width >= image.size.height ? image.size.height : image.size.width;
    
    // 设置圆环的宽度
    CGFloat border = borderWidth;
    
    // 圆形的宽度和高度
    CGFloat ovalWH = imageWH + 2 * border;
    
    // 1.开启上下文
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(ovalWH, ovalWH), NO, 0);
    
    // 2.画大圆
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, ovalWH, ovalWH)];
    
    [color set];
    
    [path fill];
    
    // 3.设置裁剪区域
    UIBezierPath *clipPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(border, border, imageWH, imageWH)];
    [clipPath addClip];
    
    // 4.绘制图片 以图片的最中心的点为圆绘制出来
    CGFloat startX = image.size.width <= imageWH ? ((image.size.width - imageWH) / 2) : ((imageWH - image.size.width) / 2);
    
    CGFloat startY = image.size.height <= imageWH ? ((image.size.height - imageWH) / 2) : ((imageWH - image.size.height) / 2);
    
    [image drawAtPoint:CGPointMake(startX, startY)]; // point 指 图片左上角的点，开始绘制在 上下文的哪个点上
    
    // 5.获取图片
    UIImage *clipImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // 6.关闭上下文
    UIGraphicsEndImageContext();
    
    return clipImage;
}

+ (UIImage * _Nonnull)imageWithClipImage:(UIImage * _Nonnull)image
                            cornerRadius:(CGFloat)radius
                             borderWidth:(CGFloat)borderWidth
                             borderColor:(UIColor * _Nullable)color {
    // 1.开启上下文
    CGFloat contextWidth = image.size.width;
    CGFloat contextHeight = image.size.height;
    CGSize contextSize = CGSizeMake(contextWidth, contextHeight);
    UIGraphicsBeginImageContextWithOptions(contextSize,
                                           NO,
                                           0);
    
    // 绘制底部曲线
    UIBezierPath *bezier = [UIBezierPath bezierPathWithArcCenter:CGPointMake(radius, radius)
                                                          radius:radius
                                                      startAngle:M_PI
                                                        endAngle: -(M_PI * 0.5)
                                                       clockwise:YES];
    
    CGPoint rightTopPoint = CGPointMake(image.size.width - radius, 0);
    [bezier addLineToPoint:rightTopPoint];
    
    [bezier addArcWithCenter:CGPointMake(image.size.width - radius, radius)
                      radius:radius
                  startAngle:-(M_PI * 0.5)
                    endAngle:0 clockwise:YES];
    
    CGPoint rightBottomPoint = CGPointMake(image.size.width, image.size.height - radius);
    [bezier addLineToPoint:rightBottomPoint];
    
    [bezier addArcWithCenter:CGPointMake(image.size.width - radius, image.size.height - radius)
                      radius:radius
                  startAngle:0
                    endAngle:M_PI * 0.5
                   clockwise:YES];
    
    CGPoint leftBottomPoint = CGPointMake(radius, image.size.height);
    [bezier addLineToPoint:leftBottomPoint];
    
    [bezier addArcWithCenter:CGPointMake(radius, image.size.height - radius)
                      radius:radius
                  startAngle:M_PI * 0.5
                    endAngle:M_PI
                   clockwise:YES];
    
    CGPoint leftTopPoint = CGPointMake(0, radius);
    [bezier addLineToPoint:leftTopPoint];
    
    [color setFill];
    [bezier fill];
    
    // 绘制裁剪区域
    CGFloat clipRadius = radius - borderWidth;
    UIBezierPath *clipBezier = [UIBezierPath bezierPathWithArcCenter:CGPointMake(radius, radius)
                                                              radius:clipRadius
                                                          startAngle:M_PI
                                                            endAngle: -(M_PI * 0.5)
                                                           clockwise:YES];
    
    CGPoint clipRightTopPoint = CGPointMake(image.size.width - radius, borderWidth);
    [clipBezier addLineToPoint:clipRightTopPoint];
    
    [clipBezier addArcWithCenter:CGPointMake(image.size.width - radius, radius)
                          radius:clipRadius
                      startAngle:-(M_PI * 0.5)
                        endAngle:0 clockwise:YES];
    
    CGPoint clipRightBottomPoint = CGPointMake(image.size.width - borderWidth, image.size.height - radius);
    [clipBezier addLineToPoint:clipRightBottomPoint];
    
    [clipBezier addArcWithCenter:CGPointMake(image.size.width - radius, image.size.height - radius)
                          radius:clipRadius
                      startAngle:0
                        endAngle:M_PI * 0.5
                       clockwise:YES];
    
    CGPoint clipLeftBottomPoint = CGPointMake(radius, image.size.height - borderWidth);
    [clipBezier addLineToPoint:clipLeftBottomPoint];
    
    [clipBezier addArcWithCenter:CGPointMake(radius, image.size.height - radius)
                          radius:clipRadius
                      startAngle:M_PI * 0.5
                        endAngle:M_PI
                       clockwise:YES];
    
    CGPoint clipLeftTopPoint = CGPointMake(borderWidth, radius);
    [clipBezier addLineToPoint:clipLeftTopPoint];
    
    [clipBezier addClip];
    
    [image drawInRect:CGRectMake(borderWidth, borderWidth, image.size.width, image.size.height)];
    
    // 获取图片
    UIImage *clipImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // 关闭上下文
    UIGraphicsEndImageContext();
    
    return clipImage;
}
@end
