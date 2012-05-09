//
//  UIView+NAB.h
//  NABCommon
//
//  Created by tkhoa87 on 19/9/11.
//  Copyright (c) 2011 Not A Basement Studio®. All rights reserved.
//

#import <UIKit/UIKit.h>


@implementation UIView(CW)

- (void)setFrameOrigin:(CGPoint)newOrigin {
    self.frame = CGRectMake(newOrigin.x, newOrigin.y, self.frame.size.width, self.frame.size.height);
}

- (void)setFrameSize:(CGSize)newSize {
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, newSize.width, newSize.height);
}

- (void)setFrameOriginX:(CGFloat)newX {
    self.frame = CGRectMake(newX, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
}

- (void)setFrameOriginY:(CGFloat)newY {
    self.frame = CGRectMake(self.frame.origin.x, newY, self.frame.size.width, self.frame.size.height);
}
- (void)setFrameSizeWidth:(CGFloat)newWidth {
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, newWidth, self.frame.size.width);
}

- (void)setFrameSizeHeight:(CGFloat)newHeight {
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, newHeight);
}


@end