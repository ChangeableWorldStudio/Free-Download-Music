//
//  NABNetworkTwitterEngine.m
//  Manhattan
//
//  Created by Luong Ken on 14/1/12.
//  Copyright (c) 2012 Not A Basement Studio®. All rights reserved.
//

#import "NABNetworkTwitterEngine.h"
#import "NABNetworkOperation.h"

// Default twitter hostname and paths
#define TW_HOSTNAME @"api.twitter.com"
#define TW_REQUEST_TOKEN @"oauth/request_token"
#define TW_ACCESS_TOKEN @"oauth/access_token"
#define TW_STATUS_UPDATE @"1/statuses/update.json"

// URL to redirect the user for authentication
#define TW_AUTHORIZE(__TOKEN__) [NSString stringWithFormat:@"https://api.twitter.com/oauth/authorize?oauth_token=%@", __TOKEN__]

@interface NABNetworkTwitterEngine ()

- (void)removeOAuthTokenFromKeychain;
- (void)storeOAuthTokenInKeychain;
- (void)retrieveOAuthTokenFromKeychain;

@end

@implementation NABNetworkTwitterEngine
@synthesize delegate = _delegate;

#pragma mark - Read-only Properties

- (NSString *)screenName
{
    return _screenName;
}

#pragma mark - Initialization
- (id)initWithConsumerKey:(NSString *)consumerKey andConsumerSecret:(NSString *)consumerSecret andCallbackURL:(NSString *)callbackURL andDelegate:(id<NABNetworkTwitterEngineDelegate>)delegate {
    
    self = [super initWithHostName:TW_HOSTNAME
                customHeaderFields:nil
                   signatureMethod:NABNetworkKitOAuthHMAC_SHA1
                       consumerKey:consumerKey
                    consumerSecret:consumerSecret 
                       callbackURL:callbackURL];
    
    if (self) {
        _oAuthCompletionBlock = nil;
        _screenName = nil;
        self.delegate = delegate;
        
        // Retrieve OAuth access token (if previously stored)
        [self retrieveOAuthTokenFromKeychain];
    }
    
    return self;
}

#pragma mark - OAuth Access Token store/retrieve

- (void)removeOAuthTokenFromKeychain
{
    // Build the keychain query
    NSMutableDictionary *keychainQuery = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                          (__bridge_transfer NSString *)kSecClassGenericPassword, (__bridge_transfer NSString *)kSecClass,
                                          self.consumerKey, kSecAttrService,
                                          self.consumerKey, kSecAttrAccount,
                                          kCFBooleanTrue, kSecReturnAttributes,
                                          nil];
    
    // If there's a token stored for this user, delete it
    SecItemDelete((__bridge_retained CFDictionaryRef) keychainQuery);
}

- (void)storeOAuthTokenInKeychain
{
    // Build the keychain query
    NSMutableDictionary *keychainQuery = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                          (__bridge_transfer NSString *)kSecClassGenericPassword, (__bridge_transfer NSString *)kSecClass,
                                          self.consumerKey, kSecAttrService,
                                          self.consumerKey, kSecAttrAccount,
                                          kCFBooleanTrue, kSecReturnAttributes,
                                          nil];
    
    CFTypeRef resData = NULL;
    
    // If there's a token stored for this user, delete it first
    SecItemDelete((__bridge_retained CFDictionaryRef) keychainQuery);
    
    // Build the token dictionary
    NSMutableDictionary *tokenDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                            self.token, @"oauth_token",
                                            self.tokenSecret, @"oauth_token_secret",
                                            self.screenName, @"screen_name",
                                            nil];
    
    // Add the token dictionary to the query
    [keychainQuery setObject:[NSKeyedArchiver archivedDataWithRootObject:tokenDictionary] 
                      forKey:(__bridge_transfer NSString *)kSecValueData];
    
    // Add the token data to the keychain
    // Even if we never use resData, replacing with NULL in the call throws EXC_BAD_ACCESS
    SecItemAdd((__bridge_retained CFDictionaryRef)keychainQuery, (CFTypeRef *) &resData);
}

- (void)retrieveOAuthTokenFromKeychain
{
    // Build the keychain query
    NSMutableDictionary *keychainQuery = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                          (__bridge_transfer NSString *)kSecClassGenericPassword, (__bridge_transfer NSString *)kSecClass,
                                          self.consumerKey, kSecAttrService,
                                          self.consumerKey, kSecAttrAccount,
                                          kCFBooleanTrue, kSecReturnData,
                                          kSecMatchLimitOne, kSecMatchLimit,
                                          nil];
    
    // Get the token data from the keychain
    CFTypeRef resData = NULL;
    
    // Get the token dictionary from the keychain
    if (SecItemCopyMatching((__bridge_retained CFDictionaryRef) keychainQuery, (CFTypeRef *) &resData) == noErr)
    {
        NSData *resultData = (__bridge_transfer NSData *)resData;
        
        if (resultData)
        {
            NSMutableDictionary *tokenDictionary = [NSKeyedUnarchiver unarchiveObjectWithData:resultData];
            
            if (tokenDictionary) {
                [self setAccessToken:[tokenDictionary objectForKey:@"oauth_token"]
                              secret:[tokenDictionary objectForKey:@"oauth_token_secret"]];
                
                _screenName = [tokenDictionary objectForKey:@"screen_name"];
            }
        }
    }
}

#pragma mark - OAuth Authentication Flow

- (void)authenticateWithCompletionBlock:(NABNetworkTwitterEngineCompletionBlock)completionBlock {
    // Store the Completion Block to call after Authenticated
    _oAuthCompletionBlock = [completionBlock copy];
    
    // First we reset the OAuth token, so we won't send previous tokens in the request
    [self resetOAuthToken];
    
    // OAuth Step 1 - Obtain a request token
    NABNetworkOperation *op = [self operationWithPath:TW_REQUEST_TOKEN
                                              params:nil
                                          httpMethod:@"POST"
                                                 ssl:YES];
    
    [op onCompletion:^(NABNetworkOperation *completedOperation)
     {
         // Fill the request token with the returned data
         [self fillTokenWithResponseBody:[completedOperation responseString] type:NABNetworkKitOAuthRequestToken];
         
         // OAuth Step 2 - Redirect user to authorization page
         [self.delegate twitterEngine:self statusUpdate:@"Waiting for user authorization..."];
         NSURL *url = [NSURL URLWithString:TW_AUTHORIZE(self.token)];
         
         [self.delegate twitterEngine:self needsToOpenURL:url];
     } 
             onError:^(NSError *error)
     {
         completionBlock(error);
         _oAuthCompletionBlock = nil;
     }];
    
    [self.delegate twitterEngine:self statusUpdate:@"Requesting Tokens..."];
    [self enqueueSignedOperation:op];
}

- (void)resumeAuthenticationFlowWithURL:(NSURL *)url
{
    // Fill the request token with data returned in the callback URL
    [self fillTokenWithResponseBody:url.query type:NABNetworkKitOAuthRequestToken];
    
    // OAuth Step 3 - Exchange the request token with an access token
    NABNetworkOperation *op = [self operationWithPath:TW_ACCESS_TOKEN
                                              params:nil
                                          httpMethod:@"POST"
                                                 ssl:YES];
    [op onCompletion:^(NABNetworkOperation *completedOperation) {
        // Fill the access token with the returned data
        [self fillTokenWithResponseBody:[completedOperation responseString] type:NABNetworkKitOAuthAccessToken];
        
        // Retrieve the user's screen name
        _screenName = [self customValueForKey:@"screen_name"];
        
        // Store the OAuth access token
        [self storeOAuthTokenInKeychain];
        
        // Finished, return to previous method
        if (_oAuthCompletionBlock) _oAuthCompletionBlock(nil);
        _oAuthCompletionBlock = nil;
    } onError:^(NSError *error) {
        if (_oAuthCompletionBlock) _oAuthCompletionBlock(error);
        _oAuthCompletionBlock = nil;
    }];
    
    [self.delegate twitterEngine:self statusUpdate:@"Authenticating..."];
    [self enqueueSignedOperation:op];
}

- (void)cancelAuthentication
{
    NSDictionary *ui = [NSDictionary dictionaryWithObjectsAndKeys:@"Authentication cancelled.", NSLocalizedDescriptionKey, nil];
    NSError *error = [NSError errorWithDomain:@"com.sharpcube.RSTwitterEngine.ErrorDomain" code:401 userInfo:ui];
    
    if (_oAuthCompletionBlock) _oAuthCompletionBlock(error);
    _oAuthCompletionBlock = nil;
}

- (void)forgetStoredToken
{
    [self removeOAuthTokenFromKeychain];
    
    [self resetOAuthToken];
    _screenName = nil;
}

#pragma mark - Public Methods

- (void)sendTweet:(NSString *)tweet withCompletionBlock:(NABNetworkTwitterEngineCompletionBlock)completionBlock
{
    if (!self.isAuthenticated) {
        [self authenticateWithCompletionBlock:^(NSError *error) {
            if (error) {
                // Authentication failed, return the error
                completionBlock(error);
            } else {
                // Authentication succeeded, call this method again
                [self sendTweet:tweet withCompletionBlock:completionBlock];
            }
        }];
        
        // This method will be called again once the authentication completes
        return;
    }
    
    // Fill the post body with the tweet
    NSMutableDictionary *postParams = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       tweet, @"status",
                                       nil];
    
    // If the user marks the option "HTTPS Only" in his/her profile,
    // Twitter will fail all non-auth requests that use only HTTP
    // with a misleading "OAuth error". I guess it's a bug.
    NABNetworkOperation *op = [self operationWithPath:TW_STATUS_UPDATE 
                                              params:postParams
                                          httpMethod:@"POST"
                                                 ssl:YES];
    
    [op onCompletion:^(NABNetworkOperation *completedOperation) {
        completionBlock(nil);
    } onError:^(NSError *error) {
        completionBlock(error);
    }];
    

    
    [self.delegate twitterEngine:self statusUpdate:@"Sending tweet..."];
    [self enqueueSignedOperation:op];    
}

@end
