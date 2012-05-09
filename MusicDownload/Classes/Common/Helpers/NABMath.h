//
//  NABMath.h
//
//  Created by tkhoa87 on 7/11/11.
//  Copyright (c) 2011 Not A Basement Studio®. All rights reserved.
//

#define RADIANS_TO_DEGREES(radians) ((radians) * (180.0 / M_PI))
#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)


#pragma mark - Definitions

typedef enum {
    CGPolygonTypeConvex = 0, // loi
    CGPolygonTypeConcave = 1 // lo~m
} CGPolygonType;

typedef enum {
    CGThreePointTypeOneLine = 0,
    CGThreePointTypeTurnLeft,
    CGThreePointTypeTurnRight
} CGThreePointType;

typedef struct {
    // These 3 are the basic constants of linear fomular Ax + By + C = 0
    CGFloat A;
    CGFloat B;
    CGFloat C;
} CGLine;

typedef struct {
    // Two ends of the segment
    CGPoint point1;
    CGPoint point2;
} CGLineSegment;


#pragma mark - Methods

CGThreePointType CGStateOfThreePoint(CGPoint O, CGPoint A1, CGPoint A2); // From A1 to A2

BOOL CGFloatApproximateToFloat(CGFloat float1, CGFloat float2);

BOOL CGPointIsLegit(CGPoint point);
BOOL CGPointApproximateToPoint(CGPoint point1, CGPoint point2);
CGFloat CGPointDistanceToPoint(CGPoint point1, CGPoint point2);
CGPoint CGPointFromNSString(NSString *string);

CGLine CGLineMake(CGFloat A, CGFloat B, CGFloat C);
BOOL CGLineContainsPoint(CGLine line, CGPoint point);
CGLine CGLineFromLineSegment(CGLineSegment lineSegment);
CGPoint CGLineIntersection(CGLine line1, CGLine line2);
BOOL CGLineIsLegit(CGLine line);

CGLineSegment CGLineSegmentMake(CGPoint point1, CGPoint point2);
BOOL CGLineSegmentContainsPoint(CGLineSegment lineSegment, CGPoint point, BOOL inclusive);
BOOL CGLineSegmentIsLegit(CGLineSegment lineSegment);
CGPoint CGLineSegmentIntersection(CGLineSegment lineSegment1, CGLineSegment lineSegment2);
CGPoint CGMiddlePointOfLineSegment(CGLineSegment lineSegment);
CGFloat CGLineSegmentAngle(CGLineSegment lineSegment);
CGFloat crossProductZMagnitude(CGLineSegment lineSegment1, CGLineSegment lineSegment2);

CGMutablePathRef CGPathCreateMutableFromPath(NSArray *points);


#pragma mark - Constants

#define CGPointNonLegit         CGPointMake(NAN, NAN)

#define CGLineZero              CGLineMake(0.0f, 0.0f, 0.0f)
#define CGLineNonLegit          CGLineMake(NAN, NAN, NAN)

#define CGLineSegmentZero       CGLineSegmentMake(CGPointZero, CGPointZero)
#define CGLineSegmentNonLegit   CGLineSegmentMake(CGPointNonLegit, CGPointNonLegit)


#pragma mark - DLogs

#ifdef ENABLE_UIKIT_LOG
#define DLogLine(...) NSLog(@"%s (%f, %f, %f)", __PRETTY_FUNCTION__, __VA_ARGS__.A, __VA_ARGS__.B, __VA_ARGS__.C)
#define DLogLineSegment(...) NSLog(@"%s (%f, %f)-(%f, %f)", __PRETTY_FUNCTION__, __VA_ARGS__.point1.x, __VA_ARGS__.point1.y, __VA_ARGS__.point2.x, __VA_ARGS__.point2.y)
#else
#define DLogLine(...) do { } while (0)
#define DLogLineSegment(...) do { } while (0)
#endif


@interface NABMath : NSObject

+ (CGFloat)areaOfPolygonContainsPoints:(NSArray *)points;
+ (NSArray *)pathsBySplittingPath:(NSArray *)path withLineSegment:(CGLineSegment)splitLineSegment;
+ (CGPolygonType)polygonTypeOfShapesWithPath:(NSArray *)path;
+ (CGPoint)pointO1ByUsing3PointsRuleWithA:(CGPoint)A B:(CGPoint)B O:(CGPoint)O A1:(CGPoint)A1 B1:(CGPoint)B1;
+ (NSArray *)intersectsWithPath:(NSArray *)path byLine:(CGLine)line;
+ (BOOL)path:(NSArray *)path containsPoint:(CGPoint)point;

@end