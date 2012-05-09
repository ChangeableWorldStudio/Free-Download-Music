//
//  ROFHUDView.h
//  HUD
//
//  Created by Hung Tran on 22/2/12.
//  Copyright (c) 2012 Not A Basement Studio®. All rights reserved.
//

#import "NABHUDView.h"


typedef enum {
    ROFHUDViewStyleSettings,
	ROFHUDViewStyleFavorite,
    ROFHUDViewStyleFavoriteTransparent,
    ROFHUDViewStyleDownload,
    ROFHUDViewStyleViewerDirectionLTR,
    ROFHUDViewStyleViewerDirectionRTL,
    ROFHUDViewStyleViewerModePage,
    ROFHUDViewStyleViewerModeStream,
} ROFHUDViewStyle;


@interface ROFHUDView : NABHUDView

- (void)showWithStyle:(ROFHUDViewStyle)style text:(NSString *)text animated:(BOOL)animated;
- (void)showWithStyle:(ROFHUDViewStyle)style text:(NSString *)text animated:(BOOL)animated forSeconds:(NSTimeInterval)seconds;

@end