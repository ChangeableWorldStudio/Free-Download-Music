//
//  ROFHUDView.m
//  HUD
//
//  Created by Hung Tran on 22/2/12.
//  Copyright (c) 2012 Not A Basement Studio®. All rights reserved.
//

#import "ROFHUDView.h"


@implementation ROFHUDView


#pragma mark - Inits

- (void)setUpROFHUDView {
    self.font = [UIFont fontWithName:ROF_FONT_PTSANS_NARROW_BOLD size:20.0f];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setUpROFHUDView];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setUpROFHUDView];
}


#pragma mark - Show/hide

- (void)showWithStyle:(ROFHUDViewStyle)style text:(NSString *)text animated:(BOOL)animated {
    NSString *imageName;
    switch (style) {
        case ROFHUDViewStyleSettings:
            imageName = @"ROFHUDViewSettings.png";
            break;
        case ROFHUDViewStyleFavorite:
            imageName = @"ROFHUDViewFavorite.png";
            break;
        case ROFHUDViewStyleFavoriteTransparent:
            imageName = @"ROFHUDViewFavoriteTransparent.png";
            break;
        case ROFHUDViewStyleDownload:
            imageName = @"ROFHUDViewDownload.png";
            break;
        case ROFHUDViewStyleViewerDirectionLTR:
            imageName = @"NABViewerIndicatorDirectionLTR.png";
            break;
        case ROFHUDViewStyleViewerDirectionRTL:
            imageName = @"NABViewerIndicatorDirectionRTL.png";
            break;
        case ROFHUDViewStyleViewerModePage:
            imageName = @"NABViewerIndicatorModePage.png";
            break;
        case ROFHUDViewStyleViewerModeStream:
            imageName = @"NABViewerIndicatorModeStream.png";
            break;    
        default:
            imageName = nil;
            break;
    }
    
    if (imageName) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
        [self showWithCustomView:imageView text:text animated:animated];
    } else {
        [self showWithIndicatorAndText:text animated:animated];
    }
}

- (void)showWithStyle:(ROFHUDViewStyle)style text:(NSString *)text animated:(BOOL)animated forSeconds:(NSTimeInterval)seconds {
    [self showWithStyle:style text:text animated:animated];
    [self hideAnimated:animated afterSeconds:seconds];
}


@end