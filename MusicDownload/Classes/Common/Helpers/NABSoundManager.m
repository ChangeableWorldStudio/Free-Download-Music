//
//  NABSoundManager.m
//  Manhattan
//
//  Created by Khoa Nguyen Thanh on 2/8/12.
//  Copyright (c) 2012 Not A Basement Studio®. All rights reserved.
//

#import "NABSoundManager.h"
#include <stdlib.h>


@interface NABSoundManager()

// For sound effects
@property (nonatomic)   SystemSoundID   soundID;

@end


@implementation NABSoundManager

@synthesize enabled = _enabled;
@synthesize soundID = _soundID;


#pragma mark - Singleton

+ (NABSoundManager *)sharedManager {
    static NABSoundManager *sharedManager;
    static dispatch_once_t done;
    
    dispatch_once(&done, ^{
        sharedManager = [[NABSoundManager alloc] init];
        sharedManager.enabled = YES;
    });
    
    return sharedManager;
}


#pragma mark - Memory Management

- (void)dealloc {
    AudioServicesDisposeSystemSoundID(_soundID);
}


#pragma mark - Sound effects (Short sounds)

- (void)playSoundAtURL:(NSURL *)url {
    if (_enabled) {
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)url, &_soundID);
        AudioServicesPlaySystemSound(_soundID);
    }
}

- (void)playSoundAtPath:(NSString *)path {
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSURL *url = [NSURL fileURLWithPath:path];
        [self playSoundAtURL:url];
    }
}

- (void)playSoundRandomlyFromPaths:(NSArray *)paths {
    if (paths) {
        int random = arc4random_uniform([paths count]);
        [self playSoundAtPath:[paths objectAtIndex:random]];
    }
}


@end
