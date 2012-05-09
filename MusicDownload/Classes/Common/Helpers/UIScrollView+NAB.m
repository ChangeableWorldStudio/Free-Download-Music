//
//  UIScrollView+NAB.m
//  Manhattan
//
//  Created by tkhoa87 on 5/12/11.
//  Copyright (c) 2011 Not A Basement Studio®. All rights reserved.
//

#import "UIScrollView+NAB.h"

@implementation UIScrollView(NAB)


#pragma mark - Content Inset

- (void)setContentInsetTop:(CGFloat)top {
    self.contentInset = UIEdgeInsetsMake(top,
                                         self.contentInset.left,
                                         self.contentInset.bottom,
                                         self.contentInset.right);
}

- (void)setContentInsetLeft:(CGFloat)left {
    self.contentInset = UIEdgeInsetsMake(self.contentInset.top,
                                         left,
                                         self.contentInset.bottom,
                                         self.contentInset.right);
}

- (void)setContentInsetBottom:(CGFloat)bottom {
    self.contentInset = UIEdgeInsetsMake(self.contentInset.top,
                                         self.contentInset.left,
                                         bottom,
                                         self.contentInset.right);
}

- (void)setContentInsetRight:(CGFloat)right {
    self.contentInset = UIEdgeInsetsMake(self.contentInset.top,
                                         self.contentInset.left,
                                         self.contentInset.bottom,
                                         right);
}


#pragma mark - Content Offset

- (void)setContentOffsetX:(CGFloat)x {
    self.contentOffset = CGPointMake(x,
                                     self.contentOffset.y);
}

- (void)setContentOffsetY:(CGFloat)y {
    self.contentOffset = CGPointMake(self.contentOffset.x,
                                     y);
}


@end
