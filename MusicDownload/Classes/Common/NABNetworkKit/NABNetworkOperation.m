//
//  NABNetworkOperation.m
//  NABNetworkKit
//
//  Created by Phan Tran Le Nguyen on 12/11/11.
//  Copyright (c) 2011 Not A Basement Studio®. All rights reserved.
//  Inspired by MKNetworkKit

#import "NABNetworkOperation.h"
#import "NSDictionary+RequestEncoding.h"
#import "NSString+MKNetworkKitAdditions.h"
#import "NSDate+RFC1123.h"
#import "NSData+Base64.h"

#define kNABNetworkKitDefaultCacheDuration 60 // 1 minute
#define kNABNetworkKitDefaultImageHeadRequestDuration 3600*24*1 // 1 day (HEAD requests with eTag are sent only after expiry of this. Not that these are not RFC compliant, but needed for performance tuning)
#define kNABNetworkKitDefaultImageCacheDuration 3600*24*7 // 1 day

@interface NABNetworkOperation()

@property (nonatomic, strong) NSURLConnection               *connection;
@property (nonatomic, strong) NSString                      *uniqueID;
@property (nonatomic, strong) NSMutableURLRequest           *request;
@property (nonatomic, strong) NSHTTPURLResponse             *response;

@property (nonatomic, strong) NSMutableDictionary           *fieldToBePosted;
@property (nonatomic, strong) NSMutableArray                *filesToBePosted;
@property (nonatomic, strong) NSMutableArray                *dataToBePosted;

@property (nonatomic, strong) NSString                      *username;
@property (nonatomic, strong) NSString                      *password;

@property (nonatomic, strong) NSMutableArray                *responseBlocks;
@property (nonatomic, strong) NSMutableArray                *errorBlocks;

@property (nonatomic        ) NABNetworkOperationState      state;
@property (nonatomic        ) BOOL                          isCancelled;

@property (nonatomic, strong) NSMutableData                 *mutableData;

@property (nonatomic, strong) NSMutableArray                *uploadProgressChangedHandlers;
@property (nonatomic, strong) NSMutableArray                *downloadProgressChangedHandlers;
@property (nonatomic, copy  ) NABNetworkEncodingBlock       postDataEncodingHandler;

@property (nonatomic, assign) int                           startPosition;

@property (nonatomic, strong) NSMutableArray                *downloadStreams;
@property (nonatomic, strong) NSData                        *cachedResponse;
@property (nonatomic, copy  ) NABNetworkResponseBlock       cacheHandlingBlock;
@property (nonatomic, assign) UIBackgroundTaskIdentifier    backgroundTaskID;

@property (nonatomic, strong) NSError                       *error;

- (NSData *)bodyData;
- (BOOL)isCacheble;
- (NSString *)encodedPostDataString;

- (NSString *)uniqueIdentifier;
- (void)setCachedData:(NSData *)cachedData;
- (void)setCacheHandler:(NABNetworkResponseBlock)cacheHandler;
- (void)updateHandlersFromOperation:(NABNetworkOperation *)operation;
- (void)updateOperationBasedOnPreviousHeaders:(NSMutableDictionary *)headers;

- (id)initWithURLString:(NSString *)aURLString params:(NSMutableDictionary *)body httpMethod:(NSString *)method;

@end

@implementation NABNetworkOperation

@synthesize postDataEncoding                = _postDataEncoding;
@synthesize postDataEncodingHandler         = _postDataEncodingHandler;

@synthesize stringEncoding                  = _stringEncoding;
@synthesize freezable                       = _freezable;
@synthesize uniqueID                        = _uniqueID;

@synthesize connection                      = _connection;

@synthesize request                         = _request;
@synthesize response                        = _response;

@synthesize fieldToBePosted                 = _fieldToBePosted;
@synthesize filesToBePosted                 = _filesToBePosted;
@synthesize dataToBePosted                  = _dataToBePosted;

@synthesize responseBlocks                  = _responseBlocks;
@synthesize errorBlocks                     = _errorBlocks;

@synthesize isCancelled                     = _isCancelled;
@synthesize mutableData                     = _mutableData;
 
@synthesize uploadProgressChangedHandlers    = _uploadProgressChangedHandlers;
@synthesize downloadProgressChangedHandlers  = _downloadProgressChangedHandlers;

@synthesize startPosition                   = _startPosition;

@synthesize downloadStreams                 = _downloadStreams;

@synthesize cachedResponse                  = _cachedResponse;
@synthesize cacheHandlingBlock              = _cacheHandlingBlock;

@synthesize backgroundTaskID                = _backgroundTaskID;

@synthesize cacheHeaders                    = _cacheHeaders;

@synthesize username                        = _username;
@synthesize password                        = _password;
@synthesize clientCertificate               = _clientCertificate;
@synthesize authHandler                     = _authHandler;
@synthesize credentialPersistence           = _credentialPersistence;

@synthesize operationStateChangedHandler    = _operationStateChangedHandler;
@synthesize localNotification               = _localNotification;
@synthesize shouldShowLocalNotificationOnError = _shouldShowLocalNotificationOnError;

@synthesize error                           = _error;


#pragma mark - init method

- (void)dealloc {
    [_connection cancel];
    _connection = nil;
}

- (id)initWithURLString:(NSString *)aURLString params:(NSMutableDictionary *)body httpMethod:(NSString *)method {
    self = [super init];
    
    if (self) {
        self.responseBlocks = [NSMutableArray array];
        self.errorBlocks = [NSMutableArray array];
        
        self.filesToBePosted = [NSMutableArray array];
        self.fieldToBePosted = [NSMutableDictionary dictionary];
        self.dataToBePosted = [NSMutableArray array];
        
        self.uploadProgressChangedHandlers = [NSMutableArray array];
        self.downloadProgressChangedHandlers = [NSMutableArray array];
        self.downloadStreams = [NSMutableArray array];
        
        NSURL *finalURL = nil;
        
        if (body) {
            self.fieldToBePosted = body;
        }
        
        self.stringEncoding = NSUTF8StringEncoding;
        
        if ([method isEqualToString:@"GET"]) {
            self.cacheHeaders = [NSMutableDictionary dictionary];
        }
        
        if (([method isEqualToString:@"GET"] || [method isEqualToString:@"DELETE"]) && (body && [body count] > 0)) {
            finalURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@?%@", aURLString, [self encodedPostDataString]]];
        } else {
            finalURL = [NSURL URLWithString:aURLString];
        }
        
        self.request = [NSMutableURLRequest requestWithURL:finalURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0f];
        
        [self.request setHTTPMethod:method];
        
        NSString *charSet = (__bridge NSString *)CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(self.stringEncoding));
        
        [self.request addValue:[NSString stringWithFormat:@"%@, en-us", [[NSLocale preferredLanguages] componentsJoinedByString:@", "]] forHTTPHeaderField:@"Accept-Language"];
        
        if (([method isEqualToString:@"POST"] || [method isEqualToString:@"PUT"]) && (body && [body count] > 0)) {
            switch (self.postDataEncoding) {
                    
                case NABNetworkPostDataEncodingTypeURL: {
                    [self.request addValue:
                     [NSString stringWithFormat:@"application/x-www-form-urlencoded; charset=%@", charSet]
                        forHTTPHeaderField:@"Content-Type"];
                }
                    break;
                case NABNetworkPostDataEncodingTypeJSON: {
                    if([NSJSONSerialization class]) {
                        [self.request addValue:
                         [NSString stringWithFormat:@"application/json; charset=%@", charSet]
                            forHTTPHeaderField:@"Content-Type"];
                    } else {
                        [self.request addValue:
                         [NSString stringWithFormat:@"application/x-www-form-urlencoded; charset=%@", charSet]
                            forHTTPHeaderField:@"Content-Type"];
                    }
                }
                    break;
                case NABNetworkPostDataEncodingTypePlist: {
                    [self.request addValue:
                     [NSString stringWithFormat:@"application/x-plist; charset=%@", charSet]
                        forHTTPHeaderField:@"Content-Type"];
                }
                    
                default:
                    break;
            }
        }
        
        self.state = NABNetworkOperationStateReady;
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeInteger:self.stringEncoding forKey:@"stringEncoding"];
    
    [encoder encodeObject:self.uniqueID forKey:@"uniqueId"];
    [encoder encodeObject:self.request forKey:@"request"];
    [encoder encodeObject:self.response forKey:@"response"];
    
    [encoder encodeObject:self.fieldToBePosted forKey:@"fieldsToBePosted"];
    [encoder encodeObject:self.filesToBePosted forKey:@"filesToBePosted"];
    [encoder encodeObject:self.dataToBePosted forKey:@"dataToBePosted"];
    
    self.state = NABNetworkOperationStateReady;
    [encoder encodeInt32:_state forKey:@"state"];
    [encoder encodeBool:self.isCancelled forKey:@"isCancelled"];
    [encoder encodeObject:self.mutableData forKey:@"mutableData"];
    
    [encoder encodeObject:self.downloadStreams forKey:@"downloadStreams"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        [self setStringEncoding:[decoder decodeIntegerForKey:@"stringEncoding"]];
        
        self.request = [decoder decodeObjectForKey:@"request"];
        self.uniqueID = [decoder decodeObjectForKey:@"uniqueId"];
        self.response = [decoder decodeObjectForKey:@"response"];
        
        self.fieldToBePosted = [decoder decodeObjectForKey:@"fieldsToBePosted"];
        self.filesToBePosted = [decoder decodeObjectForKey:@"filesToBePosted"];
        self.dataToBePosted = [decoder decodeObjectForKey:@"dataToBePosted"];
        
        [self setState:[decoder decodeInt32ForKey:@"state"]];
        
        self.isCancelled = [decoder decodeBoolForKey:@"isCancelled"];
        self.mutableData = [decoder decodeObjectForKey:@"mutableData"];
        
        self.downloadStreams = [decoder decodeObjectForKey:@"downloadStreams"];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    NABNetworkOperation *copy = [[[self class] allocWithZone:zone] init];
    
    [copy setStringEncoding:self.stringEncoding];
    [copy setUniqueID:[self.uniqueID copy]];
    
    [copy setConnection:[self.connection copy]];
    [copy setRequest:[self.request copy]];
    [copy setResponse:[self.response copy]];
    
    [copy setFieldToBePosted:[self.fieldToBePosted copy]];
    [copy setFilesToBePosted:[self.filesToBePosted copy]];
    [copy setDataToBePosted:[self.dataToBePosted copy]];
    
    [copy setResponseBlocks:[self.responseBlocks copy]];
    [copy setErrorBlocks:[self.errorBlocks copy]];
    
    [copy setState:self.state];
    
    [copy setIsCancelled:self.isCancelled];
    
    [copy setMutableData:[self.mutableData copy]];
    
    [copy setUploadProgressChangedHandlers:[self.uploadProgressChangedHandlers copy]];
    [copy setDownloadProgressChangedHandlers:[self.downloadProgressChangedHandlers copy]];
    [copy setDownloadStreams:[self.downloadStreams copy]];
    
    [copy setCachedResponse:[self.cachedResponse copy]];
    [copy setCacheHandlingBlock:self.cacheHandlingBlock];
    
    return copy;
}


#pragma mark - getters / settes

- (BOOL)isCacheble {
    return [_request.HTTPMethod isEqualToString:@"GET"];
}

- (NSString *)encodedPostDataString {
    
    NSString *returnValue = @"";
    if(self.postDataEncodingHandler)
        returnValue = self.postDataEncodingHandler(self.fieldToBePosted);    
    else if(self.postDataEncoding == NABNetworkPostDataEncodingTypeURL)
        returnValue = [self.fieldToBePosted urlEncodedKeyValueString];    
    else if(self.postDataEncoding == NABNetworkPostDataEncodingTypeJSON)
        returnValue = [self.fieldToBePosted jsonEncodedKeyValueString];
    else if(self.postDataEncoding == NABNetworkPostDataEncodingTypePlist)
        returnValue = [self.fieldToBePosted plistEncodedKeyValueString];
    return returnValue;
}

- (void)setCustomPostDataEncodingHandler:(NABNetworkEncodingBlock)postDataEncodingHandler forType:(NSString *)contentType {
    
    NSString *charset = (__bridge NSString *)CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(self.stringEncoding));
    
    self.postDataEncodingHandler = postDataEncodingHandler;
    [self.request addValue:
     [NSString stringWithFormat:@"%@; charset=%@", contentType, charset]
        forHTTPHeaderField:@"Content-Type"];
}

- (void)setUsername:(NSString *)name password:(NSString *)password {
    self.username = name;
    self.password = password;
}

- (void)setUsername:(NSString *)username password:(NSString *)password basicAuth:(BOOL)bYesOrNo {
    [self setUsername:username password:password];
    NSString *base64EncodedString = [[[NSString stringWithFormat:@"%@:%@", self.username, self.password] dataUsingEncoding:NSUTF8StringEncoding] base64EncodedString];
    
    [self addHeaders:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"Basic %@", base64EncodedString] forKey:@"Authorization"]];
}

- (BOOL)freezable {
    return _freezable;
}

- (NSString *)url {
    return [[_request URL] absoluteString];
}

- (NSURLRequest *)readonlyRequest {
    return self.request;
}

- (NSDictionary *)readonlyPostDictionary {
    return [self.fieldToBePosted copy];
}

- (NSHTTPURLResponse *)readonlyResponse {
    return self.response;
}

- (NSString *)HTTPMethod {
    return self.request.HTTPMethod;
}

- (NSInteger)HTTPStatusCode {
    if (self.request) {
        return self.response.statusCode;
    } else {
        return 0;
    }
}

- (void)setFreezable:(BOOL)freezable {
    if ([_request.HTTPMethod isEqualToString:@"GET"] && freezable) {
        return;
    }
    
    _freezable = freezable;
    
    if (_freezable && self.uniqueID == nil) {
        self.uniqueID = [NSString uniqueString];
    }
}

- (BOOL)isEqual:(id)object {
    if([self.request.HTTPMethod isEqualToString:@"GET"] || [self.request.HTTPMethod isEqualToString:@"HEAD"]) {
        
        NABNetworkOperation *anotherObject = (NABNetworkOperation *) object;
        return ([[self uniqueIdentifier] isEqualToString:[anotherObject uniqueIdentifier]]);
    }
    
    return NO;
}

- (NSString *)uniqueIdentifier {
    NSString *string = [self curlCommandLineString];
    
    if (_freezable) {
        string = [string stringByAppendingString:self.uniqueID];
    }
    
    return [string md5];
}

- (BOOL)isCachedResponse {
    return self.cachedResponse != nil;
}

- (void)updateHandlersFromOperation:(NABNetworkOperation *)operation {
    [self.responseBlocks addObjectsFromArray:operation.responseBlocks];
    [self.errorBlocks addObjectsFromArray:operation.errorBlocks];
    [self.uploadProgressChangedHandlers addObjectsFromArray:operation.uploadProgressChangedHandlers];
    [self.downloadProgressChangedHandlers addObjectsFromArray:operation.downloadProgressChangedHandlers];
    [self.downloadStreams addObjectsFromArray:self.downloadStreams];
}

- (void)setCachedData:(NSData *)cachedData {
    self.cachedResponse = cachedData;
    [self operationSucceeded];
}

- (void)updateOperationBasedOnPreviousHeaders:(NSMutableDictionary *)headers {
    NSString *lastModified = [headers objectForKey:@"Last-Modified"];
    NSString *eTag = [headers objectForKey:@"ETag"];
    
    if(lastModified) {
        [self.request setHTTPMethod:@"HEAD"];
        [self.request setValue:lastModified forHTTPHeaderField:@"IF-MODIFIED-SINCE"];
    }
    
    if(eTag) {
        [self.request setHTTPMethod:@"HEAD"];
        [self.request setValue:eTag forHTTPHeaderField:@"IF-NONE-MATCH"];
    } 
}

- (void)setUploadStream:(NSInputStream *)inputStream {
    // method has not been implemented yet
//    self.request.HTTPBodyStream = inputStream;
}

- (void)addDownloadStream:(NSOutputStream *)outputStream {
    [self.downloadStreams addObject:outputStream];
}

- (void)addHeaders:(NSDictionary *)headersDictionary {
    [headersDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [self.request addValue:obj forHTTPHeaderField:key];
    }];
}

-(void) addData:(NSData*) data forKey:(NSString*) key {
    
    [self addData:data forKey:key mimeType:@"application/octet-stream"];
}

-(void) addData:(NSData*) data forKey:(NSString*) key mimeType:(NSString*) mimeType {
    
    [self.request setHTTPMethod:@"POST"];
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          data, @"data",
                          key, @"name",
                          mimeType, @"mimetype",     
                          nil];
    
    [self.dataToBePosted addObject:dict];    
}

-(void) addFile:(NSString*) filePath forKey:(NSString*) key {
    
    [self addFile:filePath forKey:key mimeType:@"application/octet-stream"];
}

-(void) addFile:(NSString*) filePath forKey:(NSString*) key mimeType:(NSString*) mimeType {
    
    [self.request setHTTPMethod:@"POST"];
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          filePath, @"filepath",
                          key, @"name",
                          mimeType, @"mimetype",     
                          nil];
    
    [self.filesToBePosted addObject:dict];    
}

- (NABNetworkOperationState)state {
    return _state;
}


#pragma mark - Notification Handling

- (void)setState:(NABNetworkOperationState)state {
    switch (state) {
        case NABNetworkOperationStateReady:
            [self willChangeValueForKey:@"isReady"];
            break;
        case NABNetworkOperationStateExecuting:
            [self willChangeValueForKey:@"isReady"];
            [self willChangeValueForKey:@"isExecuting"];
            break;
        case NABNetworkOperationStateFinished:
            [self willChangeValueForKey:@"isExecuting"];
            [self willChangeValueForKey:@"isFinished"];
            break;
        default:
            break;
    }
    
    _state = state;
    
    switch (state) {
        case NABNetworkOperationStateReady:
            [self didChangeValueForKey:@"isReady"];
            break;
        case NABNetworkOperationStateExecuting:
            [self didChangeValueForKey:@"isReady"];
            [self didChangeValueForKey:@"isExecuting"];
            break;
        case NABNetworkOperationStateFinished:
            [self didChangeValueForKey:@"isExecuting"];
            [self didChangeValueForKey:@"isFinished"];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.backgroundTaskID != UIBackgroundTaskInvalid) {
                    [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTaskID];
                    self.backgroundTaskID = UIBackgroundTaskInvalid;
                }
            });
            
            break;
    }
}

- (void)notifyCache {
    
    if (![self isCacheble]) {
        return;
    }
    
    if (!([self.response statusCode] >= 200 && [self.response statusCode] < 300)) {
        return;
    }
    
    self.cacheHandlingBlock(self);
}

#pragma mark - Block Handling

-(void) onCompletion:(NABNetworkResponseBlock) response onError:(NABNetworkErrorBlock) error {
    
    [self.responseBlocks addObject:[response copy]];
    [self.errorBlocks addObject:[error copy]];
}

-(void) onUploadProgressChanged:(NABNetworkProgressBlock) uploadProgressBlock {
    
    [self.uploadProgressChangedHandlers addObject:[uploadProgressBlock copy]];
}

-(void) onDownloadProgressChanged:(NABNetworkProgressBlock) downloadProgressBlock {
    
    [self.downloadProgressChangedHandlers addObject:[downloadProgressBlock copy]];
}


#pragma mark - 

-(NSString*) description {
    
    NSMutableString *displayString = [NSMutableString stringWithFormat:@"%@\nRequest\n-------\n%@", 
                                      [[NSDate date] descriptionWithLocale:[NSLocale currentLocale]],
                                      [self curlCommandLineString]];
    
    NSString *responseString = [self responseString];    
    if([responseString length] > 0) {
        [displayString appendFormat:@"\n--------\nResponse\n--------\n%@\n", responseString];
    }
    
    return displayString;
}

-(NSString*) curlCommandLineString
{
    __block NSMutableString *displayString = [NSMutableString stringWithFormat:@"curl -X %@", self.request.HTTPMethod];
    
    if([self.filesToBePosted count] == 0 && [self.dataToBePosted count] == 0) {
        [[self.request allHTTPHeaderFields] enumerateKeysAndObjectsUsingBlock:^(id key, id val, BOOL *stop)
         {
             [displayString appendFormat:@" -H \"%@: %@\"", key, val];
         }];
    }
    
    [displayString appendFormat:@" \"%@\"",  self.url];
    
    if ([self.request.HTTPMethod isEqualToString:@"POST"] || [self.request.HTTPMethod isEqualToString:@"PUT"]) {
        
        NSString *option = [self.filesToBePosted count] == 0 ? @"-d" : @"-F";
        [self.fieldToBePosted enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            
            [displayString appendFormat:@" %@ \"%@=%@\"", option, key, obj];    
        }];
        
        [self.filesToBePosted enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            NSDictionary *thisFile = (NSDictionary*) obj;
            [displayString appendFormat:@" -F \"%@=@%@;type=%@\"", [thisFile objectForKey:@"name"],
             [thisFile objectForKey:@"filepath"], [thisFile objectForKey:@"mimetype"]];
        }];
        
        /* Not sure how to do this via curl
         [self.dataToBePosted enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
         
         NSDictionary *thisData = (NSDictionary*) obj;
         [displayString appendFormat:@" --data-binary \"%@\"", [thisData objectForKey:@"data"]];
         }];*/
    }
    
    return displayString;
}

- (NSData *)bodyData {
    if([self.filesToBePosted count] == 0 && [self.dataToBePosted count] == 0) {
        
        return [[self encodedPostDataString] dataUsingEncoding:self.stringEncoding];
    }
    
    NSString *boundary = @"0xKhTmLbOuNdArY";
    NSMutableData *body = [NSMutableData data];
    __block NSUInteger postLength = 0;    
    
    [self.fieldToBePosted enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        
        NSString *thisFieldString = [NSString stringWithFormat:
                                     @"--%@\r\nContent-Disposition: form-data; name=\"%@\"\r\n\r\n%@\r\n",
                                     boundary, [key urlEncodedString], [obj urlEncodedString]];
        
        [body appendData:[thisFieldString dataUsingEncoding:[self stringEncoding]]];
    }];        
    
    [self.filesToBePosted enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        NSDictionary *thisFile = (NSDictionary*) obj;
        NSString *thisFieldString = [NSString stringWithFormat:
                                     @"--%@\r\nContent-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\nContent-Type: %@\r\nContent-Transfer-Encoding: binary\r\n\r\n",
                                     boundary, 
                                     [thisFile objectForKey:@"name"], 
                                     [[thisFile objectForKey:@"filepath"] lastPathComponent], 
                                     [thisFile objectForKey:@"mimetype"]];
        
        [body appendData:[thisFieldString dataUsingEncoding:[self stringEncoding]]];         
        [body appendData: [NSData dataWithContentsOfFile:[thisFile objectForKey:@"filepath"]]];
    }];
    
    [self.dataToBePosted enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        NSDictionary *thisDataObject = (NSDictionary*) obj;
        NSString *thisFieldString = [NSString stringWithFormat:
                                     @"--%@\r\nContent-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\nContent-Type: %@\r\nContent-Transfer-Encoding: binary\r\n\r\n",
                                     boundary, 
                                     [thisDataObject objectForKey:@"name"], 
                                     [thisDataObject objectForKey:@"name"], 
                                     [thisDataObject objectForKey:@"mimetype"]];
        
        [body appendData:[thisFieldString dataUsingEncoding:[self stringEncoding]]];         
        [body appendData:[thisDataObject objectForKey:@"data"]];
    }];
    
    if (postLength >= 1)
        [self.request setValue:[NSString stringWithFormat:@"%lu", postLength] forHTTPHeaderField:@"content-length"];
    
    [body appendData: [[NSString stringWithFormat:@"\r\n--%@--\r\n", boundary] dataUsingEncoding:self.stringEncoding]];
    
    NSString *charset = (__bridge NSString *)CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(self.stringEncoding));
    
    if(([self.filesToBePosted count] > 0) || ([self.dataToBePosted count] > 0)) {
        [self.request setValue:[NSString stringWithFormat:@"multipart/form-data; charset=%@; boundary=%@", charset, boundary] 
            forHTTPHeaderField:@"Content-Type"];
        
        [self.request setValue:[NSString stringWithFormat:@"%d", [body length]] forHTTPHeaderField:@"Content-Length"];
    }
    
    return body;
}

- (void)setCacheHandler:(NABNetworkResponseBlock)cacheHandler {
    self.cacheHandlingBlock = cacheHandler;
}


#pragma mark - main method

- (void)main {
    @autoreleasepool {
        [self start];
    }
}

- (void)start {
    if(![NSThread isMainThread]){
        [self performSelectorOnMainThread:@selector(start) withObject:nil waitUntilDone:NO];
        return;
    }
    
    self.backgroundTaskID = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.backgroundTaskID != UIBackgroundTaskInvalid) {
                [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTaskID];
                self.backgroundTaskID = UIBackgroundTaskInvalid;
                [self cancel];
            }
        });
    }];
    DLog(@"%@", self.url);
    if (!self.isCancelled) {
        if ([_request.HTTPMethod isEqualToString:@"POST"] || [_request.HTTPMethod isEqualToString:@"PUT"]) {
            [_request setHTTPBody:[self bodyData]];
        }
        
        self.connection = [[NSURLConnection alloc] initWithRequest:_request delegate:self startImmediately:YES];
        self.state = NABNetworkOperationStateExecuting;
    } else {
        self.state = NABNetworkOperationStateFinished;
    }
}


#pragma mark - NSOperation overriden method

- (BOOL)isConcurrent
{
    return YES;
}

- (BOOL)isReady {
    
    return (self.state == NABNetworkOperationStateReady);
}

- (BOOL)isFinished 
{
	return (self.state == NABNetworkOperationStateFinished);
}

- (BOOL)isExecuting {
    
	return (self.state == NABNetworkOperationStateExecuting);
}

-(void) cancel {
    
    if([self isFinished]) return;
    
    [self.responseBlocks removeAllObjects];
    self.responseBlocks = nil;
    
    [self.errorBlocks removeAllObjects];
    self.errorBlocks = nil;
    
    [self.uploadProgressChangedHandlers removeAllObjects];
    self.uploadProgressChangedHandlers = nil;
    
    [self.downloadProgressChangedHandlers removeAllObjects];
    self.downloadProgressChangedHandlers = nil;
    
    [self.downloadStreams removeAllObjects];
    self.downloadStreams = nil;
    
    [self.connection cancel];
    
    
    self.mutableData = nil;
    self.isCancelled = YES;
    self.cacheHandlingBlock = nil;
    
    self.state = NABNetworkOperationStateFinished;
    
    [super cancel];
}

#pragma mark - NSURLConnection delegates

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    _error = error;
    self.mutableData = nil;
    
    for (NSOutputStream *outputStream in self.downloadStreams) {
        [outputStream close];
    }
    self.state = NABNetworkOperationStateFinished;
    
    [self operationFailedWithError:error];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if ([self.mutableData length] == 0) {
        // This is the first batch of data
        // Check for a range header and make changes as neccesary
        NSString *rangeString = [[self request] valueForHTTPHeaderField:@"Range"];
        if ([rangeString hasPrefix:@"bytes="] && [rangeString hasSuffix:@"-"]) {
            NSString *bytesText = [rangeString substringWithRange:NSMakeRange(6, [rangeString length] - 7)];
            self.startPosition = [bytesText integerValue];
            NSLog(@"Resuming at %d bytes", self.startPosition);
        }
    }
    
    [self.mutableData appendData:data];
    
    for(NSOutputStream *stream in self.downloadStreams) {
        
        if ([stream hasSpaceAvailable]) {
            const uint8_t *dataBuffer = [data bytes];
            [stream write:&dataBuffer[0] maxLength:[data length]];
        }
    }
    
    for(NABNetworkProgressBlock downloadProgressBlock in self.downloadProgressChangedHandlers) {
        
        if([self.response expectedContentLength] > 0) {
            
            double progress = (double)[self.mutableData length] / (double)[self.response expectedContentLength];
            downloadProgressBlock(progress);
        }        
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSUInteger size = [self.response expectedContentLength] < 0 ? 0 : [self.response expectedContentLength];
    self.response = (NSHTTPURLResponse*) response;
    self.mutableData = [NSMutableData dataWithCapacity:size];
    
    for(NSOutputStream *stream in self.downloadStreams)
        [stream open];
    
    NSDictionary *httpHeaders = [self.response allHeaderFields];
    
    // handle cache here
    if([self.request.HTTPMethod isEqualToString:@"GET"] && [self.downloadStreams count] == 0) {
        
        // We have all this complicated cache handling since NSURLRequestReloadRevalidatingCacheData is not implemented
        // do cache processing only if the request is a "GET" method
        NSString *lastModified = [httpHeaders objectForKey:@"Last-Modified"];
        NSString *eTag = [httpHeaders objectForKey:@"ETag"];
        NSString *expiresOn = [httpHeaders objectForKey:@"Expires"];
        
        NSString *contentType = [httpHeaders objectForKey:@"Content-Type"];
        // if contentType is image, 
        
        NSDate *expiresOnDate = nil;
        
        if([contentType rangeOfString:@"image"].location != NSNotFound) {
            
            // For images let's assume a expiry date of 7 days if there is no eTag or Last Modified.
            if(!eTag && !lastModified)
                expiresOnDate = [[NSDate date] dateByAddingTimeInterval:kNABNetworkKitDefaultImageCacheDuration];
            else    
                expiresOnDate = [[NSDate date] dateByAddingTimeInterval:kNABNetworkKitDefaultImageHeadRequestDuration];
        }
        
        NSString *cacheControl = [httpHeaders objectForKey:@"Cache-Control"]; // max-age, must-revalidate, no-cache
        NSArray *cacheControlEntities = [cacheControl componentsSeparatedByString:@","];
        
        for(NSString *substring in cacheControlEntities) {
            
            if([substring rangeOfString:@"max-age"].location != NSNotFound) {
                
                // do some processing to calculate expiresOn
                NSString *maxAge = nil;
                NSArray *array = [substring componentsSeparatedByString:@"="];
                if([array count] > 1)
                    maxAge = [array objectAtIndex:1];
                
                expiresOnDate = [[NSDate date] dateByAddingTimeInterval:[maxAge intValue]];
            }
            if([substring rangeOfString:@"no-cache"].location != NSNotFound) {
                
                // Don't cache this request
                expiresOnDate = [[NSDate date] dateByAddingTimeInterval:kNABNetworkKitDefaultCacheDuration];
            }
        }
        
        // if there was a cacheControl entity, we would have a expiresOnDate that is not nil.        
        // "Cache-Control" headers take precedence over "Expires" headers
        
        expiresOn = [expiresOnDate rfc1123String];
        
        // now remember lastModified, eTag and expires for this request in cache
        if(expiresOn)
            [self.cacheHeaders setObject:expiresOn forKey:@"Expires"];
        if(lastModified)
            [self.cacheHeaders setObject:lastModified forKey:@"Last-Modified"];
        if(eTag)
            [self.cacheHeaders setObject:eTag forKey:@"ETag"];
    }
    
}

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten 
                                            totalBytesWritten:(NSInteger)totalBytesWritten 
                                    totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
    for (NABNetworkProgressBlock uploadingProgressBlock in self.uploadProgressChangedHandlers) {
        if (totalBytesExpectedToWrite > 0) {
            uploadingProgressBlock((double)totalBytesWritten / (double)totalBytesExpectedToWrite);
        }
    }
}

//- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response {
//    if (response) {
//        NSMutableURLRequest *mutableURLReq = [self.request mutableCopy];
//        [mutableURLReq setURL:request.URL];
//        
//        return mutableURLReq;
//    } else {
//        return request;
//    }
//}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    self.state = NABNetworkOperationStateFinished;
    
    for(NSOutputStream *stream in self.downloadStreams)
        [stream close];
    
    if (self.response.statusCode >= 200 && self.response.statusCode < 300) {
        
        self.cachedResponse = nil; // remove cached data
        [self notifyCache];        
        [self operationSucceeded];
        
    } 
    if (self.response.statusCode >= 300 && self.response.statusCode < 400) {
        
        if(self.response.statusCode == 301) {
            NSLog(@"%@ has moved to %@", self.url, [self.response.URL absoluteString]);
        }
        else if(self.response.statusCode == 304) {
            NSLog(@"%@ not modified", self.url);
        }
        else if(self.response.statusCode == 307) {
            NSLog(@"%@ temporarily redirected", self.url);
        }
        else {
            NSLog(@"%@ returned status %d", self.url, [self HTTPStatusCode]);
        }
        
    } else if (self.response.statusCode >= 400 && self.response.statusCode < 600) {                        
        
        NSError *error = [NSError errorWithDomain:NSURLErrorDomain
                                             code:self.response.statusCode
                                         userInfo:self.response.allHeaderFields];
        
        [self operationFailedWithError:error];
    }
}

#pragma mark - our method to get data

- (NSData *)responseData {
    if ([self isFinished]) {
        return self.mutableData;
    } else if (self.cachedResponse) {
        return _cachedResponse;
    } else {
        return nil;
    }
}

- (NSString *)responseString {
    return [self responseStringWithEncoding:self.stringEncoding];
}

- (NSString *)responseStringWithEncoding:(NSStringEncoding)endcoding {
    return [[NSString alloc] initWithData:[self responseData] encoding:endcoding];
}

- (UIImage *)responseImage {
    return [UIImage imageWithData:[self responseData]];
}

#ifdef __IPHONE_5_0

- (id)responseJSON {
    
    if([NSJSONSerialization class]) {
        if ([self responseJSON] == nil) {
            return nil;
        }
        
        NSError *error = nil;
        
        id returnValue = [NSJSONSerialization JSONObjectWithData:[self responseJSON] options:0 error:&error];
        
        if (error) {
            NSLog(@"JSON Persing Error: %@",  error);
        }
        
        return returnValue;
    } else {
        return [self responseString];
    }

}

#endif


#pragma mark - Overridable methods

-(void) operationSucceeded {
    
    // don't log for cached responses
    if(![self isCachedResponse]) {
        
    } else {
        NSLog(@"%@", self);
    }
    
    for(NABNetworkResponseBlock responseBlock in self.responseBlocks)
        responseBlock(self);
}

-(void) operationFailedWithError:(NSError*) error {
    
//    DLog(@"%@", self);
    for(NABNetworkErrorBlock errorBlock in self.errorBlocks)
        errorBlock(error);       
}

@end
