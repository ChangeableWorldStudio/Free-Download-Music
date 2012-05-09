//
//  NSFileManager+NAB.h
//  Manga Rock 2
//
//  Created by Luong Ken on 2/22/12.
//  Copyright (c) 2012 Not A Basement Studio®. All rights reserved.

//  Should use this category to ensure optimal performance when look up for app path
//  Most of the code in this file are adpated from Cocoanetics/DTFoundation
//  Github: https://github.com/Cocoanetics/DTFoundation

#import <Foundation/Foundation.h>

@interface NSFileManager(NAB)

+ (NSString *)NABApplicationCachesPath;
+ (NSString *)NABApplicationDocumentsPath;

//utility method to generate a unique file path (including name) everytime the method is called
+ (NSString *)NABPathForTemporaryFile; 
@end
