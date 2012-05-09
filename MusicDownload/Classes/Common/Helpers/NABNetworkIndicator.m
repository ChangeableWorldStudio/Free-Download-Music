//
//  NABNetworkIndicator.m
//  KBFlickr
//
//  Created by tkhoa87 on 27/11/11.
//  Copyright (c) 2011 Not A Basement Studio®. All rights reserved.
//

#import "NABNetworkIndicator.h"

@implementation NABNetworkIndicator

int NABNetworkIndicatorRetainCount = 0;

+ (void)retainIndicator {
    if (NABNetworkIndicatorRetainCount == 0) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    }
    NABNetworkIndicatorRetainCount++;
}

+ (void)releaseIndicator {
    NABNetworkIndicatorRetainCount--;
    if (NABNetworkIndicatorRetainCount < 0) {
        NABNetworkIndicatorRetainCount = 0;
    }
    
    if (NABNetworkIndicatorRetainCount == 0) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }
}

@end
