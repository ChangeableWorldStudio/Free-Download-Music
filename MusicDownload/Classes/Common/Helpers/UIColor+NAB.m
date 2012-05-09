//
//  UIColor+NAB.m
//  Manhattan
//
//  Created by Khoa Nguyen Thanh on 12/28/11.
//  Copyright (c) 2011 Not A Basement Studio®. All rights reserved.
//

#import "UIColor+NAB.h"

@implementation UIColor(NAB)

+ (UIColor *)colorWith256Red:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha {
    return [UIColor colorWithRed:red / 255.0f
                           green:green / 255.0f
                            blue:blue / 255.0f
                           alpha:alpha];
}

+ (UIColor *)colorFromString:(NSString *)string {
    
    NSArray *parts = [string componentsSeparatedByString:@" "];
    
    if ([parts count] > 1) {
        NSString *colorSpaceName = [parts objectAtIndex:0];
        NSArray *components = [[parts objectAtIndex:1] componentsSeparatedByString:@";"];
        
        if ([colorSpaceName isEqualToString:@"Monochrome"]) {
            
            CGFloat white   = [[components objectAtIndex:0] floatValue];
            CGFloat alpha   = [[components objectAtIndex:1] floatValue];
            return [UIColor colorWithWhite:white alpha:alpha];
            
        } else if ([colorSpaceName isEqualToString:@"RGB"]) {
            
            CGFloat red     = [[components objectAtIndex:0] floatValue];
            CGFloat green   = [[components objectAtIndex:1] floatValue];
            CGFloat blue    = [[components objectAtIndex:2] floatValue];
            CGFloat alpha   = [[components objectAtIndex:3] floatValue];
            return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
            
        }
    }
    
    return [UIColor greenColor];
}

@end


@implementation NSString(UIColorNAB)

+ (NSString *)stringFromColor:(UIColor *)color {
    
    CGColorSpaceModel colorSpaceModel = CGColorSpaceGetModel(CGColorGetColorSpace(color.CGColor));
    
    switch (colorSpaceModel) {
        case kCGColorSpaceModelMonochrome: {
            const float* components = CGColorGetComponents(color.CGColor);
            CGFloat white   = components[0];
            CGFloat alpha   = components[1];
            return [NSString stringWithFormat:@"Monochrome %f;%f", white, alpha];
        }
        case kCGColorSpaceModelRGB: {
            const float* components = CGColorGetComponents(color.CGColor);
            CGFloat red     = components[0];
            CGFloat green   = components[1];
            CGFloat blue    = components[2];
            CGFloat alpha   = components[3];
            return [NSString stringWithFormat:@"RGB %f;%f;%f;%f", red, green, blue, alpha];
        }
        case kCGColorSpaceModelCMYK: {
            const float* components = CGColorGetComponents(color.CGColor);
            CGFloat C       = components[0];
            CGFloat M       = components[1];
            CGFloat Y       = components[2];
            CGFloat K       = components[3];
            CGFloat alpha   = components[4];
            return [NSString stringWithFormat:@"CMYK %f;%f;%f;%f;%f", C, M, Y, K, alpha];
        }
        case kCGColorSpaceModelLab: {
            const float* components = CGColorGetComponents(color.CGColor);
            CGFloat L       = components[0];
            CGFloat a       = components[1];
            CGFloat b       = components[2];
            CGFloat alpha   = components[3];
            return [NSString stringWithFormat:@"Lab %f;%f;%f;%f", L, a, b, alpha];
        }
        case kCGColorSpaceModelDeviceN:
            return @"DeviceN";
        case kCGColorSpaceModelIndexed:
            return @"Indexed";
        case kCGColorSpaceModelPattern:
            return @"Pattern";
        case kCGColorSpaceModelUnknown:
            return @"Unknown";
        default:
            return @"Others";
    }
    
}

@end