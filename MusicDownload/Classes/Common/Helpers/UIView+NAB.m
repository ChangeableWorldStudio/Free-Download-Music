//
//  UIView+Extra.m
//  NABCommon
//
//  Created by tkhoa87 on 15/8/11.
//  Copyright (c) 2011 Not A Basement Studio®. All rights reserved.
//

#import "UIView+NAB.h"

@implementation UIView(NAB)


#pragma mark - Frame

- (void)setFrameOrigin:(CGPoint)newOrigin {
    self.frame = CGRectMake(newOrigin.x,
                            newOrigin.y,
                            self.frame.size.width,
                            self.frame.size.height);
}

- (void)setFrameSize:(CGSize)newSize {
    self.frame = CGRectMake(self.frame.origin.x,
                            self.frame.origin.y,
                            newSize.width,
                            newSize.height);
}

- (void)setFrameOriginX:(CGFloat)newX {
    self.frame = CGRectMake(newX,
                            self.frame.origin.y,
                            self.frame.size.width,
                            self.frame.size.height);
}

- (void)setFrameOriginY:(CGFloat)newY {
    self.frame = CGRectMake(self.frame.origin.x,
                            newY,
                            self.frame.size.width,
                            self.frame.size.height);
}

- (void)setFrameSizeWidth:(CGFloat)newWidth {
    self.frame = CGRectMake(self.frame.origin.x,
                            self.frame.origin.y,
                            newWidth,
                            self.frame.size.height);
}

- (void)setFrameSizeHeight:(CGFloat)newHeight {
    self.frame = CGRectMake(self.frame.origin.x,
                            self.frame.origin.y,
                            self.frame.size.width,
                            newHeight);
}


#pragma mark - Center

- (void)setCenterX:(CGFloat)newX {
    self.center = CGPointMake(newX,
                              self.center.y);
}

- (void)setCenterY:(CGFloat)newY {
    self.center = CGPointMake(self.center.x,
                              newY);
}


#pragma mark - Convert

- (CGFloat)convertX:(CGFloat)x toView:(UIView *)anotherView {
    return [self convertPoint:CGPointMake(x, 0.0f) toView:anotherView].x;
}

- (CGFloat)convertX:(CGFloat)x fromView:(UIView *)anotherView {
    return [self convertPoint:CGPointMake(x, 0.0f) fromView:anotherView].x;
}

- (CGFloat)convertY:(CGFloat)y toView:(UIView *)anotherView {
    return [self convertPoint:CGPointMake(0.0f, y) toView:anotherView].y;
}

- (CGFloat)convertY:(CGFloat)y fromView:(UIView *)anotherView {
    return [self convertPoint:CGPointMake(0.0f, y) fromView:anotherView].y;
}


#pragma mark - Add Subviews

- (void)addSubview:(UIView *)subview keepSubviewFrameOnScreen:(BOOL)keepPosition {
    if (keepPosition && subview.superview) {
        subview.frame = [subview.superview convertRect:subview.frame toView:self];
    }
    [self addSubview:subview];
}

@end