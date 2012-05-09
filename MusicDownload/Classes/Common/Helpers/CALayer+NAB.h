//
//  CALayer+NAB.h
//  Manhattan
//
//  Created by Khoa Nguyen Thanh on 2/10/12.
//  Copyright (c) 2012 Not A Basement Studio®. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface CALayer(NAB)

+ (CALayer *)layerMaskWithMaskFrame:(CGRect)maskFrame inFullSize:(CGSize)fullSize;

@end
