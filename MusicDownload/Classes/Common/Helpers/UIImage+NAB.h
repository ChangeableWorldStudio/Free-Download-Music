// UIImage+Resize.h
// Created by Trevor Harmon on 8/5/09.
// Free for personal or commercial use, with or without modification.
// No warranty is expressed or implied.

// Extends the UIImage class to support resizing/cropping

@interface UIImage(NAB)

- (UIImage *)croppedImage:(CGRect)bounds;
- (UIImage *)resizedImage:(CGSize)newSize interpolationQuality:(CGInterpolationQuality)quality __attribute__((deprecated));
- (UIImage *)resizedImageWithContentMode:(UIViewContentMode)contentMode bounds:(CGSize)bounds interpolationQuality:(CGInterpolationQuality)quality __attribute__((deprecated));
- (UIImage *)resizedImageWithContentMode:(UIViewContentMode)contentMode bounds:(CGSize)bounds scale:(CGFloat)scale;

- (UIImage *)imageWithTintColor:(UIColor *)tintColor blendMode:(CGBlendMode)blendMode;

- (UIImage *)imageByIgnoringOrientation;
- (UIImage *)imageByFlippingHorizontally:(BOOL)flipHorizontal vertically:(BOOL)flipVertical;
- (UIImage *)imageByRotatedHalvesOfPi:(int)numberHalvesOfPi;

@end
