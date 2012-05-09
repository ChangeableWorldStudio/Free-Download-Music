//
//  NABNetworkEngine.m
//  NABNetworkKit
//
//  Created by Phan Tran Le Nguyen on 12/11/11.
//  Copyright (c) 2011 Not A Basement Studio®. All rights reserved.
//

#import "NABNetworkEngine.h"
#import "Reachability.h"
#import "NSDate+RFC1123.h"
#import "NABNetworkOperation+EngineMethod.h"

#define NABNETWORKCACHE_DEFAULT_DIRECTORY @"NetworkCache"
#define kFreezableOperationExtension @"nabnetworkkitfrozenoperation"
#define kMKNetworkEngineOperationCountChanged @"kMKNetworkEngineOperationCountChanged"

@interface NABNetworkEngine ()

@property (strong, nonatomic) NSString              *hostName;
@property (strong, nonatomic) Reachability          *reachability;
@property (strong, nonatomic) NSDictionary          *customHeaders;
@property (assign, nonatomic) Class                 customOperationSubclass;

@property (nonatomic, strong) NSMutableDictionary   *memoryCache;
@property (nonatomic, strong) NSMutableArray        *memoryCacheKeys;
@property (nonatomic, strong) NSMutableDictionary   *cacheInvalidationParams;

- (void)saveCache;
- (void)saveCacheData:(NSData *)data forKey:(NSString *) cacheDataKey;

- (void)freezeOperations;
- (void)checkAndRestoreFrozenOperations;

- (BOOL)isCacheEnabled;
@end

static NSOperationQueue *_sharedNetworkQueue;

@implementation NABNetworkEngine

@synthesize hostName = _hostName;
@synthesize reachability = _reachability;
@synthesize customHeaders = _customHeaders;
@synthesize customOperationSubclass = _customOperationSubclass;

@synthesize memoryCache = _memoryCache;
@synthesize memoryCacheKeys = _memoryCacheKeys;
@synthesize cacheInvalidationParams = _cacheInvalidationParams;
@synthesize reachabilityChangedHandler = _reachabilityChangedHandler;


// Network Queue is a shared singleton object.
// no matter how many instances of MKNetworkEngine is created, there is one and only one network queue
// In theory an app should contain as many network engines as the number of domains it talks to

#pragma mark -
#pragma mark Initialization

+ (void)initialize {
    
    if (!_sharedNetworkQueue) {
        static dispatch_once_t oncePredicate;
        dispatch_once(&oncePredicate, ^{
            _sharedNetworkQueue = [[NSOperationQueue alloc] init];
            [_sharedNetworkQueue addObserver:[self self] forKeyPath:@"operationCount" options:0 context:NULL];
            [_sharedNetworkQueue setMaxConcurrentOperationCount:6];
            
        });
    }            
}

- (id)initWithHostName:(NSString *)hostName customHeaderFields:(NSDictionary *)headers {
    
    if ((self = [super init])) {        
        
        if (hostName) {
            [[NSNotificationCenter defaultCenter] addObserver:self 
                                                     selector:@selector(reachabilityChanged:) 
                                                         name:kReachabilityChangedNotification 
                                                       object:nil];
            
            DLog(@"NABNetworkEngine: Engine initialized with host: %@", hostName);
            self.hostName = hostName;            
            self.reachability = [Reachability reachabilityWithHostname:self.hostName];
            [self.reachability startNotifier];            
        }
        
        if ([headers objectForKey:@"User-Agent"] == nil) {
            
            NSMutableDictionary *newHeadersDict = [headers mutableCopy];
            NSString *userAgentString = [NSString stringWithFormat:@"%@/%@", 
                                         [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleNameKey], 
                                         [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey]];
            [newHeadersDict setObject:userAgentString forKey:@"User-Agent"];
            self.customHeaders = newHeadersDict;
        } else {
            self.customHeaders = headers;
        }
        
        self.customOperationSubclass = [NABNetworkOperation class];
    }
    
    return self;
}

#pragma mark -
#pragma mark Memory Mangement

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];  
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
}

+ (void)dealloc {
    [_sharedNetworkQueue removeObserver:[self self] forKeyPath:@"operationCount"];
}

#pragma mark - KVO for network Queue

+ (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object 
                         change:(NSDictionary *)change context:(void *)context
{
    if (object == _sharedNetworkQueue && [keyPath isEqualToString:@"operationCount"]) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kMKNetworkEngineOperationCountChanged 
                                                            object:[NSNumber numberWithInteger:[_sharedNetworkQueue operationCount]]];
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = 
        ([_sharedNetworkQueue.operations count] > 0);        
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object 
                               change:change context:context];
    }
}

#pragma mark - Reachability related

- (void)reachabilityChanged:(NSNotification*) notification
{
    if ([self.reachability currentReachabilityStatus] == ReachableViaWiFi)
    {
        DLog(@"NABNetworkEngine: Server [%@] is reachable via Wifi", self.hostName);
        [_sharedNetworkQueue setMaxConcurrentOperationCount:6];
        
        [self checkAndRestoreFrozenOperations];
    }
    else if ([self.reachability currentReachabilityStatus] == ReachableViaWWAN)
    {
        DLog(@"NABNetworkEngine: Server [%@] is reachable only via cellular data", self.hostName);
        [_sharedNetworkQueue setMaxConcurrentOperationCount:2];
        [self checkAndRestoreFrozenOperations];
    }
    else if ([self.reachability currentReachabilityStatus] == NotReachable)
    {
        DLog(@"NABNetworkEngine: Server [%@] is not reachable", self.hostName);        
        [self freezeOperations];
    }
    
    if(self.reachabilityChangedHandler) {
        self.reachabilityChangedHandler([self.reachability currentReachabilityStatus]);
    }
}

#pragma Freezing operations (Called when network connectivity fails)
- (void)freezeOperations {
    
    if (![self isCacheEnabled]) return;
    
    for(NABNetworkOperation *operation in _sharedNetworkQueue.operations) {
        
        // freeze only freeable operations.
        if (![operation freezable]) continue;
        
        // freeze only operations that belong to this server
        if ([[operation url] rangeOfString:self.hostName].location == NSNotFound)continue;
        
        NSString *archivePath = [[[self cacheDirectoryName] stringByAppendingPathComponent:[operation uniqueIdentifier]] 
                                 stringByAppendingPathExtension:kFreezableOperationExtension];
        [NSKeyedArchiver archiveRootObject:operation toFile:archivePath];
        [operation cancel];
    }
    
}

- (void)checkAndRestoreFrozenOperations {
    
    if (![self isCacheEnabled]) return;
    
    NSError *error = nil;
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self cacheDirectoryName] error:&error];
    if (error) {
        DLog(@"NABNetworkEngine: %@", error);
    }
    
    NSArray *pendingOperations = [files filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        
        NSString *thisFile = (NSString*) evaluatedObject;
        return ([thisFile rangeOfString:kFreezableOperationExtension].location != NSNotFound);             
    }]];
    
    for(NSString *pendingOperationFile in pendingOperations) {
        
        NSString *archivePath = [[self cacheDirectoryName] stringByAppendingPathComponent:pendingOperationFile];
        NABNetworkOperation *pendingOperation = [NSKeyedUnarchiver unarchiveObjectWithFile:archivePath];
        [self enqueueOperation:pendingOperation];
        NSError *error = nil;
        [[NSFileManager defaultManager] removeItemAtPath:archivePath error:&error];
        if (error) DLog(@"NABNetworkEngine: %@", error);
    }
}

- (NSString *)readonlyHostName {
    
    return [_hostName copy];
}

- (BOOL) isReachable {
    
    return ([self.reachability currentReachabilityStatus] != NotReachable);
}

#pragma mark - Create methods

- (NABNetworkOperation *) operationWithPath:(NSString *)path {
    
    return [self operationWithPath:path params:nil];
}

- (NABNetworkOperation *) operationWithPath:(NSString *)path
                                  params:(NSMutableDictionary *)body {
    
    return [self operationWithPath:path 
                            params:body 
                        httpMethod:@"GET"];
}

- (NABNetworkOperation *) operationWithPath:(NSString *)path
                                  params:(NSMutableDictionary *)body
                              httpMethod:(NSString *)method  {
    
    NSString *urlString = [NSString stringWithFormat:@"http://%@/%@", self.hostName, path];
    
    return [self operationWithURLString:urlString params:body httpMethod:method];
}

- (NABNetworkOperation *) operationWithURLString:(NSString *)urlString {
    
    return [self operationWithURLString:urlString params:nil httpMethod:@"GET"];
}

- (NABNetworkOperation *) operationWithURLString:(NSString *)urlString
                                       params:(NSMutableDictionary *)body {
    
    return [self operationWithURLString:urlString params:body httpMethod:@"GET"];
}

- (NABNetworkOperation *) operationWithPath:(NSString*) path
                                    params:(NSMutableDictionary*) body
                                httpMethod:(NSString*)method 
                                       ssl:(BOOL) useSSL {
    
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/%@", useSSL ? @"https" : @"http", self.hostName, path];
    
    return [self operationWithURLString:urlString params:body httpMethod:method];
}


- (NABNetworkOperation *) operationWithURLString:(NSString *)urlString
                                       params:(NSMutableDictionary *)body
                                   httpMethod:(NSString *) method {
    
    NABNetworkOperation *operation = [[NABNetworkOperation alloc] initWithURLString:urlString params:body httpMethod:method];
    
    [self prepareHeaders:operation];
    return operation;
}

- (void)prepareHeaders:(NABNetworkOperation *)operation {
    
    [operation addHeaders:self.customHeaders];
}

- (NSData *)cachedDataForOperation:(NABNetworkOperation *) operation {
    
    NSData *cachedData = [self.memoryCache objectForKey:[operation uniqueIdentifier]];
    if (cachedData) return cachedData;
    
    NSString *filePath = [[self cacheDirectoryName] stringByAppendingPathComponent:[operation uniqueIdentifier]];    
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        
        NSData *cachedData = [NSData dataWithContentsOfFile:filePath];
        [self saveCacheData:cachedData forKey:[operation uniqueIdentifier]]; // bring it back to the in-memory cache
        return cachedData;
    }
    
    return nil;
}

- (void)enqueueOperation:(NABNetworkOperation *) operation {
    
    [self enqueueOperation:operation forceReload:NO];
}

- (void)enqueueOperation:(NABNetworkOperation *)operation forceReload:(BOOL)forceReload {
    
    // Grab on to the current queue (We need it later)
    __block dispatch_queue_t originalQueue = dispatch_get_current_queue();
    // Jump off the main thread, mainly for disk cache reading purposes
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [operation setCacheHandler:^(NABNetworkOperation* completedCacheableOperation) {
            
            // if this is not called, the request would have been a non cacheable request
            //completedCacheableOperation.cacheHeaders;
            NSString *uniqueId = [completedCacheableOperation uniqueIdentifier];
            [self saveCacheData:[completedCacheableOperation responseData] 
                         forKey:uniqueId];
            
            [self.cacheInvalidationParams setObject:completedCacheableOperation.cacheHeaders forKey:uniqueId];
        }];
        
        __block double expiryTimeInSeconds = 0.0f;    
        
        if(!forceReload) {
            NSData *cachedData = [self cachedDataForOperation:operation];
            if(cachedData) {
                dispatch_async(originalQueue, ^{
                    // Jump back to the original thread here since setCachedData updates the main thread
                    [operation setCachedData:cachedData];                    
                });
                
                
                NSString *uniqueId = [operation uniqueIdentifier];
                NSMutableDictionary *savedCacheHeaders = [self.cacheInvalidationParams objectForKey:uniqueId];
                // there is a cached version.
                // this means, the current operation is a "GET"
                if(savedCacheHeaders) {
                    NSString *expiresOn = [savedCacheHeaders objectForKey:@"Expires"];
                    
                    dispatch_sync(originalQueue, ^{
                        NSDate *expiresOnDate = [NSDate dateFromRFC1123:expiresOn];
                        expiryTimeInSeconds = [expiresOnDate timeIntervalSinceNow];
                    });
                    
                    [operation updateOperationBasedOnPreviousHeaders:savedCacheHeaders];
                }
            }
        }
        
        dispatch_async(originalQueue, ^{
            
            NSUInteger index = [_sharedNetworkQueue.operations indexOfObject:operation];
            if(index == NSNotFound) {
                
                if(expiryTimeInSeconds <= 0)
                    [_sharedNetworkQueue addOperation:operation];
                else if(forceReload)
                    [_sharedNetworkQueue addOperation:operation];
                // else don't do anything
                DLog(@"%d", [_sharedNetworkQueue.operations count]);
            }
            else {
                // This operation is already being processed
                NABNetworkOperation *queuedOperation = (NABNetworkOperation *) [_sharedNetworkQueue.operations objectAtIndex:index];
                [queuedOperation updateHandlersFromOperation:operation];
            }
            
            if([self.reachability currentReachabilityStatus] == NotReachable)
                [self freezeOperations];
        }); 
    });
}

- (NABNetworkOperation *)imageAtURL:(NSURL *)url onCompletion:(NABNetworkImageBlock)imageFetchedBlock
{
        
    if (url == nil) {
        return nil;
    }
    
    NABNetworkOperation *op = [self operationWithURLString:[url absoluteString]];
    
    [op 
     onCompletion:^(NABNetworkOperation *completedOperation)
     {
         imageFetchedBlock([completedOperation responseImage], 
                           url,
                           [completedOperation isCachedResponse]);
         
     }
     onError:^(NSError* error) {
         
         DLog(@"%@", error);
     }];    
    
    [self enqueueOperation:op];
    
    return op;
}

#pragma mark - Cache related

- (void)registerOperationSubclass:(Class) aClass {
    
    self.customOperationSubclass = aClass;
}

- (NSArray *)allOperations {
    return [NSArray arrayWithArray:[_sharedNetworkQueue operations]];
}

- (NSString *)cacheDirectoryName {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *cacheDirectoryName = [documentsDirectory stringByAppendingPathComponent:NABNETWORKCACHE_DEFAULT_DIRECTORY];
    return cacheDirectoryName;
}

- (int)cacheMemoryCost {
    // subclass this method to change number of cache GET request
    return 1500;
}

- (void)saveCache {
    
    for(NSString *cacheKey in [self.memoryCache allKeys])
    {
        NSString *filePath = [[self cacheDirectoryName] stringByAppendingPathComponent:cacheKey];
        [[self.memoryCache objectForKey:cacheKey] writeToFile:filePath atomically:YES];        
    }
    
    [self.memoryCache removeAllObjects];
    [self.memoryCacheKeys removeAllObjects];
    
    NSString *cacheInvalidationPlistFilePath = [[self cacheDirectoryName] stringByAppendingPathExtension:@"plist"];
    [self.cacheInvalidationParams writeToFile:cacheInvalidationPlistFilePath atomically:YES];
}

- (void)saveCacheData:(NSData *)data forKey:(NSString *)cacheDataKey
{    
    @synchronized(self) {
        [self.memoryCache setObject:data forKey:cacheDataKey];
        
        NSUInteger index = [self.memoryCacheKeys indexOfObject:cacheDataKey];
        if(index != NSNotFound)
            [self.memoryCacheKeys removeObjectAtIndex:index];    
        
        [self.memoryCacheKeys insertObject:cacheDataKey atIndex:0]; // remove it and insert it at start
        
        if([self.memoryCacheKeys count] >= [self cacheMemoryCost])
        {
            NSString *lastKey = [self.memoryCacheKeys lastObject];        
            NSData *data = [self.memoryCache objectForKey:lastKey];        
            NSString *filePath = [[self cacheDirectoryName] stringByAppendingPathComponent:lastKey];
            
            if(![[NSFileManager defaultManager] fileExistsAtPath:filePath])
                [data writeToFile:filePath atomically:YES];
            
            [self.memoryCacheKeys removeLastObject];
            [self.memoryCache removeObjectForKey:lastKey];        
        }
    }
}

- (BOOL) isCacheEnabled {
    
    BOOL isDir = NO;
    BOOL isCachingEnabled = [[NSFileManager defaultManager] fileExistsAtPath:[self cacheDirectoryName] isDirectory:&isDir];
    return isCachingEnabled;
}

- (void)useCache {
    
    self.memoryCache = [NSMutableDictionary dictionaryWithCapacity:[self cacheMemoryCost]];
    self.memoryCacheKeys = [NSMutableArray arrayWithCapacity:[self cacheMemoryCost]];
    self.cacheInvalidationParams = [NSMutableDictionary dictionary];
    
    NSString *cacheDirectory = [self cacheDirectoryName];
    BOOL isDirectory = YES;
    BOOL folderExists = [[NSFileManager defaultManager] fileExistsAtPath:cacheDirectory isDirectory:&isDirectory] && isDirectory;
    
    if (!folderExists)
    {
        NSError *error = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:cacheDirectory withIntermediateDirectories:YES attributes:nil error:&error];
    }
    
    NSString *cacheInvalidationPlistFilePath = [cacheDirectory stringByAppendingPathExtension:@"plist"];
    
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:cacheInvalidationPlistFilePath];
    
    if (fileExists)
    {
        self.cacheInvalidationParams = [NSMutableDictionary dictionaryWithContentsOfFile:cacheInvalidationPlistFilePath];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveCache)
                                                 name:UIApplicationDidReceiveMemoryWarningNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveCache)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveCache)
                                                 name:UIApplicationWillTerminateNotification
                                               object:nil];
    
}

-(void) emptyCache {
    
    [self saveCache]; // ensures that invalidation params are written to disk properly
    NSError *error = nil;
    NSArray *directoryContents = [[NSFileManager defaultManager] 
                                  contentsOfDirectoryAtPath:[self cacheDirectoryName] error:&error];
    if(error) DLog(@"%@", error);
    
    error = nil;
    for(NSString *fileName in directoryContents) {
        
        NSString *path = [[self cacheDirectoryName] stringByAppendingPathComponent:fileName];
        [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
        if(error) DLog(@"%@", error);
    }
    
    error = nil;
    NSString *cacheInvalidationPlistFilePath = [[self cacheDirectoryName] stringByAppendingPathExtension:@"plist"];
    [[NSFileManager defaultManager] removeItemAtPath:cacheInvalidationPlistFilePath error:&error];
    if(error) DLog(@"%@", error);
}

- (void)cancelAndRemoveOperation:(NABNetworkOperation *)operation {
    [operation cancel];
    
    if ([_sharedNetworkQueue.operations indexOfObject:operation] != NSNotFound) {
        
    }
}

@end
