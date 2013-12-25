//
//  HXQFChartViewLayerDelegate.h
//  ChartGrid
//
//  Created by oybq on 12-7-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HXQFChartView;

@interface HXQFChartViewLayerDelegate : NSObject
{
@private
    
    HXQFChartView *_view;
}

-(id)initWithView:(HXQFChartView*)view;

@end
