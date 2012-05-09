//
//  UITableView+NAB.h
//  Manga Rock 2
//
//  Created by Khoa Nguyen Thanh on 4/11/12.
//  Copyright (c) 2012 Not A Basement Studio®. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableView(NAB)

// Section Index View Customization
- (UIView *)sectionIndexView;
- (void)setSectionIndexTextColor:(UIColor *)textColor;
- (void)setSectionIndexFont:(UIFont *)font;
- (void)setSectionIndexFont:(UIFont *)font textColor:(UIColor *)textColor;

@end