//
//  HXQFChartViewLayerDelegate.m
//  ChartGrid
//
//  Created by oybq on 12-7-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "HXQFChartViewLayerDelegate.h"
#import "HXQFChartView.h"

@implementation HXQFChartViewLayerDelegate

-(id)initWithView:(HXQFChartView*)view
{
    self = [self init];
    if (self != nil)
    {
        _view = view;
    }
    
    return  self;
}

-(void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx
{
    [_view drawChartLayer:layer inContext:ctx];
}

@end
