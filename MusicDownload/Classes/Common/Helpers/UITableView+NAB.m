//
//  UITableView+NAB.m
//  Manga Rock 2
//
//  Created by Khoa Nguyen Thanh on 4/11/12.
//  Copyright (c) 2012 Not A Basement Studio®. All rights reserved.
//

#import "UITableView+NAB.h"

@implementation UITableView(NAB)


#pragma mark - Section Index View

- (UIView *)sectionIndexView {
    for (UIView *view in self.subviews) {
        if ([view respondsToSelector:@selector(setIndexColor:)]) {
            return view;
        }
    }
    return nil;
}

- (void)setSectionIndexTextColor:(UIColor *)textColor {
    UIView *sectionIndexView = [self sectionIndexView];
    if (sectionIndexView) {
        if ([sectionIndexView respondsToSelector:@selector(setIndexColor:)]) {
            [sectionIndexView performSelector:@selector(setIndexColor:) withObject:textColor];
        }
    }
}

- (void)setSectionIndexFont:(UIFont *)font {
    UIView *sectionIndexView = [self sectionIndexView];
    if (sectionIndexView) {
        if ([sectionIndexView respondsToSelector:@selector(setFont:)]) {
            [sectionIndexView performSelector:@selector(setFont:) withObject:font];
        }
    }
}

- (void)setSectionIndexFont:(UIFont *)font textColor:(UIColor *)textColor {
    UIView *sectionIndexView = [self sectionIndexView];
    if (sectionIndexView) {
        if ([sectionIndexView respondsToSelector:@selector(setIndexColor:)]) {
            [sectionIndexView performSelector:@selector(setIndexColor:) withObject:textColor];
        }
        if ([sectionIndexView respondsToSelector:@selector(setFont:)]) {
            [sectionIndexView performSelector:@selector(setFont:) withObject:font];
        }
    }
}


@end
