//
//  NABSoundManager.h
//  Manhattan
//
//  Created by Khoa Nguyen Thanh on 2/8/12.
//  Copyright (c) 2012 Not A Basement Studio®. All rights reserved.
//

#import <AudioToolbox/AudioToolbox.h>

@interface NABSoundManager : NSObject

@property (nonatomic)       BOOL    enabled;

+ (NABSoundManager *)sharedManager;

// For sound effects: short sounds, high performance, low overhead
- (void)playSoundAtURL:(NSURL *)url;
- (void)playSoundAtPath:(NSString *)path;
- (void)playSoundRandomlyFromPaths:(NSArray *)paths;

@end
