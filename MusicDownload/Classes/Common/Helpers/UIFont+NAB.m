//
//  UIFont+NAB.m
//  Manga Rock 2
//
//  Created by Khoa Nguyen Thanh on 3/5/12.
//  Copyright (c) 2012 Not A Basement Studio®. All rights reserved.
//

#import "UIFont+NAB.h"

@implementation UIFont(NAB)


#pragma mark - Logging

+ (void)listAllFonts {
    for (NSString *familyName in [UIFont familyNames]) {
        NSLog(@"%@", familyName);
        for (NSString *fontName in [UIFont fontNamesForFamilyName:familyName]) {
            NSLog(@"- %@", fontName);
        }
    }
}


#pragma mark - Demonstration

+ (UIScrollView *)scrollViewWithAllSizesForFont:(UIFont *)font text:(NSString *)text textColor:(UIColor *)textColor backgroundColor:(UIColor *)backgroundColor {
    
    if (!font) font = [UIFont boldSystemFontOfSize:0];
    if (!text) text = @"The quick brown fox jumps over the lazy dog";
    if (!textColor) textColor = [UIColor blackColor];
    if (!backgroundColor) backgroundColor = [UIColor clearColor];
    
    
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    
    CGFloat width = 0.0f;
    CGFloat height = 0.0f;
    
    for (int i = 1; i <= 30; i++) {
        
        UIFont *currentFont = [font fontWithSize:i];
        NSString *currentText = [NSString stringWithFormat:@"%@ (size %d)", text, i];
        
        CGSize size = [currentText sizeWithFont:currentFont];
        width = MAX(size.width, width);
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, height, width, size.height)];
        label.font = currentFont;
        label.text = currentText;
        label.textColor = textColor;
        label.backgroundColor = backgroundColor;
        [scrollView addSubview:label];
        
        height += size.height + 20.0f;
    }
    
    scrollView.contentSize = CGSizeMake(width, height);
    
    return scrollView;
}

@end
