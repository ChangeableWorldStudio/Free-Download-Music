//
//  AppDelegate.h
//  UISearchBar
//
//  Created by Hung Tran on 16/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UISearchBar+Extra.h"


@implementation UISearchBar(Extra)

- (void)removeBackground {
    for (UIView *subview in self.subviews) {
        if (CGRectEqualToRect(subview.frame, self.bounds) || (subview.frame.size.width == 1.0f)) {
            subview.alpha = 0.0f;
            subview.hidden = YES;
        }
    }
}

- (void)setEnabled:(BOOL)enabled {
    
    #define kUISearchBarCoverViewTag    888
    
    UIView *coverView = [self viewWithTag:kUISearchBarCoverViewTag];
    
    if (enabled) {
        if (coverView) {
            [coverView removeFromSuperview];
        }
    } else {
        if (coverView) {
            [self bringSubviewToFront:coverView];
        } else {
            coverView = [[UIView alloc] initWithFrame:self.bounds];
            coverView.tag = kUISearchBarCoverViewTag;
            coverView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            coverView.opaque = YES;
            coverView.clearsContextBeforeDrawing = NO;
            coverView.autoresizesSubviews = NO;
            coverView.clipsToBounds = NO;
            coverView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.5f];
            [self addSubview:coverView];
        }
    }
    self.userInteractionEnabled = enabled;
}

@end