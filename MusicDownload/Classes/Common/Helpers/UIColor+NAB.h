//
//  UIColor+NAB.h
//  Manhattan
//
//  Created by Khoa Nguyen Thanh on 12/28/11.
//  Copyright (c) 2011 Not A Basement Studio®. All rights reserved.
//

@interface UIColor(NAB)

+ (UIColor *)colorWith256Red:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha;
+ (UIColor *)colorFromString:(NSString *)string;

@end


@interface NSString(UIColorNAB)

+ (NSString *)stringFromColor:(UIColor *)color;

@end