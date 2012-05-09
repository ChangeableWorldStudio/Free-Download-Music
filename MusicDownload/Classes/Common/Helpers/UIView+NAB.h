//
//  UIView+NAB.h
//  NABCommon
//
//  Created by tkhoa87 on 15/8/11.
//  Copyright (c) 2011 Not A Basement Studio®. All rights reserved.
//

@interface UIView(NAB)

- (void)setFrameOrigin:(CGPoint)newOrigin;
- (void)setFrameSize:(CGSize)newSize;
- (void)setFrameOriginX:(CGFloat)newX;
- (void)setFrameOriginY:(CGFloat)newY;
- (void)setFrameSizeWidth:(CGFloat)newWidth;
- (void)setFrameSizeHeight:(CGFloat)newHeight;

- (void)setCenterX:(CGFloat)newX;
- (void)setCenterY:(CGFloat)newY;

- (CGFloat)convertX:(CGFloat)x toView:(UIView *)anotherView;
- (CGFloat)convertX:(CGFloat)x fromView:(UIView *)anotherView;
- (CGFloat)convertY:(CGFloat)y toView:(UIView *)anotherView;
- (CGFloat)convertY:(CGFloat)y fromView:(UIView *)anotherView;

- (void)addSubview:(UIView *)subview keepSubviewFrameOnScreen:(BOOL)keepPosition;

@end
