//
//  NABNetworkTwitterEngine.h
//  Manhattan
//
//  Created by Luong Ken on 14/1/12.
//  Copyright (c) 2012 Not A Basement Studio®. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NABNetworkOAuthEngine.h"

@protocol NABNetworkTwitterEngineDelegate;

typedef void (^NABNetworkTwitterEngineCompletionBlock)(NSError *error);

@interface NABNetworkTwitterEngine : NABNetworkOAuthEngine {
    NABNetworkTwitterEngineCompletionBlock _oAuthCompletionBlock;
    NSString *_screenName;
}

@property (assign) id <NABNetworkTwitterEngineDelegate> delegate;
@property (readonly) NSString *screenName;


- (id)initWithConsumerKey:(NSString *)consumerKey andConsumerSecret:(NSString *)consumerSecret andCallbackURL:(NSString *)callbackURL andDelegate:(id <NABNetworkTwitterEngineDelegate>)delegate;
- (void)authenticateWithCompletionBlock:(NABNetworkTwitterEngineCompletionBlock)completionBlock;
- (void)resumeAuthenticationFlowWithURL:(NSURL *)url;
- (void)cancelAuthentication;
- (void)forgetStoredToken;
- (void)sendTweet:(NSString *)tweet withCompletionBlock:(NABNetworkTwitterEngineCompletionBlock)completionBlock;

@end

@protocol NABNetworkTwitterEngineDelegate <NSObject>

@optional
- (void)twitterEngine:(NABNetworkTwitterEngine *)engine needsToOpenURL:(NSURL *)url;
- (void)twitterEngine:(NABNetworkTwitterEngine *)engine statusUpdate:(NSString *)message;

@end