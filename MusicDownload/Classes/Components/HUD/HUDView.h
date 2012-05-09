//
//  NABHUDView.h
//  HUD
//
//  Created by Hung Tran on 22/2/12.
//  Copyright (c) 2012 Not A Basement Studio®. All rights reserved.
//


@interface HUDView : UIView

@property (nonatomic)           CGSize      cornerViewMinimumSize;
@property (nonatomic)           CGFloat     cornerRadius;
@property (nonatomic)           CGFloat     paddingBottomLabel;
@property (nonatomic, strong)   UIFont      *font;
@property (nonatomic)           BOOL        allowUserInteractions;

@property(nonatomic, strong)    UIView      *customView;

- (void)showWithIndicatorAndText:(NSString *)text animated:(BOOL)animated;
- (void)showWithIndicatorAndText:(NSString *)text animated:(BOOL)animated forSeconds:(NSTimeInterval)seconds;

- (void)showWithOnlyText:(NSString *)text animated:(BOOL)animated;
- (void)showWithOnlyText:(NSString *)text animated:(BOOL)animated forSeconds:(NSTimeInterval)seconds;

- (void)showWithCustomView:(UIView *)customView text:(NSString *)text animated:(BOOL)animated;
- (void)showWithCustomView:(UIView *)customView text:(NSString *)text animated:(BOOL)animated forSeconds:(NSTimeInterval)seconds;

- (void)hideAnimated;
- (void)hideAnimated:(BOOL)animated afterSeconds:(NSTimeInterval)seconds;

@end