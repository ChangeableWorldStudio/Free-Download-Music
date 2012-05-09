//
//  CALayer+NAB.m
//  Manhattan
//
//  Created by Khoa Nguyen Thanh on 2/10/12.
//  Copyright (c) 2012 Not A Basement Studio®. All rights reserved.
//

#import "CALayer+NAB.h"

@implementation CALayer(NAB)

+ (CALayer *)layerMaskWithMaskFrame:(CGRect)maskFrame inFullSize:(CGSize)fullSize {
    
    UIGraphicsBeginImageContextWithOptions(fullSize, NO, 1.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [[UIColor whiteColor] setFill];
    CGContextFillRect(context, CGRectMake(0.0f, 0.0f, fullSize.width, fullSize.height));
    
    CGContextSetBlendMode(context, kCGBlendModeClear);
    CGContextFillRect(context, maskFrame);
    
    UIImage *maskImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CALayer *layer = [CALayer layer];
    layer.frame = CGRectMake(0.0f, 0.0f, fullSize.width, fullSize.height);
    layer.contents = (id) maskImage.CGImage;
    
    return layer;
}

@end
