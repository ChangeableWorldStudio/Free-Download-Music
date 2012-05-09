//
//  NABMath.m
//  NABCollageCutView
//
//  Created by tkhoa87 on 7/11/11.
//  Copyright (c) 2011 Not A Basement Studio®. All rights reserved.
//

#import "NABMath.h"
#import "NABBezierPoint.h"

#define CGFLOAT_ERROR   0.01f



CGThreePointType CGStateOfThreePoint(CGPoint O, CGPoint A1, CGPoint A2) {
    CGThreePointType type = CGThreePointTypeOneLine;
    
    CGFloat x1 = A1.x - O.x;
    CGFloat y1 = A1.y - O.y;
    
    CGFloat x2 = A2.x - O.x;
    CGFloat y2 = A2.y - O.y;
    
    CGFloat fResult = x1*y2 - x2*y1;
    
    if (fResult < 0) {
        type = CGThreePointTypeTurnLeft;
    } else if (fResult > 0) {
        type = CGThreePointTypeTurnRight;
    }
    
    return type;
}

#pragma mark - Float

BOOL CGFloatApproximateToFloat(CGFloat float1, CGFloat float2) {
    return ABS(float1 - float2) < CGFLOAT_ERROR;
}


#pragma mark - Point

BOOL CGPointIsLegit(CGPoint point) {
    return !isnan(point.x) && !isnan(point.y);
}

BOOL CGPointApproximateToPoint(CGPoint point1, CGPoint point2) {
    return CGFloatApproximateToFloat(point1.x, point2.x) && CGFloatApproximateToFloat(point1.y, point2.y);
}

CGFloat CGPointDistanceToPoint(CGPoint point1, CGPoint point2) {
    if (CGPointIsLegit(point1) && CGPointIsLegit(point2)) {
        return sqrtf(powf(point1.x - point2.x, 2.0f) + powf(point1.y - point2.y, 2.0f));
    } else {
        return NAN;
    }
}

CGPoint CGPointFromNSString(NSString *string) {
    NSString *stringWithoutBrackets = [string stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"{}"]];
    NSArray *components = [stringWithoutBrackets componentsSeparatedByString:@","];
    
    CGPoint point = CGPointNonLegit;
    
    NSString *stringX = [components objectAtIndex:0];
    if (![stringX isEqualToString:@"nan"]) {
        point.x = [stringX floatValue];
    }
    
    NSString *stringY = [components objectAtIndex:1];
    if (![stringY isEqualToString:@"nan"]) {
        point.y = [stringY floatValue];
    }
    
    return point;
}


#pragma mark - Line

CGLine CGLineMake(CGFloat A, CGFloat B, CGFloat C) {
    CGLine line;
    line.A = A;
    line.B = B;
    line.C = C;
    return line;
}

BOOL CGLineContainsPoint(CGLine line, CGPoint point) {
    if (CGLineIsLegit(line) && CGPointIsLegit(point)) {
        return ABS(line.A * point.x + line.B * point.y + line.C) <= 3.0f;
    } else {
        return NO;
    }
}

CGLine CGLineFromLineSegment(CGLineSegment lineSegment) {
    CGLine line;
    
    if (lineSegment.point1.x == lineSegment.point2.x) {
        
        if (lineSegment.point1.y == lineSegment.point2.y) {
            // Not a line
            line = CGLineNonLegit;
        } else {
            line.A = lineSegment.point2.y - lineSegment.point1.y;
            line.B = 0.0f;
            line.C = - line.A * lineSegment.point1.x;
        }
        
    } else {
        line.A = lineSegment.point2.y - lineSegment.point1.y;
        line.B = lineSegment.point1.x - lineSegment.point2.x;
        line.C = - line.A * lineSegment.point1.x - line.B * lineSegment.point1.y;
    }
    
    return line;
}

CGPoint CGMiddlePointOfLineSegment(CGLineSegment lineSegment) {
    return CGPointMake((lineSegment.point1.x + lineSegment.point2.x) / 2, (lineSegment.point1.y + lineSegment.point2.y) / 2);
}

CGPoint CGLineIntersection(CGLine line1, CGLine line2) {
    if (CGLineIsLegit(line1) && CGLineIsLegit(line2)) {
        
        CGFloat constant = line2.A * line1.B - line1.A * line2.B;
        if (constant == 0.0f) {
            // Parallel
            return CGPointNonLegit;
        } else {
            CGPoint point;
            // Split into cases like this to prevent FLOAT ERRORS when dividing
            if (line1.A == 0.0f) {
                point.y = - line1.C / line1.B;
                point.x = - (line2.C + line2.B * point.y) / line2.A;
            } else if (line1.B == 0.0f) {
                point.x = - line1.C / line1.A;
                point.y = - (line2.C + line2.A * point.x) / line2.B;
            } else if (line2.A == 0.0f) {
                point.y = - line2.C / line2.B;
                point.x = - (line1.C + line1.B * point.y) / line1.A;
            } else if (line2.B == 0.0f) {
                point.x = - line2.C / line2.A;
                point.y = - (line1.C + line1.A * point.x) / line1.B;
            } else {
                point.x = (line2.B * line1.C - line1.B * line2.C) / constant;
                point.y = - (line1.C + line1.A * point.x) / line1.B;
            }
            return point;
        }
        
    } else {
        return CGPointNonLegit;
    }
}

BOOL CGLineIsLegit(CGLine line) {
    return !isnan(line.A) && !isnan(line.B) && !isnan(line.C) && ((line.A != 0.0f) || (line.B != 0.0f));
}


#pragma mark - Line Segment

CGLineSegment CGLineSegmentMake(CGPoint point1, CGPoint point2) {
    CGLineSegment lineSegment;
    lineSegment.point1 = point1;
    lineSegment.point2 = point2;
    return lineSegment;
}

BOOL CGLineSegmentContainsPoint(CGLineSegment lineSegment, CGPoint point, BOOL inclusive) {
    if (CGLineSegmentIsLegit(lineSegment) && CGPointIsLegit(point)) {
        CGLine line = CGLineFromLineSegment(lineSegment);
        
        CGFloat minX = MIN(lineSegment.point1.x, lineSegment.point2.x);
        CGFloat maxX = MAX(lineSegment.point1.x, lineSegment.point2.x);
        CGFloat minY = MIN(lineSegment.point1.y, lineSegment.point2.y);
        CGFloat maxY = MAX(lineSegment.point1.y, lineSegment.point2.y);
        
        if (inclusive) {
            return CGLineContainsPoint(line, point) && (point.x >= minX-CGFLOAT_ERROR) && (point.x <= maxX+CGFLOAT_ERROR) && (point.y >= minY-CGFLOAT_ERROR) && (point.y <= maxY+CGFLOAT_ERROR);
        } else {
            return CGLineContainsPoint(line, point) && (point.x > minX-CGFLOAT_ERROR) && (point.x < maxX+CGFLOAT_ERROR) && (point.y > minY-CGFLOAT_ERROR) && (point.y < maxY+CGFLOAT_ERROR);
        }
    } else {
        return NO;
    }
}

BOOL CGLineSegmentIsLegit(CGLineSegment lineSegment) {
    return CGPointIsLegit(lineSegment.point1) && CGPointIsLegit(lineSegment.point2) && ((lineSegment.point1.x != lineSegment.point2.x) || (lineSegment.point1.y != lineSegment.point2.y));
}

CGPoint CGLineSegmentIntersection(CGLineSegment lineSegment1, CGLineSegment lineSegment2) {
    CGLine line1 = CGLineFromLineSegment(lineSegment1);
    CGLine line2 = CGLineFromLineSegment(lineSegment2);
    CGPoint intersection = CGLineIntersection(line1, line2);
    if (CGPointIsLegit(intersection) && CGLineSegmentContainsPoint(lineSegment1, intersection, YES) && CGLineSegmentContainsPoint(lineSegment2, intersection, YES)) {
        return intersection;
    } else {
        return CGPointNonLegit;
    }
}

CGFloat CGLineSegmentAngle(CGLineSegment lineSegment) {
    
    CGFloat opposite = lineSegment.point2.y - lineSegment.point1.y;
    CGFloat adjacent = lineSegment.point2.x - lineSegment.point1.x;
    CGFloat hypotenuse = sqrtf(powf(opposite, 2.0f) + powf(adjacent, 2.0f));
    
    if (hypotenuse == 0.0f) {
        return NAN;
    } else {
        CGFloat angle = acosf(adjacent / hypotenuse);
        if (opposite < 0.0f) {
            angle = -angle;
        }
        return angle;
    }
    
}

CGFloat crossProductZMagnitude(CGLineSegment lineSegment1, CGLineSegment lineSegment2) {
    // See http://en.wikipedia.org/wiki/Cross_product
    
    double a1 = lineSegment1.point2.x - lineSegment1.point1.x;
    double a2 = lineSegment1.point2.y - lineSegment1.point1.y;
    double b1 = lineSegment2.point2.x - lineSegment2.point1.x;
    double b2 = lineSegment2.point2.y - lineSegment2.point1.y;
    
    return a1 * b2 - a2 * b1;
    
}


#pragma mark - Path

CGMutablePathRef CGPathCreateMutableFromPath(NSArray *points) {
    
    CGMutablePathRef path = CGPathCreateMutable();
    
    NABBezierPoint *lastPoint = [points lastObject];
    CGPathMoveToPoint(path, nil, lastPoint.mainPoint.x, lastPoint.mainPoint.y);
    
    for (NABBezierPoint *point in [NSArray arrayWithArray:points]) {
        CGPathAddLineToPoint(path, nil, point.mainPoint.x, point.mainPoint.y);
    }
    
    CGPathCloseSubpath(path);
    
    return path;
    
}


#pragma mark - NABMath

@implementation NABMath

+ (CGFloat)areaOfPolygonContainsPoints:(NSArray *)points {
    if ([points count] > 0) {
        id firstObject = [points objectAtIndex:0];
        
        CGFloat area = 0.0f;
        
        if ([firstObject isKindOfClass:[NABBezierPoint class]]) {
            for (int i = 0; i < [points count]; i++) {
                NABBezierPoint *pointi = [points objectAtIndex:i];
                NABBezierPoint *pointiPlus1 = i == [points count] - 1 ? [points objectAtIndex:0] : [points objectAtIndex:i + 1];
                
                float xi = pointi.mainPoint.x;
                float xiPlus1 = pointiPlus1.mainPoint.x;
                float yi = pointi.mainPoint.y;
                float yiPlus1 = pointiPlus1.mainPoint.y;
                
                area += xi * yiPlus1 - xiPlus1 * yi;
            }
        } else if ([firstObject isKindOfClass:[NSValue class]]) {
            for (int i = 0; i < [points count]; i++) {
                CGPoint pointi = [[points objectAtIndex:i] CGPointValue];
                CGPoint pointiPlus1 = i == [points count] - 1 ? [[points objectAtIndex:0] CGPointValue] : [[points objectAtIndex:i + 1] CGPointValue];
                
                float xi = pointi.x;
                float xiPlus1 = pointiPlus1.x;
                float yi = pointi.y;
                float yiPlus1 = pointiPlus1.y;
                
                area += xi * yiPlus1 - xiPlus1 * yi;
            }
        }
        
        area = area / 2.0f;
        
        return area;
        
    } else {
        return 0.0f;
    }
}

+ (NSArray *)pathsBySplittingPath:(NSArray *)path withLineSegment:(CGLineSegment)splitLineSegment {
    
    //DLog(@"Split lineSegment");
    //DLogLineSegment(splitLineSegment);
    
    CGLineSegment lineSegments[1000];
    int lineSegmentsCount = 0;
    
    CGPoint intersections[1000];
    int intersectionsCount = 0;
    
    
    // STEP 1: Find lineSegments from path
    
    NABBezierPoint *lastPoint = [path lastObject];
    for (NABBezierPoint *point in [NSArray arrayWithArray:path]) {
        CGLineSegment lineSegment = CGLineSegmentMake(lastPoint.mainPoint, point.mainPoint);
        //DLog(@"Checking");
        //DLogLineSegment(lineSegment);
        CGPoint intersection = CGLineSegmentIntersection(lineSegment, splitLineSegment);
        if (CGPointIsLegit(intersection)) {
            
            // Round up values
            intersection.x = roundf(intersection.x);
            intersection.y = roundf(intersection.y);
            
            // Add the point into list
            BOOL alreadyExists = NO;
            for (int i = 0; i < intersectionsCount; i++) {
                if (CGPointEqualToPoint(intersection, intersections[i])) {
                    alreadyExists = YES;
                    break;
                }
            }
            if (!alreadyExists) {
                //DLog(@"Add intersection");
                //DLogPoint(intersection);
                intersections[intersectionsCount] = intersection;
                intersectionsCount++;
            }
            
            // Add line segments into list
            //DLog(@"Add line");
            if (CGPointEqualToPoint(intersection, lastPoint.mainPoint) || CGPointEqualToPoint(intersection, point.mainPoint)) {
                //DLogLineSegment(lineSegment);
                lineSegments[lineSegmentsCount] = lineSegment;
                lineSegmentsCount++;
            } else {
                //DLogLineSegment(CGLineSegmentMake(lastPoint.mainPoint, intersection));
                lineSegments[lineSegmentsCount] = CGLineSegmentMake(lastPoint.mainPoint, intersection);
                lineSegmentsCount++;
                //DLogLineSegment(CGLineSegmentMake(intersection, point.mainPoint));
                lineSegments[lineSegmentsCount] = CGLineSegmentMake(intersection, point.mainPoint);
                lineSegmentsCount++;
            }
            
        } else {
            
            //DLog(@"Add line");
            //DLogLineSegment(lineSegment);
            lineSegments[lineSegmentsCount] = lineSegment;
            lineSegmentsCount++;
            
        }
        lastPoint = point;
    }
    
    if (intersectionsCount <= 0) return nil;
    
    
    // STEP 2: Find lineSegments from intersects
    
    if (intersectionsCount > 1) {
        
        // Sort intersections
        //DLog(@"Sorting");
        if (intersections[0].x != intersections[1].x) {
            for (int i=0; i<intersectionsCount-1; i++) {
                for (int j=i+1; j<intersectionsCount; j++) {
                    if (intersections[i].x > intersections[j].x) {
                        CGPoint temp = intersections[i];
                        intersections[i] = intersections[j];
                        intersections[j] = temp;
                    }
                }
            }
        } else {
            for (int i=0; i<intersectionsCount-1; i++) {
                for (int j=i+1; j<intersectionsCount; j++) {
                    if (intersections[i].y > intersections[j].y) {
                        CGPoint temp = intersections[i];
                        intersections[i] = intersections[j];
                        intersections[j] = temp;
                    }
                }
            }
        }
        
        // Add lineSegments
        CGPathRef CGPath = CGPathCreateMutableFromPath(path);
        for (int i=1; i<intersectionsCount; i++) {
            CGPoint midPoint = CGPointMake((intersections[i-1].x + intersections[i].x)/2.0f, (intersections[i-1].y + intersections[i].y)/2.0f);
            if (CGPathContainsPoint(CGPath, nil, midPoint, NO)) {
                //DLog(@"Add line");
                //DLogLineSegment(CGLineSegmentMake(intersections[i-1], intersections[i]));
                lineSegments[lineSegmentsCount] = CGLineSegmentMake(intersections[i-1], intersections[i]);
                lineSegmentsCount++;
                //DLogLineSegment(CGLineSegmentMake(intersections[i], intersections[i-1]));
                lineSegments[lineSegmentsCount] = CGLineSegmentMake(intersections[i], intersections[i-1]);
                lineSegmentsCount++;
            }
        }
        CGPathRelease(CGPath);
        
    }
    
    
    // STEP 3: Find the shapes
    
    BOOL lineChosen[lineSegmentsCount];
    for (int i=0; i<lineSegmentsCount; i++) {
        lineChosen[i] = NO;
    }
    
    //DLog(@"%d", intersectionsCount);
    //DLog(@"%d", lineSegmentsCount);
    
    NSMutableArray *newPaths = [[NSMutableArray alloc] init];
    
    for (int i=0; i<lineSegmentsCount-1; i++) {
        if (!lineChosen[i]) {
            lineChosen[i] = YES;
            
            int previousLine[lineSegmentsCount];
            int steps[lineSegmentsCount];
            for (int j=i; j<lineSegmentsCount; j++) {
                previousLine[j] = -1;
                steps[j] = INT_MAX;
            }
            steps[i] = 0;
            
            CGPoint targetPoint = lineSegments[i].point1;
            
            // Breadth First Search
            int queue[lineSegmentsCount];
            queue[0] = i;
            int count = 1;
            int j = 0;
            
            int found = -1;
            while (j < count) {
                CGLineSegment lineSegment = lineSegments[queue[j]];
                int step = steps[queue[j]] + 1;
                //DLog(@"Step 3 Checking");
                //DLogLineSegment(lineSegment);
                for (int k=i+1; k<lineSegmentsCount; k++) {
                    if (!lineChosen[k] && CGPointEqualToPoint(lineSegment.point2, lineSegments[k].point1) && !CGPointEqualToPoint(lineSegment.point1, lineSegments[k].point2) && (step < steps[k])) {
                        //DLogLineSegment(lineSegments[k]);
                        previousLine[k] = queue[j];
                        steps[k] = step;
                        if (CGPointEqualToPoint(lineSegments[k].point2, targetPoint)) {
                            found = k;
                            break;
                        } else {
                            queue[count] = k;
                            count++;
                        }
                    }
                }
                if (found != -1) {
                    break;
                }
                j++;
            }
            
            // Trace back for new path
            if (found == -1) {
                DLog(@"Error");
            } else {
                NSMutableArray *newPath = [[NSMutableArray alloc] init];
                
                while (found != -1) {
                    lineChosen[found] = YES;
                    
                    CGLineSegment lineSegment = lineSegments[found];
                    //DLogLineSegment(lineSegment);
                    
                    NABBezierPoint *point = [[NABBezierPoint alloc] initWithMainPoint:lineSegment.point1 firstAnchorPoint:CGPointNonLegit secondAnchorPoint:CGPointNonLegit];
                    [newPath addObject:point];
                    
                    found = previousLine[found];
                }
                
                [newPaths addObject:newPath];
            }
            
        }
    }
    
    return [NSArray arrayWithArray:newPaths];
    
}

+ (CGPolygonType)polygonTypeOfShapesWithPath:(NSArray *)path {
//    CGPolygonType type = CGPolygonTypeConvex;
    CGThreePointType firstMove = CGThreePointTypeOneLine;
    
    NSArray *pointArray = [NSArray arrayWithArray:path];
    int count = 0;
    
    for (NABBezierPoint *point in pointArray) {
        
        CGPoint O = point.mainPoint;
        CGPoint A1;
        CGPoint A2;
        
        if (count == [pointArray count] - 2) {
            A1 = ((NABBezierPoint *)[pointArray objectAtIndex:count + 1]).mainPoint;
            A2 = ((NABBezierPoint *)[pointArray objectAtIndex:0]).mainPoint;
        } else if (count == [pointArray count] - 1) {
            A1 = ((NABBezierPoint *)[pointArray objectAtIndex:0]).mainPoint;
            A2 = ((NABBezierPoint *)[pointArray objectAtIndex:1]).mainPoint;
        } else {
            A1 = ((NABBezierPoint *)[pointArray objectAtIndex:count + 1]).mainPoint;
            A2 = ((NABBezierPoint *)[pointArray objectAtIndex:count + 2]).mainPoint;
        }
        
        CGThreePointType currentType = CGStateOfThreePoint(O, A1, A2);
        
        if (firstMove == CGThreePointTypeOneLine) {
            firstMove = currentType;
        } else {
            if (currentType != firstMove) {
                return CGPolygonTypeConcave;
            }
        }
        
        count++;
    }
    
    return CGPolygonTypeConvex;
}

+ (CGPoint)pointO1ByUsing3PointsRuleWithA:(CGPoint)A B:(CGPoint)B O:(CGPoint)O A1:(CGPoint)A1 B1:(CGPoint)B1 {
    
    CGLine AB = CGLineFromLineSegment(CGLineSegmentMake(A, B));
    
    CGLine OH = CGLineMake(-AB.B, AB.A, 0.0f);
    OH.C = -OH.A * O.x - OH.B * O.y;
    
    CGPoint H = CGLineIntersection(AB, OH);
    
    CGFloat dOH = CGPointDistanceToPoint(O, H);
    CGFloat dAB = CGPointDistanceToPoint(A, B);
    CGFloat dA1B1 = CGPointDistanceToPoint(A1, B1);
    CGFloat dO1H1 = dOH * dA1B1 / dAB;
    
    CGFloat AHoverAB = A.x != B.x ? (H.x - A.x)/(B.x - A.x) : (H.y - A.y)/(B.y - A.y);
    CGPoint H1 = CGPointMake(AHoverAB * (B1.x - A1.x) + A1.x, AHoverAB * (B1.y - A1.y) + A1.y);
    
    CGLine A1B1 = CGLineFromLineSegment(CGLineSegmentMake(A1, B1));

    CGLine O1H1 = CGLineMake(-A1B1.B, A1B1.A, 0.0f);
    O1H1.C = -O1H1.A * H1.x - O1H1.B * H1.y;
    
    CGPoint O1a = CGPointNonLegit;
    CGPoint O1b = CGPointNonLegit;
    
    if (O1H1.B == 0) {
        
        O1a.x = -O1H1.C / O1H1.A;
        O1a.y = H1.y + sqrt(pow(dO1H1, 2) - pow(H1.x + O1H1.C / O1H1.A, 2));
        
        O1b.x = O1a.x;
        O1b.y = H1.y - sqrt(pow(dO1H1, 2) - pow(H1.x + O1H1.C / O1H1.A, 2));
        
    } else {
        
        O1a.x = H1.x + dO1H1 * O1H1.B / sqrt(pow(O1H1.A, 2) + pow(O1H1.B, 2));
        O1a.y = (-O1H1.A * O1a.x - O1H1.C) / O1H1.B;
        
        O1b.x = H1.x - dO1H1 * O1H1.B / sqrt(pow(O1H1.A, 2) + pow(O1H1.B, 2));
        O1b.y = (-O1H1.A * O1b.x - O1H1.C) / O1H1.B;
        
    }
    
    CGFloat cross1 = crossProductZMagnitude(CGLineSegmentMake(A, B), CGLineSegmentMake(A, O));
    CGFloat cross2 = crossProductZMagnitude(CGLineSegmentMake(A1, B1), CGLineSegmentMake(A1, O1a));
    
    if (cross1 * cross2 >= 0) {
        return O1a;
    } else {
        return O1b;
    }
    
}

+ (NSArray *)intersectsWithPath:(NSArray *)path byLine:(CGLine)splitLine {
    NSMutableArray *intersects = [[NSMutableArray alloc] init];
    NABBezierPoint *lastPoint = [path lastObject];
    for (NABBezierPoint *point in [NSArray arrayWithArray:path]) {
        CGLineSegment lineSegment = CGLineSegmentMake(lastPoint.mainPoint, point.mainPoint);
        CGLine line = CGLineFromLineSegment(lineSegment);
        
        CGPoint intersect = CGLineIntersection(line, splitLine);
        if (CGLineSegmentContainsPoint(lineSegment, intersect, YES)) {
            [intersects addObject:[NSValue valueWithCGPoint:intersect]];
        }
        
        lastPoint = point;
    }
    return intersects;
}

+ (BOOL)path:(NSArray *)path containsPoint:(CGPoint)point {
    CGMutablePathRef CGPath = CGPathCreateMutableFromPath(path);
    BOOL contain = CGPathContainsPoint(CGPath, nil, point, NO);
    CGPathRelease(CGPath);
    return contain;
}


@end