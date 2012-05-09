//
//  NABAsyncFileDeleter.h
//  Manga Rock 2
//
//  Created by Luong Ken on 23/3/12.
//  Copyright (c) 2012 Not A Basement Studio®. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NABAsyncFileDeleter : NSObject
+ (NABAsyncFileDeleter *)sharedDeleter;

- (void)waitUntilFinished;
- (void)removeItemAtPath:(NSString *)path;
- (void)removeItemAtURL:(NSURL *)URL;
@end
