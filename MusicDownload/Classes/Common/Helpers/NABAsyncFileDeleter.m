//
//  NABAsyncFileDeleter.m
//  Manga Rock 2
//
//  Created by Luong Ken on 23/3/12.
//  Copyright (c) 2012 Not A Basement Studio®. All rights reserved.
//

#import "NABAsyncFileDeleter.h"
#import "NSFileManager+NAB.h"
// private utilites
@interface NABAsyncFileDeleter ()
- (BOOL)supportsTaskCompletion;
@end

@implementation NABAsyncFileDeleter

static dispatch_queue_t _delQueue;
static dispatch_group_t _delGroup;
static dispatch_once_t onceToken;

static dispatch_queue_t _renameQueue;

#pragma mark - Singleton
+ (NABAsyncFileDeleter *)sharedDeleter {
    
    static NABAsyncFileDeleter *sharedDeleter;
    static dispatch_once_t done;
    
    dispatch_once(&done, ^{
        sharedDeleter = [[NABAsyncFileDeleter alloc] init];
    });
    
    return sharedDeleter;
}

- (id)init {
	self = [super init];
	if (self) {
		dispatch_once(&onceToken, ^{
			_delQueue = dispatch_queue_create("NABAsyncFileDeleterRemoveQueue", 0);
			_delGroup = dispatch_group_create();
			_renameQueue = dispatch_queue_create("NABAsyncFileDeleterRenameQueue", 0);
		});
	}
    
	return self;
}

- (void)waitUntilFinished {
    dispatch_group_wait(_delGroup, DISPATCH_TIME_FOREVER);
}

- (void)removeItemAtPath:(NSString *)path {
    // make a unique temporary name in tmp folder
	NSString *tmpPath = [NSFileManager NABPathForTemporaryFile];
    
	// rename the file, waiting for the rename to finish before async deletion
	dispatch_sync(_renameQueue, ^{
		NSFileManager *fileManager = [[NSFileManager alloc] init];
        
		if ([fileManager moveItemAtPath:path toPath:tmpPath error:NULL]) {
			// schedule the removal and immediately return	
			dispatch_group_async(_delGroup, _delQueue, ^{
				__block UIBackgroundTaskIdentifier backgroundTaskID = UIBackgroundTaskInvalid;
                
				// block to use for timeout as well as completed task
				void (^completionBlock)() = ^{
					[[UIApplication sharedApplication] endBackgroundTask:backgroundTaskID];
					backgroundTaskID = UIBackgroundTaskInvalid;
				};
                
				if ([self supportsTaskCompletion]) {
					// according to docs this is safe to be called from background threads
					backgroundTaskID = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:completionBlock];
				}
                
				// file manager is not used any more in the rename queue, so we reuse it
				[fileManager removeItemAtPath:tmpPath error:NULL];
                
				// ... when the task completes:
				if (backgroundTaskID != UIBackgroundTaskInvalid) {
					completionBlock();		
				}
			});
		}
	});	
}

- (void)removeItemAtURL:(NSURL *)URL {
    NSAssert([URL isFileURL], @"Parameter URL must be a file URL");
    [self removeItemAtPath:[URL path]];
}

- (BOOL)supportsTaskCompletion {
	UIDevice *device = [UIDevice currentDevice];
    
	if ([device respondsToSelector:@selector(isMultitaskingSupported)]) {
		if (device.multitaskingSupported) {
			return YES;
		}
		else {
			return NO;
		}
	}
    
	return NO;
}

@end
