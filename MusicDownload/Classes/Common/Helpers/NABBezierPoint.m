//
//  NABPathPoint.m
//  Mahattan
//
//  Created by Phan Tran Le Nguyen on 11/8/11.
//  Copyright (c) 2011 Not A Basement Studio®. All rights reserved.
//

#define kNABBezierPointMainPoint @"MainPoint"
#define kNABBezierPointFirstAnchorPoint @"FirstAnchorPoint"
#define kNABBezierPointSecondAnchorPoint @"SecondAnchorPoint"

#import "NABBezierPoint.h"
#import "NABMath.h"

@implementation NABBezierPoint

@synthesize mainPoint           = _mainPoint;
@synthesize firstAnchorPoint    = _firstAnchorPoint;
@synthesize secondAnchorPoint   = _secondAnchorPoint;


- (void)setUpBezierPoint {
    
    _mainPoint = CGPointZero;
    _firstAnchorPoint = CGPointNonLegit;
    _secondAnchorPoint = CGPointNonLegit;
    
}


#pragma mark - init

- (id)init {
    self = [super init];
    if (self) {
        [self setUpBezierPoint];
    }
    return self;
}

- (id)initWithMainPoint:(CGPoint)mainPoint firstAnchorPoint:(CGPoint)firstAnchorPoint secondAnchorPoint:(CGPoint)secondAnchorPoint {
    self = [super init];
    
    if (self) {
        [self setUpBezierPoint];
        
        _mainPoint = mainPoint;
        _firstAnchorPoint = firstAnchorPoint;
        _secondAnchorPoint = secondAnchorPoint;
    }
    
    return self;
}


#pragma mark - NSCoder Compliant

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    
    if (self) {
        _mainPoint = [aDecoder decodeCGPointForKey:kNABBezierPointMainPoint];
        _firstAnchorPoint = [aDecoder decodeCGPointForKey:kNABBezierPointFirstAnchorPoint];
        _secondAnchorPoint = [aDecoder decodeCGPointForKey:kNABBezierPointSecondAnchorPoint];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeCGPoint:_mainPoint forKey:kNABBezierPointMainPoint];
    [aCoder encodeCGPoint:_firstAnchorPoint forKey:kNABBezierPointFirstAnchorPoint];
    [aCoder encodeCGPoint:_secondAnchorPoint forKey:kNABBezierPointSecondAnchorPoint];
}


#pragma mark - Plist Compliant

+ (NABBezierPoint *)bezierPointFromDictionary:(NSDictionary *)dictionary {
    NABBezierPoint *bezierPoint = [[NABBezierPoint alloc] init];
    
    bezierPoint.mainPoint = CGPointFromNSString([dictionary objectForKey:kNABBezierPointMainPoint]);
    bezierPoint.firstAnchorPoint = CGPointFromNSString([dictionary objectForKey:kNABBezierPointFirstAnchorPoint]);
    bezierPoint.secondAnchorPoint = CGPointFromNSString([dictionary objectForKey:kNABBezierPointSecondAnchorPoint]);
    
    return bezierPoint;
}


#pragma mark - Duplicate

- (NABBezierPoint *)duplicate {
    NABBezierPoint *newPoint = [[NABBezierPoint alloc] initWithMainPoint:_mainPoint firstAnchorPoint:_firstAnchorPoint secondAnchorPoint:_secondAnchorPoint];
    return newPoint;
}


@end


@implementation NSDictionary(NABBezierPoint)

+ (NSDictionary *)dictionaryFromBezierPoint:(NABBezierPoint *)bezierPoint {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    
    [dictionary setObject:NSStringFromCGPoint(bezierPoint.mainPoint) forKey:kNABBezierPointMainPoint];
    [dictionary setObject:NSStringFromCGPoint(bezierPoint.firstAnchorPoint) forKey:kNABBezierPointFirstAnchorPoint];
    [dictionary setObject:NSStringFromCGPoint(bezierPoint.secondAnchorPoint) forKey:kNABBezierPointSecondAnchorPoint];
    
    return dictionary;
}

@end