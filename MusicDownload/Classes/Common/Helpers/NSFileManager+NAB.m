//
//  NSFileManager+NAB.m
//  Manga Rock 2
//
//  Created by Luong Ken on 2/22/12.
//  Copyright (c) 2012 Not A Basement Studio®. All rights reserved.
//

#import "NSFileManager+NAB.h"

@implementation NSFileManager(NAB)

+ (NSString *)NABApplicationCachesPath {
    static dispatch_once_t onceToken;
	static NSString *cachedPath;
    
	dispatch_once(&onceToken, ^{
		cachedPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];	
	});
    
	return cachedPath;
}

+ (NSString *)NABApplicationDocumentsPath {
    static dispatch_once_t onceToken;
	static NSString *documentPath;
    
	dispatch_once(&onceToken, ^{
		documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];	
	});
    
	return documentPath;
}

+ (NSString *)NABPathForTemporaryFile { 
	CFUUIDRef newUniqueId = CFUUIDCreate(kCFAllocatorDefault);
	CFStringRef newUniqueIdString = CFUUIDCreateString(kCFAllocatorDefault, newUniqueId);
    
	NSString *tmpPath = [[NSFileManager NABApplicationCachesPath] stringByAppendingPathComponent:(__bridge NSString *)newUniqueIdString];
	CFRelease(newUniqueId);
	CFRelease(newUniqueIdString);
    
	return tmpPath;
}
@end
