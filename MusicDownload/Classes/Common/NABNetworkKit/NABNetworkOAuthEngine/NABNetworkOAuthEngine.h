//
//  NABNetworkOAuthEngine.h
//  Manhattan
//
//  Created by Luong Ken on 14/1/12.
//  Copyright (c) 2012 Not A Basement Studio®. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NABNetworkEngine.h"

typedef enum NABNetworkKitOAuthTokenType {
    NABNetworkKitOAuthRequestToken,
    NABNetworkKitOAuthAccessToken,
}
NABNetworkKitOAuthTokenType;

typedef enum NABNetworkKitOAuthSignatureMethod {
    NABNetworkKitOAuthPlainText,
    NABNetworkKitOAuthHMAC_SHA1,
} NABNetworkKitOAuthSignatureMethod;

@interface NABNetworkOAuthEngine : NABNetworkEngine {
@private
    NABNetworkKitOAuthTokenType _tokenType;
    NABNetworkKitOAuthSignatureMethod _signatureMethod;
    NSString *_consumerSecret;
    NSString *_tokenSecret;
    NSString *_callbackURL;
    NSString *_verifier;
    NSMutableDictionary *_oAuthValues;
    NSMutableDictionary *_customValues;

}

@property (readonly) NABNetworkKitOAuthTokenType tokenType;
@property (readonly) NABNetworkKitOAuthSignatureMethod signatureMethod;
@property (readonly) NSString *consumerKey;
@property (readonly) NSString *consumerSecret;
@property (readonly) NSString *callbackURL;
@property (readonly) NSString *token;
@property (readonly) NSString *tokenSecret;
@property (readonly) NSString *verifier;

- (id)initWithHostName:(NSString *)hostName 
    customHeaderFields:(NSDictionary *)headers
       signatureMethod:(NABNetworkKitOAuthSignatureMethod)signatureMethod
           consumerKey:(NSString *)consumerKey
        consumerSecret:(NSString *)consumerSecret
           callbackURL:(NSString *)callbackURL;

- (id)initWithHostName:(NSString *)hostName
    customHeaderFields:(NSDictionary *)headers
       signatureMethod:(NABNetworkKitOAuthSignatureMethod)signatureMethod
           consumerKey:(NSString *)consumerKey
        consumerSecret:(NSString *)consumerSecret;

- (BOOL)isAuthenticated;
- (void)resetOAuthToken;
- (NSString *)customValueForKey:(NSString *)key;
- (void)fillTokenWithResponseBody:(NSString *)body type:(NABNetworkKitOAuthTokenType)tokenType;
- (void)setAccessToken:(NSString *)token secret:(NSString *)tokenSecret;
- (void)signRequest:(NABNetworkOperation *)request;
- (void)enqueueSignedOperation:(NABNetworkOperation *)op;
@end
