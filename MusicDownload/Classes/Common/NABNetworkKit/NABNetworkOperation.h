//
//  NABNetworkOperation.h
//  NABNetworkKit
//
//  Created by Phan Tran Le Nguyen on 12/11/11.
//  Copyright (c) 2011 Not A Basement Studio®. All rights reserved.
//

#import <Foundation/Foundation.h>
@class NABNetworkOperation;

typedef enum {
    NABNetworkOperationStateReady = 1,
    NABNetworkOperationStateExecuting = 2,
    NABNetworkOperationStateFinished = 3
} NABNetworkOperationState;

typedef void (^NABNetworkProgressBlock)(double progress);
typedef void (^NABNetworkResponseBlock)(NABNetworkOperation *completedOperation);
typedef void (^NABNetworkImageBlock)(UIImage *image, NSURL *url, BOOL isInCache);
typedef void (^NABNetworkErrorBlock)(NSError *error);
typedef void (^NABNKAuthBlock)(NSURLAuthenticationChallenge* challenge);;
typedef NSString *(^NABNetworkEncodingBlock) (NSDictionary *postDataDict);

typedef enum {
    NABNetworkPostDataEncodingTypeURL = 0, // default
    NABNetworkPostDataEncodingTypeJSON,
    NABNetworkPostDataEncodingTypePlist,
} NABNetworkPostDataEncodingType;

@interface NABNetworkOperation : NSOperation <NSCoding, NSCopying, NSURLConnectionDelegate, NSURLConnectionDataDelegate, NSURLConnectionDownloadDelegate> {
  @private
    int _state;
    BOOL _freezable;
}

@property (nonatomic,           readonly, getter = url  )   NSString *url;
@property (nonatomic, strong,   readonly)                   NSURLRequest *readonlyRequest;
@property (nonatomic, strong,   readonly)                   NSHTTPURLResponse *readonlyResponse;
@property (nonatomic, strong,   readonly)                   NSDictionary *readonlyPostDictionary;
@property (nonatomic, strong,   readonly)                   NSString *HTTPMethod;
@property (nonatomic, assign,   readonly)                   NSInteger HTTPStatusCode;
@property (nonatomic, assign)                               NABNetworkPostDataEncodingType postDataEncoding;
@property (nonatomic, assign)                               NSStringEncoding stringEncoding;
@property (nonatomic, assign)                               BOOL freezable;
@property (nonatomic, strong,   readonly)                   NSError *error;
@property (nonatomic, strong)                               NSMutableDictionary *cacheHeaders;
@property (nonatomic, strong)                               NSString *clientCertificate;
@property (nonatomic, copy)                                 NABNKAuthBlock authHandler;
@property (nonatomic, copy)     void                        (^operationStateChangedHandler)(NABNetworkOperationState newState);
@property (nonatomic, assign)                               NSURLCredentialPersistence credentialPersistence;
@property (nonatomic, strong)                               UILocalNotification *localNotification;
@property (nonatomic, assign)                               BOOL shouldShowLocalNotificationOnError;

- (void)addHeaders:(NSDictionary *)headersDictionary;

//  NOTICE: these methods will convert the HTTP request to POST + set post format to multipart/form-data

- (void)addFile:(NSString *)filePath forKey:(NSString *)key;
- (void)addFile:(NSString *)filePath forKey:(NSString *)key mimeType:(NSString *)mimeType;
- (void)addData:(NSData *)data       forKey:(NSString *)key;
- (void)addData:(NSData *)data       forKey:(NSString *)key mimeType:(NSString *)mimeType;

//  END of NOTICE

- (void)onCompletion:(NABNetworkResponseBlock)response onError:(NABNetworkErrorBlock)error;
- (void)onUploadProgressChanged:(NABNetworkProgressBlock)uploadProgressBlock;
- (void)onDownloadProgressChanged:(NABNetworkProgressBlock)downloadProgressBlock;

- (void)setCustomPostDataEncodingHandler:(NABNetworkEncodingBlock)postDataEncodingHandler forType:(NSString *)contentType;
- (void)setUsername:(NSString *)name password:(NSString *)password;
- (void)setUsername:(NSString *)username password:(NSString *)password basicAuth:(BOOL)bYesOrNo;

//- (void)setUploadStream:(NSInputStream *)inputStream;
- (void)addDownloadStream:(NSOutputStream *)outputStream;
- (BOOL)isCachedResponse;

// NOTICE: these methods are to accessing the downloaded data. If operation is still processing, to access partial data uses a downloadStream (using setDownloadSteam: method above)

- (NSData *)responseData;
- (NSString *)responseString;// the method convert responseData to string using 'stringEncoding' attribute
- (NSString *)responseStringWithEncoding:(NSStringEncoding)endcoding;// the method convert responseData to string using 'encoding' parameter
- (UIImage *)responseImage;

//  END of NOTICE

#ifdef __IPHONE_5_0
- (id)responseJSON;// NSDictionary or NSArray. Return nil if operation is in progress or response is not a valid JSON
#endif

// override these methods to add more business rule
- (void)operationSucceeded;
- (void)operationFailedWithError:(NSError *)error;

- (NSString *)curlCommandLineString;

@end
