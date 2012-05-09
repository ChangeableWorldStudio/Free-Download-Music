//
//  UIViewController+NABEmailSupport.h
//  Manhattan
//
//  Created by NAB NAB on 1/9/12.
//  Copyright (c) 2012 Not A Basement Studio®. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIViewController(CWEmailSupport)

- (void)displaySupportComposerSheetForAppname:(NSString *)appName delegate:(id)delegate;
- (void)displaySupportComposerSheetForAppname:(NSString *)appName;
- (void)displayShareMailComposerSheetForAppname:(NSString *)appName;


@end
