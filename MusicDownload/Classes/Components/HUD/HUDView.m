//
//  NABHUDView.m
//  HUD
//
//  Created by Hung Tran on 22/2/12.
//  Copyright (c) 2012 Not A Basement Studio®. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "HUDView.h"


@interface HUDView()

@property (nonatomic, strong)   UIView                  *coverView;
@property (nonatomic, strong)   UIView                  *cornerView;
@property (nonatomic, strong)   UILabel                 *textLabel;
@property (nonatomic, strong)   UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong)   NSTimer                 *hideTimer;

@end


@implementation HUDView

@synthesize cornerViewMinimumSize   = _cornerViewMinimumSize;
@synthesize cornerRadius            = _cornerRadius;
@synthesize paddingBottomLabel      = _paddingBottomLabel;
@synthesize font                    = _font;
@synthesize allowUserInteractions   = _allowUserInteractions;
@synthesize customView              = _customView;

@synthesize coverView               = _coverView;
@synthesize cornerView              = _cornerView;
@synthesize textLabel               = _textLabel;
@synthesize activityIndicator       = _activityIndicator;
@synthesize hideTimer               = _hideTimer;


#pragma mark - Inits

- (void)setUpStatusView {
    
    self.opaque = YES;
    self.clearsContextBeforeDrawing = NO;
    self.clipsToBounds = NO;
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.userInteractionEnabled = YES;
    
    self.backgroundColor = [UIColor clearColor];
    self.alpha = 0.0f;
    
    _cornerRadius = 10.0f;
    _cornerViewMinimumSize = CGSizeMake(160.0f, 160.0f);
    _paddingBottomLabel = 10.0f;
    _allowUserInteractions = NO;
    
    self.coverView = [[UIView alloc] initWithFrame:self.bounds];
    _coverView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _coverView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.5f];
    _coverView.userInteractionEnabled = NO;
    _coverView.alpha = 0.0f;
    [self addSubview:_coverView];
    
    self.cornerView = [[UIView alloc] initWithFrame:CGRectMake(roundf((self.bounds.size.width - _cornerViewMinimumSize.width) / 2.0f),
                                                               roundf((self.bounds.size.height - _cornerViewMinimumSize.height) / 2.0f),
                                                               _cornerViewMinimumSize.width,
                                                               _cornerViewMinimumSize.height)];
    _cornerView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    _cornerView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.5f];
    _cornerView.userInteractionEnabled = NO;
    [self addSubview:_cornerView];
    
    self.textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, _cornerViewMinimumSize.width, _cornerViewMinimumSize.height)];
    _textLabel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    _textLabel.adjustsFontSizeToFitWidth = NO;
    _textLabel.textAlignment = UITextAlignmentCenter;
    _textLabel.numberOfLines = 0;
    _textLabel.opaque = NO;
    _textLabel.backgroundColor = [UIColor clearColor];
    _textLabel.textColor = [UIColor whiteColor];
    _textLabel.font = [UIFont boldSystemFontOfSize:16.0f];
    _textLabel.userInteractionEnabled = NO;
    [_cornerView addSubview:_textLabel];
    
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _activityIndicator.hidesWhenStopped = YES;
    _activityIndicator.userInteractionEnabled = NO;
    [_cornerView addSubview:_activityIndicator];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setUpStatusView];
    }
    return self;
}

- (void)awakeFromNib {
    [self setUpStatusView];
}


#pragma mark - Getters

- (UIFont *)font {
    return _textLabel.font;
}


#pragma mark - Setters

- (void)setFont:(UIFont *)font {
    _textLabel.font = font;
}


#pragma mark - Hide/Show HUD

- (void)showWithIndicatorAndText:(NSString *)text animated:(BOOL)animated {
    
    if (_hideTimer) {
        [_hideTimer invalidate];
        self.hideTimer = nil;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (self.superview) {
            [self.superview bringSubviewToFront:self];
        }
        
        if (_customView) {
            [_customView removeFromSuperview];
            self.customView = nil;
        }
        
        // Find corner view size
        CGSize cornerViewSize;
        cornerViewSize.width = MAX(_cornerViewMinimumSize.width,
                                   _cornerRadius + _activityIndicator.frame.size.width + _cornerRadius);
        
        CGFloat textHeight = [text sizeWithFont:_textLabel.font constrainedToSize:CGSizeMake(cornerViewSize.width - 2 * _cornerRadius, CGFLOAT_MAX) lineBreakMode:_textLabel.lineBreakMode].height;
        textHeight = MIN(textHeight, _textLabel.font.lineHeight * 2.0f);
        
        if (textHeight > 0.0f) {
            cornerViewSize.height = MAX(_cornerViewMinimumSize.height,
                                        _cornerRadius + _activityIndicator.frame.size.height + _paddingBottomLabel + textHeight + _cornerRadius);
        } else {
            cornerViewSize.height = MAX(_cornerViewMinimumSize.height,
                                        _cornerRadius + _activityIndicator.frame.size.height + _cornerRadius);
        }
        
        // Prepare cornerView
        _cornerView.frame = CGRectMake(roundf((self.bounds.size.width - cornerViewSize.width)/2),
                                       roundf((self.bounds.size.height - cornerViewSize.height)/2),
                                       cornerViewSize.width,
                                       cornerViewSize.height);
        _cornerView.layer.cornerRadius = _cornerRadius;
        
        // Prepare textLabel
        _textLabel.text = text;
        _textLabel.frame = CGRectMake(_cornerRadius,
                                      cornerViewSize.height - _cornerRadius - textHeight,
                                      cornerViewSize.width - 2 * _cornerRadius,
                                      textHeight);
        
        // Prepare activityIndicator
        if (textHeight > 0.0f) {
            _activityIndicator.frame = CGRectMake(roundf((cornerViewSize.width - _activityIndicator.frame.size.width)/2),
                                                  _cornerRadius + roundf((cornerViewSize.height - _cornerRadius * 2 - textHeight - _paddingBottomLabel - _activityIndicator.frame.size.height)/2),
                                                  _activityIndicator.frame.size.width,
                                                  _activityIndicator.frame.size.height);
        } else {
            _activityIndicator.frame = CGRectMake(roundf((cornerViewSize.width - _activityIndicator.frame.size.width)/2),
                                                  roundf((cornerViewSize.height - _activityIndicator.frame.size.height)/2),
                                                  _activityIndicator.frame.size.width,
                                                  _activityIndicator.frame.size.height);
        }
        if (!_activityIndicator.isAnimating) {
            [_activityIndicator startAnimating];
        }
        
        // Showing animation
        if (animated) {
            self.alpha = self.alpha;
            [UIView animateWithDuration:0.2f delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                self.alpha = 1.0f;
                _coverView.alpha = _allowUserInteractions ? 0.0f : 1.0f;
            } completion:^(BOOL finished) {
                self.userInteractionEnabled = !_allowUserInteractions;
            }];
        } else {
            self.alpha = 1.0f;
            _coverView.alpha = _allowUserInteractions ? 0.0f : 1.0f;
            self.userInteractionEnabled = !_allowUserInteractions;
        }
    });
}

- (void)showWithIndicatorAndText:(NSString *)text animated:(BOOL)animated forSeconds:(NSTimeInterval)seconds {
    [self showWithIndicatorAndText:text animated:animated];
    [self hideAnimated:animated afterSeconds:seconds];
}

- (void)showWithOnlyText:(NSString *)text animated:(BOOL)animated {
    
    if (_hideTimer) {
        [_hideTimer invalidate];
        self.hideTimer = nil;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (self.superview) {
            [self.superview bringSubviewToFront:self];
        }
        
        if (_customView) {
            [_customView removeFromSuperview];
            self.customView = nil;
        }
        
        [_activityIndicator stopAnimating];
        
        // Find corner view size
        CGSize textSize = [text sizeWithFont:_textLabel.font];
        textSize.height = MIN(textSize.height, _textLabel.font.lineHeight * 2.0f);
        
        CGSize cornerViewSize;
        cornerViewSize.width = MAX(_cornerViewMinimumSize.width,
                                   _cornerRadius + textSize.width + _cornerRadius);
        cornerViewSize.height = MAX(_cornerViewMinimumSize.height,
                                    _cornerRadius + textSize.height + _cornerRadius);
        
        // Prepare cornerView
        _cornerView.frame = CGRectMake(roundf((self.bounds.size.width - cornerViewSize.width)/2),
                                       roundf((self.bounds.size.height - cornerViewSize.height)/2),
                                       cornerViewSize.width,
                                       cornerViewSize.height);
        _cornerView.layer.cornerRadius = _cornerRadius;
        
        // Prepare textLabel
        _textLabel.text = text;
        _textLabel.frame = CGRectMake(_cornerRadius,
                                      _cornerRadius,
                                      cornerViewSize.width - 2 * _cornerRadius,
                                      cornerViewSize.height - 2 * _cornerRadius);
        
        // Showing animation
        if (animated) {
            self.alpha = self.alpha;
            [UIView animateWithDuration:0.2f delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                self.alpha = 1.0f;
                _coverView.alpha = _allowUserInteractions ? 0.0f : 1.0f;
            } completion:^(BOOL finished) {
                self.userInteractionEnabled = !_allowUserInteractions;
            }];
        } else {
            self.alpha = 1.0f;
            _coverView.alpha = _allowUserInteractions ? 0.0f : 1.0f;
            self.userInteractionEnabled = !_allowUserInteractions;
        }
    });
}

- (void)showWithOnlyText:(NSString *)text animated:(BOOL)animated forSeconds:(NSTimeInterval)seconds {
    [self showWithOnlyText:text animated:animated];
    [self hideAnimated:animated afterSeconds:seconds];
}

- (void)showWithCustomView:(UIView *)customView text:(NSString *)text animated:(BOOL)animated {
    
    if (_hideTimer) {
        [_hideTimer invalidate];
        self.hideTimer = nil;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (self.superview) {
            [self.superview bringSubviewToFront:self];
        }
        
        if (_customView) {
            [_customView removeFromSuperview];
        }
        self.customView = customView;
        customView.userInteractionEnabled = NO;
        
        [_activityIndicator stopAnimating];
        
        // Find corner view size
        CGSize cornerViewSize;
        cornerViewSize.width = MAX(_cornerViewMinimumSize.width,
                                   _cornerRadius + _customView.frame.size.width + _cornerRadius);
        
        CGFloat textHeight = [text sizeWithFont:_textLabel.font constrainedToSize:CGSizeMake(cornerViewSize.width - 2 * _cornerRadius, CGFLOAT_MAX) lineBreakMode:_textLabel.lineBreakMode].height;
        textHeight = MIN(textHeight, _textLabel.font.lineHeight * 2.0f);
        if (textHeight > 0.0f) {
            cornerViewSize.height = MAX(_cornerViewMinimumSize.height,
                                        _cornerRadius + _customView.frame.size.height + _paddingBottomLabel + textHeight + _cornerRadius);
        } else {
            cornerViewSize.height = MAX(_cornerViewMinimumSize.height,
                                        _cornerRadius + _customView.frame.size.height + _cornerRadius);
        }
        
        // Prepare cornerView
        _cornerView.frame = CGRectMake(roundf((self.bounds.size.width - cornerViewSize.width)/2),
                                       roundf((self.bounds.size.height - cornerViewSize.height)/2),
                                       cornerViewSize.width,
                                       cornerViewSize.height);
        _cornerView.layer.cornerRadius = _cornerRadius;
        
        // Prepare textLabel
        _textLabel.text = text;
        _textLabel.frame = CGRectMake(_cornerRadius,
                                      cornerViewSize.height - _cornerRadius - textHeight,
                                      cornerViewSize.width - 2 * _cornerRadius,
                                      textHeight);
        
        // Prepare customView
        [_cornerView addSubview:customView];
        if (textHeight > 0.0f) {
            customView.frame = CGRectMake(roundf((cornerViewSize.width - _customView.frame.size.width)/2),
                                          _cornerRadius + roundf((cornerViewSize.height - _cornerRadius * 2 - textHeight - _paddingBottomLabel - _customView.frame.size.height)/2),
                                          _customView.frame.size.width,
                                          _customView.frame.size.height);
        } else {
            customView.frame = CGRectMake(roundf((cornerViewSize.width - _customView.frame.size.width)/2),
                                          roundf((cornerViewSize.height - _customView.frame.size.height)/2),
                                          _customView.frame.size.width,
                                          _customView.frame.size.height);
        }
        
        // Showing animation
        if (animated) {
            self.alpha = self.alpha;
            [UIView animateWithDuration:0.2f delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                self.alpha = 1.0f;
                _coverView.alpha = _allowUserInteractions ? 0.0f : 1.0f;
            } completion:^(BOOL finished) {
                self.userInteractionEnabled = !_allowUserInteractions;
            }];
        } else {
            self.alpha = 1.0f;
            _coverView.alpha = _allowUserInteractions ? 0.0f : 1.0f;
            self.userInteractionEnabled = !_allowUserInteractions;
        }
    });
}

- (void)showWithCustomView:(UIView *)customView text:(NSString *)text animated:(BOOL)animated forSeconds:(NSTimeInterval)seconds {
    [self showWithCustomView:customView text:text animated:animated];
    [self hideAnimated:animated afterSeconds:seconds];
}

- (void)hideAnimated {
    if (_hideTimer) {
        [_hideTimer invalidate];
        self.hideTimer = nil;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (_customView) {
            [_customView removeFromSuperview];
            self.customView = nil;
        }
        
        [_activityIndicator stopAnimating];
        
        [UIView animateWithDuration:0.2f delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            self.alpha = 0.0f;
        } completion:nil];
    });
}

- (void)hideAnimated:(BOOL)animated afterSeconds:(NSTimeInterval)seconds {
    if (_hideTimer) {
        [_hideTimer invalidate];
    }
    self.hideTimer = [NSTimer scheduledTimerWithTimeInterval:seconds target:self selector:@selector(hideAnimated) userInfo:nil repeats:NO];
}


@end
