//
//  UIView+NAB.h
//  NABCommon
//
//  Created by tkhoa87 on 19/9/11.
//  Copyright (c) 2011 Not A Basement Studio®. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIView(CW)

- (void)setFrameOrigin:(CGPoint)newOrigin;
- (void)setFrameSize:(CGSize)newSize;
- (void)setFrameOriginX:(CGFloat)newX;
- (void)setFrameOriginY:(CGFloat)newY;
- (void)setFrameSizeWidth:(CGFloat)newWidth;
- (void)setFrameSizeHeight:(CGFloat)newHeight;

@end