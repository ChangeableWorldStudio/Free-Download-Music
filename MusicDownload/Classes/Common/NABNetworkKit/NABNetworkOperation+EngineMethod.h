//
//  NABNetworkOperation+EngineMethod.h
//  NABNetworkKit
//
//  Created by Phan Tran Le Nguyen on 12/11/11.
//  Copyright (c) 2011 Not A Basement Studio®. All rights reserved.
//
#import "NABNetworkOperation.h"

@interface NABNetworkOperation (EngineMethod)

- (void)setCachedData:(NSData *)cachedData;
- (void)setCacheHandler:(NABNetworkResponseBlock)cacheHandler;
- (void)updateHandlersFromOperation:(NABNetworkOperation *)operation;
- (void)updateOperationBasedOnPreviousHeaders:(NSMutableDictionary *)headers;
- (NSString *)uniqueIdentifier;

- (id)initWithURLString:(NSString *)aURLString params:(NSMutableDictionary *)params httpMethod:(NSString *)method;

@end
