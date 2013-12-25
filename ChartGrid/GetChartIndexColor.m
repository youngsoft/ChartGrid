//
//  GetChartIndexColor.m
//  ChartGrid
//
//  Created by oybq on 12-7-3.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "GetChartIndexColor.h"

static NSArray *chartIndexColorList = nil;


@implementation GetChartIndexColor


+ (NSArray *)getChartIndexColorList
{
    if (chartIndexColorList == nil)
    {
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"chartIndexColorList" ofType:@"plist"];

        BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:plistPath];
        if (isExist)
        {
            NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:plistPath];
            chartIndexColorList = [[NSArray alloc] initWithArray:[dict objectForKey:@"IndexColorList"]];
        }
        
    }
    return chartIndexColorList;
}

+ (NSArray *)getChartIndexColorAtIndex:(NSInteger)aIndex
{    
    NSArray *allColorArray = [GetChartIndexColor getChartIndexColorList];
    
    NSInteger curIndex = aIndex%[allColorArray count];
    
    NSArray *colorArray = (NSArray *)[allColorArray objectAtIndex:curIndex];
    
    NSDictionary *startDict = (NSDictionary *)[colorArray objectAtIndex:0];
    NSDictionary *endDict = (NSDictionary *)[colorArray objectAtIndex:1];
    
    NSString *startRed = [startDict objectForKey:@"r"];
    NSString *startGreen = [startDict objectForKey:@"g"];
    NSString *startBlue = [startDict objectForKey:@"b"];
    
    UIColor *startColor = [UIColor colorWithRed:[startRed floatValue]/255.0 
                                          green:[startGreen floatValue]/255.0 
                                           blue:[startBlue floatValue]/255.0 
                                          alpha:1.0];
    
    NSString *endRed = [endDict objectForKey:@"r"];
    NSString *endGreen = [endDict objectForKey:@"g"];
    NSString *endBlue = [endDict objectForKey:@"b"];
    
    UIColor *endColor = [UIColor colorWithRed:[endRed floatValue]/255.0 
                                        green:[endGreen floatValue]/255.0 
                                         blue:[endBlue floatValue]/255.0 
                                        alpha:1.0];
    
    return [NSArray arrayWithObjects:startColor, endColor, nil];
}

@end
