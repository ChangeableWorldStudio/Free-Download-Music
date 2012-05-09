// UIImage+Resize.m
// Created by Trevor Harmon on 8/5/09.
// Free for personal or commercial use, with or without modification.
// No warranty is expressed or implied.

#import "UIImage+NAB.h"


@interface UIImage(NABPrivate)

- (UIImage *)resizedImage:(CGSize)newSize
                transform:(CGAffineTransform)transform
           drawTransposed:(BOOL)transpose
     interpolationQuality:(CGInterpolationQuality)quality;
- (CGAffineTransform)transformForOrientation:(CGSize)newSize;

@end


#pragma mark -


@implementation UIImage(NABPrivate)

// Returns a copy of the image that has been transformed using the given affine transform and scaled to the new size
// The new image's orientation will be UIImageOrientationUp, regardless of the current image's orientation
// If the new size is not integral, it will be rounded up
- (UIImage *)resizedImage:(CGSize)newSize
                transform:(CGAffineTransform)transform
           drawTransposed:(BOOL)transpose
     interpolationQuality:(CGInterpolationQuality)quality {
    CGRect newRect = CGRectIntegral(CGRectMake(0, 0, newSize.width, newSize.height));
    CGRect transposedRect = CGRectMake(0, 0, newRect.size.height, newRect.size.width);
    CGImageRef imageRef = self.CGImage;
    
    // Build a context that's the same dimensions as the new size
    CGContextRef bitmap = CGBitmapContextCreate(NULL,
                                                newRect.size.width,
                                                newRect.size.height,
                                                CGImageGetBitsPerComponent(imageRef),
                                                0,
                                                CGImageGetColorSpace(imageRef),
                                                CGImageGetBitmapInfo(imageRef));
    
    // Rotate and/or flip the image if required by its orientation
    CGContextConcatCTM(bitmap, transform);
    
    // Set the quality level to use when rescaling
    CGContextSetInterpolationQuality(bitmap, quality);
    
    // Draw into the context; this scales the image
    CGContextDrawImage(bitmap, transpose ? transposedRect : newRect, imageRef);
    
    // Get the resized image from the context and a UIImage
    CGImageRef newImageRef = CGBitmapContextCreateImage(bitmap);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    
    // Clean up
    CGContextRelease(bitmap);
    CGImageRelease(newImageRef);
    
    return newImage;
}

// Returns an affine transform that takes into account the image orientation when drawing a scaled image
- (CGAffineTransform)transformForOrientation:(CGSize)newSize {
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (self.imageOrientation) {
        case UIImageOrientationDown:           // EXIF = 3
        case UIImageOrientationDownMirrored:   // EXIF = 4
            transform = CGAffineTransformTranslate(transform, newSize.width, newSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:           // EXIF = 6
        case UIImageOrientationLeftMirrored:   // EXIF = 5
            transform = CGAffineTransformTranslate(transform, newSize.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:          // EXIF = 8
        case UIImageOrientationRightMirrored:  // EXIF = 7
            transform = CGAffineTransformTranslate(transform, 0, newSize.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (self.imageOrientation) {
        case UIImageOrientationUpMirrored:     // EXIF = 2
        case UIImageOrientationDownMirrored:   // EXIF = 4
            transform = CGAffineTransformTranslate(transform, newSize.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:   // EXIF = 5
        case UIImageOrientationRightMirrored:  // EXIF = 7
            transform = CGAffineTransformTranslate(transform, newSize.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    return transform;
}

@end


#pragma mark -


@implementation UIImage(NAB)


#pragma mark - Cropping

// Returns a copy of this image that is cropped to the given bounds.
// The bounds will be adjusted using CGRectIntegral.
// This method ignores the image's imageOrientation setting.
- (UIImage *)croppedImage:(CGRect)bounds {
    CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage], bounds);
    UIImage *croppedImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return croppedImage;
}


#pragma mark - Resizing

// Returns a rescaled copy of the image, taking into account its orientation
// The image will be scaled disproportionately if necessary to fit the bounds specified by the parameter
- (UIImage *)resizedImage:(CGSize)newSize interpolationQuality:(CGInterpolationQuality)quality {
    BOOL drawTransposed;
    
    switch (self.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            drawTransposed = YES;
            break;
            
        default:
            drawTransposed = NO;
    }
    
    return [self resizedImage:newSize
                    transform:[self transformForOrientation:newSize]
               drawTransposed:drawTransposed
         interpolationQuality:quality];
}

// Resizes the image according to the given content mode, taking into account the image's orientation
- (UIImage *)resizedImageWithContentMode:(UIViewContentMode)contentMode bounds:(CGSize)bounds interpolationQuality:(CGInterpolationQuality)quality {
    
    CGFloat horizontalRatio = bounds.width / self.size.width;
    CGFloat verticalRatio = bounds.height / self.size.height;
    CGFloat ratio;
    
    switch (contentMode) {
        case UIViewContentModeScaleAspectFill:
            ratio = MAX(horizontalRatio, verticalRatio);
            break;
            
        case UIViewContentModeScaleAspectFit:
            ratio = MIN(horizontalRatio, verticalRatio);
            break;
            
        default:
            [NSException raise:NSInvalidArgumentException format:@"Unsupported content mode: %d", contentMode];
    }
    
    CGSize newSize = CGSizeMake(self.size.width * ratio, self.size.height * ratio);
    
    return [self resizedImage:newSize interpolationQuality:quality];
}

- (UIImage *)resizedImageWithContentMode:(UIViewContentMode)contentMode bounds:(CGSize)bounds scale:(CGFloat)scale {
    
    CGSize newSize;
    switch (contentMode) {
        case UIViewContentModeScaleAspectFill: {
            CGFloat horizontalRatio = bounds.width / self.size.width;
            CGFloat verticalRatio = bounds.height / self.size.height;
            
            if (horizontalRatio > verticalRatio) {
                newSize = CGSizeMake(bounds.width, roundf(self.size.height * horizontalRatio));
            } else {
                newSize = CGSizeMake(roundf(self.size.width * verticalRatio), bounds.height);
            }
            break;
        }
        case UIViewContentModeScaleAspectFit: {
            CGFloat horizontalRatio = bounds.width / self.size.width;
            CGFloat verticalRatio = bounds.height / self.size.height;
            
            if (horizontalRatio < verticalRatio) {
                newSize = CGSizeMake(bounds.width, roundf(self.size.height * horizontalRatio));
            } else {
                newSize = CGSizeMake(roundf(self.size.width * verticalRatio), bounds.height);
            }
            break;
        }
        case UIViewContentModeScaleToFill:
        default:
            newSize = bounds;
            break;
    }
    
    UIGraphicsBeginImageContextWithOptions(newSize, NO, scale);
    
    [self drawInRect:CGRectMake(0.0f, 0.0f, newSize.width, newSize.height)];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
    
}


#pragma mark - Tinting

- (UIImage *)imageWithTintColor:(UIColor *)tintColor blendMode:(CGBlendMode)blendMode {
    
    UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Draw image
    [self drawAtPoint:CGPointZero];
    
    // Draw color (keep alpha mask of the image)
    CGContextScaleCTM(context, 1.0f, -1.0f);
    CGContextTranslateCTM(context, 0.0f, -self.size.height);
    
    CGContextClipToMask(context, CGRectMake(0.0f, 0.0f, self.size.width, self.size.height), self.CGImage);
    [tintColor setFill];
    CGContextSetBlendMode(context, blendMode);
    CGContextFillRect(context, CGRectMake(0.0f, 0.0f, self.size.width, self.size.height));
    
    // Get image
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}


#pragma mark - Orientation

- (UIImage *)imageByIgnoringOrientation {
    
    UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
    
    [self drawInRect:CGRectMake(0.0f, 0.0f, self.size.width, self.size.height)];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (UIImage *)imageByFlippingHorizontally:(BOOL)flipHorizontal vertically:(BOOL)flipVertical {
    
    if (flipHorizontal || flipVertical) {
        
        UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        if (flipHorizontal) {
            if (flipVertical) {
                CGContextTranslateCTM(context, self.size.width, self.size.height);
                CGContextRotateCTM(context, M_PI);
            } else {
                CGContextTranslateCTM(context, self.size.width, 0.0f);
                CGContextScaleCTM(context, -1.0f, 1.0f);
            }
        } else {
            if (flipVertical) {
                CGContextTranslateCTM(context, 0.0f, self.size.height);
                CGContextScaleCTM(context, 1.0f, -1.0f);
            }
        }
        
        [self drawInRect:CGRectMake(0.0f, 0.0f, self.size.width, self.size.height)];
        
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return image;
        
    } else {
        return self;
    }
    
}

- (UIImage *)imageByRotatedHalvesOfPi:(int)numberHalvesOfPi {
    
    CGSize size = numberHalvesOfPi % 2 == 0 ? self.size : CGSizeMake(self.size.height, self.size.width);
    
    UIGraphicsBeginImageContextWithOptions(size, NO, self.scale);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, size.width/2.0f, size.height/2.0f);
    CGContextRotateCTM(context, M_PI_2 * numberHalvesOfPi);
    
    [self drawInRect:CGRectMake(-self.size.width/2.0f, -self.size.height/2.0f, self.size.width, self.size.height)];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
    
}


@end
