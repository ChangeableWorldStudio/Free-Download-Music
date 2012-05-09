//
//  NABProjectPrefix.h
//
//  Created by Nguyen Thanh Khoa on 22/8/11.
//  Copyright (c) 2011 Not A Basement Studio®. All rights reserved.
//
//
//
// How to use:
//
// 1. Import this file in "Reference" mode (by not ticking on "Copy...")
//
// 2. Add these lines at the top of your own project prefix file (Ex. ComicExpress-Prefix.pch)
//
//    #define UIAppDelegate ((YourAppDelegateClass *)[UIApplication sharedApplication].delegate)
//
// 3. Follow this format for importing NAB libraries inside the "#ifdef __OBJC__" of your own project prefix file
//
//        #ifdef __OBJC__
//            // Apple's
//            #import <UIKit/UIKit.h>
//            #import <MessageUI/MessageUI.h>
//            #import <AVFoundation/AVFoundation.h>
//            #import <QuartzCore/QuartzCore.h>
//            #import <CoreGraphics/CoreGraphics.h>
//            #import <Foundation/Foundation.h>
//            #import <MobileCoreServices/MobileCoreServices.h>
//            #import <AssetsLibrary/AssetsLibrary.h>
//
//            // Others'
//            #import "CodeTimestamps.h"
//
//            // NAB's Preffix
//            #import "NABProjectPrefix.h"
//
//            // NAB's Extras
//            #import "UIView+NAB.h"
//            #import "UIImage+NAB.h"
//            #import "UIColor+NAB.h"
//            #import "UIScrollView+NAB.h"
//            #import "CALayer+NAB.h"
//            #import "NSDate+NAB.h"
//            #import "ALAsset+Extra.h"
//
//            // NAB's
//            #import <NABFacebook/FBConnect.h>
//            #import "NABNetworkKit.h"
//            #import "NABSoundManager.h"
//            #import "NABMath.h"
//
//            // Project's
//            #import "MHTAppDelegate.h"
//            #import "MHTAppSettings.h"
//            #import "MHTDataObject.h"
//        #endif
//
// 4. If using NABMagicalRecord
//
//    Add "-Wno-arc-performSelector-leaks" to "Other linker Flags"
//
//    #define NAB_PROJECT_PERSISTENT_STORE @"YourProjectCoreDataStore.sqlite"
//    #define MR_SHORTHAND
//    ...
//
//    #ifdef __OBJC__
//        #import "CoreData+MagicalRecord.h"
//    ...
//


#define DEVICE_IS_PHONE ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)

#define DEVICE_IS_IOS_5 ([[[UIDevice currentDevice] systemVersion] compare:@"5.0" options:NSNumericSearch] != NSOrderedAscending)

#define DIRECTORY_DOCUMENT ([NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0])


#ifdef DEBUG

#define ENABLE_UIKIT_LOG YES
#define ENABLE_CORE_DATA_LOG YES
#define ENABLE_CORE_ANIMATION_LOG YES
#define ENABLE_GESTURES_LOG YES

#define DLog(...) NSLog(@"%s [Line %d] %@", __PRETTY_FUNCTION__, __LINE__, [NSString stringWithFormat:__VA_ARGS__])
#define ALog(...) [[NSAssertionHandler currentHandler] handleFailureInFunction:[NSString stringWithCString:__PRETTY_FUNCTION__ encoding:NSUTF8StringEncoding] file:[NSString stringWithCString:__FILE__ encoding:NSUTF8StringEncoding] lineNumber:__LINE__ description:[NSString stringWithFormat:__VA_ARGS__]]

#else

#define DLog(...)
#define ALog(...) NSLog(@"%s [Line %d] %@", __PRETTY_FUNCTION__, __LINE__, [NSString stringWithFormat:__VA_ARGS__])

#endif


#ifdef ENABLE_UIKIT_LOG
#define DLogFrame(...) NSLog(@"%s [Line %d] (%f, %f, %f, %f)", __PRETTY_FUNCTION__, __LINE__, __VA_ARGS__.origin.x, __VA_ARGS__.origin.y, __VA_ARGS__.size.width, __VA_ARGS__.size.height)
#define DLogPoint(...) NSLog(@"%s [Line %d] (%f, %f)", __PRETTY_FUNCTION__, __LINE__, __VA_ARGS__.x, __VA_ARGS__.y)
#define DLogSize(...) NSLog(@"%s [Line %d] (%f, %f)", __PRETTY_FUNCTION__, __LINE__, __VA_ARGS__.width, __VA_ARGS__.height)
#define DLogUIKit(...) NSLog(@"%s [Line %d] %@", __PRETTY_FUNCTION__, __LINE__, [NSString stringWithFormat:__VA_ARGS__])
#else
#define DLogFrame(...)
#define DLogPoint(...)
#define DLogSize(...)
#define DLogUIKit(...)
#endif


#ifdef ENABLE_CORE_DATA_LOG
#define DLogCoreData(...) NSLog(@"%s [Line %d] %@", __PRETTY_FUNCTION__, __LINE__, [NSString stringWithFormat:__VA_ARGS__])
#else
#define DLogCoreData(...)
#endif


#ifdef ENABLE_CORE_ANIMATION_LOG
#define DLogCoreAnimation(...) NSLog(@"%s [Line %d] %@", __PRETTY_FUNCTION__, __LINE__, [NSString stringWithFormat:__VA_ARGS__])
#else
#define DLogCoreAnimation(...)
#endif


#ifdef ENABLE_GESTURES_LOG
#define DLogGesture(...) NSLog(@"%s [Line %d] %@", __PRETTY_FUNCTION__, __LINE__, [NSString stringWithFormat:__VA_ARGS__])
#else
#define DLogGesture(...)
#endif


void DLogOrientation(int orientation);