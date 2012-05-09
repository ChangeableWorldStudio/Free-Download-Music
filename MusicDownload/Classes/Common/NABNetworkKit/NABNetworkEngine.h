//
//  NABNetworkEngine.h
//  NABNetworkKit
//
//  Created by Phan Tran Le Nguyen on 12/11/11.
//  Copyright (c) 2011 Not A Basement Studio®. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NABNetworkOperation.h"
#import "Reachability.h"

@interface NABNetworkEngine : NSObject

/*!
 *  @abstract Initializes your network engine with a hostname and custom header fields
 *  
 *  @discussion
 *	Creates an engine for a given host name
 *  The default headers you specify here will be appened to every operation created in this engine
 *  The hostname, if not null, initializes a Reachability notifier.
 *  Network reachability notifications are automatically taken care of by MKNetworkEngine
 *  Both parameters are optional
 *  
 */
- (id) initWithHostName:(NSString*)hostName customHeaderFields:(NSDictionary*)headers;

/*!
 *  @abstract Creates a simple GET Operation with a request URL
 *  
 *  @discussion
 *	Creates an operation with the given URL path.
 *  The default headers you specified in your MKNetworkEngine subclass gets added to the headers
 *  The HTTP Method is implicitly assumed to be GET
 *  
 */

- (NABNetworkOperation *)operationWithPath:(NSString*)path;

/*!
 *  @abstract Creates a simple GET Operation with a request URL and parameters
 *  
 *  @discussion
 *	Creates an operation with the given URL path.
 *  The default headers you specified in your MKNetworkEngine subclass gets added to the headers
 *  The body dictionary in this method gets attached to the URL as query parameters
 *  The HTTP Method is implicitly assumed to be GET
 *  
 */
- (NABNetworkOperation *)operationWithPath:(NSString*)path
                                  params:(NSMutableDictionary*)body;

/*!
 *  @abstract Creates a simple GET Operation with a request URL, parameters and HTTP Method
 *  
 *  @discussion
 *	Creates an operation with the given URL path.
 *  The default headers you specified in your MKNetworkEngine subclass gets added to the headers
 *  The params dictionary in this method gets attached to the URL as query parameters if the HTTP Method is GET/DELETE
 *  The params dictionary is attached to the body if the HTTP Method is POST/PUT
 *  The HTTP Method is implicitly assumed to be GET
 */
- (NABNetworkOperation *)operationWithPath:(NSString*) path
                                  params:(NSMutableDictionary*) body
                              httpMethod:(NSString*)method;

/*!
 *  @abstract Creates a simple GET Operation with a request URL, parameters, HTTP Method and the SSL switch
 *  
 *  @discussion
 *	Creates an operation with the given URL path.
 *  The ssl option when true changes the URL to https.
 *  The ssl option when false changes the URL to http.
 *  The default headers you specified in your MKNetworkEngine subclass gets added to the headers
 *  The params dictionary in this method gets attached to the URL as query parameters if the HTTP Method is GET/DELETE
 *  The params dictionary is attached to the body if the HTTP Method is POST/PUT
 *  The previously mentioned methods operationWithPath: and operationWithPath:params: call this internally
 */
-(NABNetworkOperation *) operationWithPath:(NSString*) path
                                    params:(NSMutableDictionary*) body
                                httpMethod:(NSString*)method 
                                       ssl:(BOOL) useSSL;

/*!
 *  @abstract Creates a simple GET Operation with a request URL
 *  
 *  @discussion
 *	Creates an operation with the given absolute URL.
 *  The hostname of the engine is *NOT* prefixed
 *  The default headers you specified in your MKNetworkEngine subclass gets added to the headers
 *  The HTTP method is implicitly assumed to be GET.
 */
- (NABNetworkOperation *)operationWithURLString:(NSString*) urlString;

/*!
 *  @abstract Creates a simple GET Operation with a request URL and parameters
 *  
 *  @discussion
 *	Creates an operation with the given absolute URL.
 *  The hostname of the engine is *NOT* prefixed
 *  The default headers you specified in your MKNetworkEngine subclass gets added to the headers
 *  The body dictionary in this method gets attached to the URL as query parameters
 *  The HTTP method is implicitly assumed to be GET.
 */
- (NABNetworkOperation *)operationWithURLString:(NSString*) urlString
                                       params:(NSMutableDictionary*) body;

/*!
 *  @abstract Creates a simple Operation with a request URL, parameters and HTTP Method
 *  
 *  @discussion
 *	Creates an operation with the given absolute URL.
 *  The hostname of the engine is *NOT* prefixed
 *  The default headers you specified in your MKNetworkEngine subclass gets added to the headers
 *  The params dictionary in this method gets attached to the URL as query parameters if the HTTP Method is GET/DELETE
 *  The params dictionary is attached to the body if the HTTP Method is POST/PUT
 *	This method can be over-ridden by subclasses to tweak the operation creation mechanism.
 *  You would typically over-ride this method to create a subclass of MKNetworkOperation (if you have one). After you create it, you should call [super prepareHeaders:operation] to attach any custom headers from super class.
 *  @seealso
 *  prepareHeaders:
 */
- (NABNetworkOperation *)operationWithURLString:(NSString*) urlString
                                       params:(NSMutableDictionary*) body
                                   httpMethod:(NSString*) method;

/*!
 *  @abstract adds the custom default headers
 *  
 *  @discussion
 *	This method adds custom default headers to the factory created MKNetworkOperation.
 *	This method can be over-ridden by subclasses to add more default headers if necessary.
 *  You would typically over-ride this method if you have over-ridden operationWithURLString:params:httpMethod:.
 *  @seealso
 *  operationWithURLString:params:httpMethod:
 */

- (void)prepareHeaders:(NABNetworkOperation *)operation;

- (NABNetworkOperation *)imageAtURL:(NSURL *)url onCompletion:(NABNetworkImageBlock) imageFetchedBlock;

- (void)enqueueOperation:(NABNetworkOperation *)request;

- (void)enqueueOperation:(NABNetworkOperation *)operation forceReload:(BOOL)forceReload;

- (void)cancelAndRemoveOperation:(NABNetworkOperation *)operation;


@property (readonly, strong, nonatomic) NSString *readonlyHostName;
@property (copy, nonatomic) void (^reachabilityChangedHandler)(NetworkStatus ns);

- (void)registerOperationSubclass:(Class) aClass;
- (NSArray *)allOperations;
- (NSString *)cacheDirectoryName;
- (int)cacheMemoryCost;
- (void)useCache;
- (void)emptyCache;

@end
