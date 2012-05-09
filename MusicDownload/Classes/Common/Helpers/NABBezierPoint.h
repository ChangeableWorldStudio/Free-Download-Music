//
//  NABPathPoint.h
//  Mahattan
//
//  Created by Phan Tran Le Nguyen on 11/8/11.
//  Copyright (c) 2011 Not A Basement Studio®. All rights reserved.
//


@interface NABBezierPoint : NSObject <NSCoding>

@property (nonatomic) CGPoint mainPoint;
@property (nonatomic) CGPoint firstAnchorPoint;
@property (nonatomic) CGPoint secondAnchorPoint;

- (id)initWithMainPoint:(CGPoint)mainPoint firstAnchorPoint:(CGPoint)firstAnchorPoint secondAnchorPoint:(CGPoint)secondAnchorPoint;

+ (NABBezierPoint *)bezierPointFromDictionary:(NSDictionary *)dictionary;

- (NABBezierPoint *)duplicate;

@end


@interface NSDictionary(NABBezierPoint)

+ (NSDictionary *)dictionaryFromBezierPoint:(NABBezierPoint *)bezierPoint;

@end