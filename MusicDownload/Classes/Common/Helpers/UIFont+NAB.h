//
//  UIFont+NAB.h
//  Manga Rock 2
//
//  Created by Khoa Nguyen Thanh on 3/5/12.
//  Copyright (c) 2012 Not A Basement Studio®. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface UIFont(NAB)

+ (void)listAllFonts;
+ (UIScrollView *)scrollViewWithAllSizesForFont:(UIFont *)font text:(NSString *)text textColor:(UIColor *)textColor backgroundColor:(UIColor *)backgroundColor;

@end
