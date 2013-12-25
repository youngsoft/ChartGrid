//
//  ChartView.m
//  ChartGrid
//
//  Created by oybq on 12-7-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ChartView.h"

NSString *DeleteZero(NSString *string)
{
    NSString *newstring = nil;
    NSInteger i = 0;
    NSInteger deleteindex = 0;
    NSInteger pointIndex = 0;
    BOOL isneedDelete = NO;
	for (i= 0; i<string.length; i++)
	{
        unichar a = [string characterAtIndex:i];
        if (a == 46)
        {
            pointIndex = i;
            isneedDelete = YES;
            break;
        }
    }
    if (isneedDelete)
    {
        for (i = string.length -1; i >= pointIndex ; i-- )
        {
            unichar a = [string characterAtIndex:i];
            if (a != 46 && a != 48)
            {
                deleteindex = i;
                isneedDelete = NO;
                break;
            }
        }
        if (deleteindex == 0)
        {
            deleteindex = pointIndex-1;
        }
        newstring = [string substringToIndex:deleteindex+1];
    }
    else
    {
        newstring = string;
    }
    
    return newstring;
}

@interface ChartViewLayerDelegate : NSObject
{
@private
    
    ChartView *_view;
}

-(id)initWithView:(ChartView*)view;

@end



@implementation ChartViewLayerDelegate

-(id)initWithView:(ChartView*)view
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



@interface ChartView(Pravite)

- (void)changeFloatViewFrame;


@end

@implementation ChartView

@synthesize dataSource = _dataSource;

@synthesize indexCount = _indexCount;
@synthesize measureCount = _measureCount;

@synthesize chartType = _chartType;

@synthesize showMajorTitle;
@synthesize showMinorTitle;

@synthesize showYaxisTitle;
@synthesize showYaxisScaleLine;

@synthesize showXaxisTitle;

@synthesize showCutline;
@synthesize showValuePoint;
@synthesize closedLine;
@synthesize showValue;

@synthesize showIndicator;

@synthesize chartOffset;

#pragma mark - UIGestureRecognizer


- (void)dealWithchange:(CGPoint)aPoint  //处理移动事件
{
    //如果没有指标则不计算。
    if (_indexCount == 0)
        return;
    
    //计算
    //  NSInteger modX = (_measureWidth * _measureUnit + _measureSpacing);
    
    NSInteger tempMeasureIndex =  floorf((aPoint.x - CHARTVIEW_LEFTINSET_WIDTH) / (_measureUnit * _measureWidth + _measureSpacing));
    
    //  NSLog(@"aPoint:%f index:%d",aPoint.x, tempMeasureIndex);
    
    if (tempMeasureIndex < _measureCount && tempMeasureIndex >= 0)
    {
        BOOL mustReload = (tempMeasureIndex != _showFloatIndex);
        _showFloatIndex = tempMeasureIndex;
        [self showDetailFloatView:mustReload];
    }
    else 
        _showFloatIndex = -1;
}


-(void)handlePanGestureRecognizer:(UIPanGestureRecognizer*)gestureRecognizer
{
    if (_chartType == ChartTypePie)
        return;
    
   
    static BOOL bStartIndicatorMove = NO;
    static BOOL bStartValueLayerMove = NO;
    static CGFloat ptLastTranslationX = 0;
    
    
    
    CGPoint ptTranslation = [gestureRecognizer translationInView:self];
    CGPoint ptLocation = [gestureRecognizer locationInView:self];
    
 
    CGFloat minOffsetX = 0;
    CGFloat maxOffsetX = CHARTVIEW_LEFTINSET_WIDTH + _measureCount * (_measureUnit * _measureWidth + _measureSpacing) + CHARTVIEW_RIGHTINSET_WIDTH - _valueLayer.bounds.size.width;
    if (maxOffsetX < 0)
        maxOffsetX = 0;
    
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
        //判断当前的位置
        //这里位置往上调整一下
        if (CGRectContainsPoint(CGRectMake(_valueRect.origin.x, _valueRect.origin.y, _valueRect.size.width, _valueRect.size.height - 50), ptLocation))
        {
            if (_valueLayer.visibleRect.origin.x >= minOffsetX && _valueLayer.visibleRect.origin.x <= maxOffsetX)
            {
                bStartValueLayerMove = YES;
                ptLastTranslationX = 0;
            }
        }
        else if (CGRectContainsPoint(CGRectMake(_indicatorLayer.frame.origin.x, _indicatorLayer.frame.origin.y - 50, _indicatorLayer.frame.size.width, _indicatorLayer.frame.size.height + 50), ptLocation))  //这里位置往下调整一下。
        {
            bStartIndicatorMove = YES;
        }

    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateChanged)
    {
        if (bStartValueLayerMove)
        {
            CGFloat newOffset = _valueLayer.visibleRect.origin.x - (ptTranslation.x - ptLastTranslationX);
            if (newOffset >= minOffsetX && newOffset <= maxOffsetX)
            {
                [_valueLayer scrollToPoint:CGPointMake(newOffset, 0)];
                            
            }
            else if (newOffset < minOffsetX)
            {
                [_valueLayer scrollToPoint:CGPointMake(minOffsetX, 0)];
            }
            else if (newOffset > maxOffsetX)
            {
                [_valueLayer scrollToPoint:CGPointMake(maxOffsetX, 0)];
            }
            
            [self reloadData];
                      
            ptLastTranslationX = ptTranslation.x;
        }
        if (bStartIndicatorMove)
        {

            CALayer *sublayer = [_indicatorLayer.sublayers objectAtIndex:0];
            
            //计算
            
            //把ptStart转化为某个层的
            
            
           CGPoint ptIndicatorLocation = [self.layer convertPoint:ptLocation toLayer:_indicatorLayer];
            if (ptIndicatorLocation.x >=10 && ptIndicatorLocation.x <= _indicatorLayer.bounds.size.width - 10 - 6)
            {
                CGFloat width = CHARTVIEW_XAXISINDICATOR_HEIGHT*0.8 * tanf(30*3.14159265358/180);
                
                sublayer.frame = CGRectMake(ptIndicatorLocation.x - width - 6, sublayer.frame.origin.y, sublayer.frame.size.width, sublayer.frame.size.height);
                
                //计算指针所移动的位置。计算在层里面的位置。
                CGPoint ptValueLayer = [self.layer convertPoint:ptLocation toLayer:_valueLayer];
                //如果这个点是在刻度点上。那么就显示数据。
                [self dealWithchange:ptValueLayer];
                               
            }
        }
        else
        {            
        }
        
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
        
        if (bStartValueLayerMove)
        {
           
            
            CALayer *layer = [_indicatorLayer.sublayers objectAtIndex:0];
            CGFloat width = CHARTVIEW_XAXISINDICATOR_HEIGHT*0.8 * tanf(30*3.14159265358/180);
            float linePointX = layer.frame.origin.x + width + 6;
            CGPoint ppt1 = CGPointMake(linePointX, 0);
            
            CGPoint ppt2 =  [_indicatorLayer convertPoint:ppt1 toLayer:_valueLayer];
            [self dealWithchange:ppt2];
        }
        
        bStartValueLayerMove = NO;
        bStartIndicatorMove = NO;
        
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateCancelled)
    {
        //if (_startValueLayerMove)
        //     _valueLayerVisibleX = _valueLayer.visibleRect.origin.x;
        
        bStartValueLayerMove = NO;
        bStartIndicatorMove = NO;
    }
}

-(void)handlePinchGestureRecognizer:(UIPinchGestureRecognizer*)gestureRecognizer
{
    
    if (_chartType == ChartTypePie)
        return;
    
    //通过调整区域。
    //计算2个点的位置。然后判断是左右缩放,也就是
    if (gestureRecognizer.numberOfTouches != 2)
        return;
    
    
    CGPoint pt1 = [gestureRecognizer locationOfTouch:0 inView:self];
    CGPoint pt2 = [gestureRecognizer locationOfTouch:1 inView:self];
    
    if (!CGRectContainsPoint(_valueRect, pt1) || !CGRectContainsPoint(_valueRect, pt2))
        return;
    
    
    //判断2个点位置。如果是纵向的则不进行处理。
 //   if (fabsf(pt1.x - pt2.x) < fabsf(pt1.y - pt2.y))
   //     return;
    
    
    static CGFloat prevMeasureSpacing = 0;
    static CGFloat prevMeasureWidth = 0;
    static CGFloat prevOffset = 0;
    
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
        prevMeasureSpacing = _measureSpacing;
        prevMeasureWidth= _measureWidth;
        prevOffset = _valueLayer.visibleRect.origin.x;
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateChanged)
    {
    
        //优先放大间隔，如果间隔man
        _measureSpacing =  prevMeasureSpacing * gestureRecognizer.scale;
              
        //缩放策略如下：
        //如果空间大于100则不再放大，如果宽度大于30则不再放大。
        if (_measureSpacing > 120)
            _measureSpacing = 120;        
        if (_measureSpacing < 3)
            _measureSpacing = 3;
        
            
        //如果在指定的空间内显示的数量超过最大宽度也就是1024 / (1 + 5) ~~ 170 行。那么就按170的来显示。
        
        //如果按上面的缩放比例总的数量的宽度要小于系统的宽度则不再进行缩放。
        CGFloat totalWidth = CHARTVIEW_LEFTINSET_WIDTH + _measureCount * (_measureSpacing + _measureUnit * _measureWidth);
        if (_measureCount > 0 &&  totalWidth < _valueRect.size.width)
        {
            _measureSpacing = (_valueRect.size.width - CHARTVIEW_LEFTINSET_WIDTH) /_measureCount  - _measureUnit * _measureWidth;
            if (_measureSpacing > 120)
                _measureSpacing = 120;
            if (_measureSpacing < 3)
                _measureSpacing = 3;
        }
        
        //计算最小移动界限和最大移动界限。
        CGFloat minOffsetX = 0;
        CGFloat maxOffsetX = CHARTVIEW_LEFTINSET_WIDTH + _measureCount * (_measureUnit * _measureWidth + _measureSpacing) + CHARTVIEW_RIGHTINSET_WIDTH - _valueLayer.bounds.size.width;
        if (maxOffsetX < 0)
            maxOffsetX = 0;
        
                    
        CGFloat newOffset = prevOffset;
        if (newOffset > CHARTVIEW_LEFTINSET_WIDTH)
        {
            newOffset = (newOffset - CHARTVIEW_LEFTINSET_WIDTH) / (prevMeasureSpacing + prevMeasureWidth * _measureUnit) * (_measureSpacing + _measureUnit * _measureWidth) + CHARTVIEW_LEFTINSET_WIDTH;
        }
        
        
        if ( (newOffset >= minOffsetX && newOffset <= maxOffsetX))
        {
            [_valueLayer scrollToPoint:CGPointMake(newOffset, 0)];
            
        }
        else if (newOffset < minOffsetX)
        {
            [_valueLayer scrollToPoint:CGPointMake(minOffsetX, 0)];
        }
        else if(newOffset > maxOffsetX)
        {
             [_valueLayer scrollToPoint:CGPointMake(maxOffsetX, 0)];
        }
        
        CALayer *layer = [_indicatorLayer.sublayers objectAtIndex:0];
        CGFloat width = CHARTVIEW_XAXISINDICATOR_HEIGHT*0.8 * tanf(30*3.14159265358/180);
        float linePointX = layer.frame.origin.x +width;
        CGPoint ppt1 = CGPointMake(linePointX, 0);
        
        CGPoint ppt2 =  [_indicatorLayer convertPoint:ppt1 toLayer:_valueLayer];
        [self dealWithchange:ppt2];
        
         [self reloadData];
    }
      
    
}

-(void)handleTapGestureRecognizer:(UITapGestureRecognizer*)gestureRecognizer
{
    if (_chartType != ChartTypePie)
        return;
    
    if (_indexCount == 0 || _measureCount == 0)
        return;
    
    //根据点击的区域得到制定的值。并显示图例。
    CGPoint ptLocation = [gestureRecognizer locationInView:self];
    if (!CGRectContainsPoint(_valueRect, ptLocation))
        return;
    
    //只能在圆内点击。
    CGPoint pt2 = [self.layer convertPoint:ptLocation toLayer:_pieLayer];
    if (pt2.x < 0 || pt2.y < 0)
        return;
    
    NSArray *arr = _pieLayer.sublayers;
    
    for (int i = 0; i < arr.count; i+=2)
    {
        CALayer *ll = [arr objectAtIndex:i];
        
        CGPoint pt3 = [self.layer convertPoint:ptLocation toLayer:ll];
        
        CGPathRef pathRef = ((CAShapeLayer*)ll.mask).path;
        
        if (CGPathContainsPoint(pathRef, nil, pt3, NO))
        {
            ll.transform = CATransform3DTranslate(ll.transform, 10, 10, 0);
            break;
        }
    }
    
    
}

#pragma mark - DrawLayer Methods

-(void)drawYAxisLayer:(CALayer *)layer inContext:(CGContextRef)ctx
{
    if (_chartType == ChartTypePie)
        return;
   
    UIGraphicsPushContext(ctx);
    CGFloat xOffset = CHARTVIEW_ELEMENT_SPACING;
    
    UIFont *font = [UIFont systemFontOfSize:15];
    
     CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
    
    CGContextSetStrokeColorWithColor(ctx, [UIColor colorWithWhite:37/255.0 alpha:1].CGColor);
    
    
    
    //如果绘制标题则取标题
    if (self.showYaxisTitle)
    {
        //取X轴的标题。
        if ([_dataSource respondsToSelector:@selector(yAxisTitleOfChartView:)])
        {
            NSString *title = [_dataSource yAxisTitleOfChartView:self];
            if (title != nil)
            {
                //计算标题的有效显示区域。
                CGSize titleSize =[title sizeWithFont:font 
                                             forWidth:CHARTVIEW_YAXISTITLE_WIDTH 
                                        lineBreakMode:UILineBreakModeCharacterWrap];
                [title drawInRect:CGRectMake(xOffset,
                                             layer.bounds.size.height/2 - titleSize.height/2 , 
                                             CHARTVIEW_YAXISTITLE_WIDTH+60,
                                             titleSize.height)
                         withFont:font
                    lineBreakMode:UILineBreakModeWordWrap];
            }
        }
        xOffset += CHARTVIEW_YAXISTITLE_WIDTH + CHARTVIEW_ELEMENT_SPACING;
    }

    //循环绘制刻度
    //平均刻度增量
    if (_indexCount > 0 && _measureCount > 0)
    {
        double avgScaleValue = (_maxValue - _minValue) / (_yAxisScaleCount - 1);
        CGFloat avgScalePos = _valueAreaHeight / (_yAxisScaleCount - 1);
        
        //绘制y轴刻度
        for (NSInteger i = 0; i < _yAxisScaleCount; i++)
        {
            NSString *value = [NSString stringWithFormat:@"%f", round((_maxValue - i * avgScaleValue)*10000)/10000];
            // NSString *value = [[NSNumber numberWithFloat:_maxValue - avgScaleValue * i] stringValue]; 
            
            //取出末尾空格。
            value = DeleteZero(value);
            
            [value drawInRect:CGRectMake(xOffset-10, 
                                         _valueRect.origin.y + i*avgScalePos - 10,
                                         _yAxisScaleValueWidth+10,
                                         avgScalePos/2) 
                     withFont:font
                lineBreakMode:UILineBreakModeCharacterWrap
                    alignment:UITextAlignmentRight];
            
        }
        
        xOffset += _yAxisScaleValueWidth;
        
        
        CGContextAddRect(ctx, _valueRect);
        
        for (NSInteger i = 0; i < _yAxisScaleCount; i++)
        {
            CGContextMoveToPoint(ctx, xOffset, _valueRect.origin.y + i*avgScalePos);
            if (self.showYaxisScaleLine)
            {
                CGContextAddLineToPoint(ctx, 
                                        xOffset + CHARTVIEW_YAXISSCALESHORTLINE_WIDTH, 
                                        _valueRect.origin.y + i*avgScalePos);
            }
            else 
            {
                CGContextAddLineToPoint(ctx, 
                                        xOffset + CHARTVIEW_YAXISSCALESHORTLINE_WIDTH + _valueRect.size.width, 
                                        _valueRect.origin.y + i*avgScalePos);
            }
        }
        
        CGContextStrokePath(ctx);
    }
    
     UIGraphicsPopContext();
}

-(void)drawXAxisScale:(CALayer *)layer inContext:(CGContextRef)ctx
{
    if (_chartType == ChartTypePie)
        return;
   
    if (_startMeasure == _endMeasure)
        return;
    
    UIFont *font = [UIFont systemFontOfSize:15];
    
    CGContextSetStrokeColorWithColor(ctx, [UIColor colorWithWhite:37/255.0 alpha:1].CGColor);
                                     
    CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
    CGContextSetLineWidth(ctx, 1);
    
    UIGraphicsPushContext(ctx);
    
      
    CGFloat xOffset = CHARTVIEW_LEFTINSET_WIDTH + _startMeasure * (_measureSpacing + _measureUnit * _measureWidth);
    
    
    //计算这段区域的数量以及每个占用的宽度。如果每个占用的宽度大于特定的值就是，
    //measureValue sizeWithFont:font
    
    //步长
    NSInteger step = ceilf((5.0 + 77)/(_measureUnit* _measureWidth + _measureSpacing));
    if (step < 1)
        step = 1;
       
    //最多只显示6个部分。
    for (NSInteger i = _startMeasure; i < _endMeasure; i++)
    {
        //如果i - startMeasure ％ 6 ＝＝ 0则这一行显示。
        
        xOffset += (_measureWidth * _measureUnit)/2;
        
        //取刻度值。
        if ((i % step) == 0)
        {
        NSString *measureValue = [_dataSource valueInChartView:self atMeasure:i];
        
        //计算出刻度的中间x坐标。这里需要缩小字体。
        /*
        - (CGSize)sizeWithFont:(UIFont *)font minFontSize:(CGFloat)minFontSize actualFontSize:(CGFloat *)actualFontSize forWidth:(CGFloat)width lineBreakMode:(UILineBreakMode)lineBreakMode;*/
        
        
        CGFloat actualSize = 15;
        CGSize sizeMeasure =[measureValue sizeWithFont:font
                                           minFontSize:12 actualFontSize:&actualSize forWidth:200
                                         lineBreakMode:UILineBreakModeCharacterWrap ];        
            CGRect textRect = CGRectMake(xOffset - sizeMeasure.width / 2, 
                                     _yAxisZeroScalePos + CHARTVIEW_XAXISSCALESHORTLINE_HEIGHT , 
                                     sizeMeasure.width, 
                                     sizeMeasure.height);
        
        CGContextMoveToPoint(ctx, xOffset, _yAxisZeroScalePos);
        CGContextAddLineToPoint(ctx, xOffset, _yAxisZeroScalePos + CHARTVIEW_XAXISSCALESHORTLINE_HEIGHT);
        
        //单数双数,日期上升下降显示结果。如果间距小于特定的值。并且数量多时
   //     if (_measureSpacing < (10 + sizeMeasure.width - (_measureUnit * _measureWidth)))
     //       {
       //         [measureValue drawInRect:CGRectOffset(textRect, 0,sizeMeasure.height * (i%2))
         //                       withFont:[UIFont systemFontOfSize:actualSize]
           //                lineBreakMode:UILineBreakModeCharacterWrap
             //                  alignment:UITextAlignmentCenter];
           // }
           //else
            //{
                [measureValue drawInRect:textRect
                                withFont:[UIFont systemFontOfSize:actualSize]
                           lineBreakMode:UILineBreakModeCharacterWrap
                               alignment:UITextAlignmentCenter];
           // }
        }
        
        xOffset += (_measureWidth * _measureUnit)/2 + _measureSpacing;
    }
    
    CGContextStrokePath(ctx);
    UIGraphicsPopContext();
}


-(void)drawMeasureText:(CGContextRef)ctx values:(NSArray*)valueArray points:(NSArray*)valuePointArray
{
     UIFont *font = [UIFont systemFontOfSize:15];
    
    UIGraphicsPushContext(ctx);
    
    CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);

    for (int i = 0; i < valueArray.count; i++)
    {
        NSString *strValue = [valueArray objectAtIndex:i];
        CGPoint  point = ((NSValue*)[valuePointArray objectAtIndex:i]).CGPointValue;
        CGSize sizeMeasure =[strValue sizeWithFont:font forWidth:200 lineBreakMode:UILineBreakModeCharacterWrap];   
        
        [strValue drawInRect:CGRectMake(point.x - sizeMeasure.width/2 , point.y - 26, sizeMeasure.width, 20) 
                    withFont:font 
               lineBreakMode:UILineBreakModeCharacterWrap
                   alignment:UITextAlignmentCenter];

    }
    
    UIGraphicsPopContext();
}


-(void)drawLineLayer:(CALayer *)layer inContext:(CGContextRef)ctx
{
    
    // UIGraphicsPushContext(ctx);
    
    // CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
    
    //文字显示数组,这个是放在最后面绘制，保证文字浮动在最上面。
    NSMutableArray *strValueArray = nil;
    NSMutableArray *strValuePointArray = nil;
    
   // UIFont *font = [UIFont systemFontOfSize:15];
    //显示有效的区域。
    
    
    //得到y坐标值
    for (NSInteger j = 0; j < _indexCount; j++)
    {        
        CGFloat xOffset = CHARTVIEW_LEFTINSET_WIDTH +  _startMeasure * (_measureSpacing + _measureUnit * _measureWidth);
        BOOL bPointStart = YES;
        
        //如果需要填充渐变这里建立一个路径。
        CGMutablePathRef linePath = NULL;
        if (self.closedLine)
            linePath = CGPathCreateMutable();
        
        //如果要显示点则绘制点路径。
        CGMutablePathRef valuePointPath = NULL;
        if ((_measureSpacing + _measureUnit * _measureWidth) > 50)
            valuePointPath = CGPathCreateMutable();
        
        for (NSInteger i = _startMeasure; i < _endMeasure; i++)
        {
            //计算x的偏移位置
            xOffset += (_measureUnit * _measureWidth)/2;
            
            //取值。
            NSString *strValue  = [_dataSource valueInChartView:self atMeasure:i atIndex:j];
            CGFloat value = nanf("");
            if (strValue.length > 0 && ![strValue isEqualToString:@"-"] && ![strValue isEqualToString:@"--"])
                value = [strValue floatValue];
            //判断是否是数字。
            
            //只对有效的数字进行处理
            if (!isnan(value))
            {
                //根据值得到对应的y轴坐标值。
                CGFloat yOffset  = _valueAreaHeight / (_maxValue - _minValue)  *(_maxValue - value);
                
                if (bPointStart)
                {
                    CGContextMoveToPoint(ctx, xOffset, yOffset);
                    if (linePath != NULL)
                    {
                        CGPathMoveToPoint(linePath, NULL, xOffset, _yAxisZeroScalePos);
                        CGPathAddLineToPoint(linePath,NULL, xOffset, yOffset);
                    }
                }
                else 
                {
                    CGContextAddLineToPoint(ctx, xOffset, yOffset);
                    if (linePath != NULL)
                    {
                        CGPathAddLineToPoint(linePath,NULL,xOffset, yOffset);
                    }
                }
                
                bPointStart = NO;
                
                //如果显示值的点则显示值的点。
                if (valuePointPath != NULL)
                {
                    //因为绘制园会移动当前点，所以绘制园后需要重置当前点。
                    CGPathAddEllipseInRect(valuePointPath, NULL, CGRectMake(xOffset - 3, yOffset - 3, 6, 6));
                    
                    //只有画点的时候才显示文字。在圆圈的顶上绘制文字。 －30
                    if (_indexCount == 1)
                    {
                        if (strValueArray == nil)
                        {
                            strValueArray = [[NSMutableArray alloc] init];
                            strValuePointArray = [[NSMutableArray alloc] init];
                        }
                        
                        [strValueArray addObject:strValue];
                        [strValuePointArray addObject:[NSValue valueWithCGPoint:CGPointMake(xOffset, yOffset)]];
                        
                        /*
                        CGSize sizeMeasure =[strValue sizeWithFont:font forWidth:200 lineBreakMode:UILineBreakModeCharacterWrap];   
                        
                        [strValue drawInRect:CGRectMake(xOffset - sizeMeasure.width/2 , yOffset - 26, sizeMeasure.width, 20) 
                                withFont:font 
                           lineBreakMode:UILineBreakModeCharacterWrap
                                   alignment:UITextAlignmentCenter];*/
                    }
                    
                    
                    
                }
            }
            else 
            {
                //对于无效的点，下次总是认为是新的起点。
              //  bPointStart = YES;
                //这里也要绘制结束点。
              //  if (linePath != NULL)
               //     CGPathAddLineToPoint(linePath, NULL, xOffset - _measureSpacing - (_measureUnit * _measureWidth), _yAxisZeroScalePos);
                
            }
            
            xOffset += (_measureWidth * _measureUnit)/2 + _measureSpacing;
        }
        
        //绘制出线段。
        //设置线绘制的颜色。
        //UIColor *indexColor = nil;
        NSArray *indexColorArray = nil;
        if ([_dataSource respondsToSelector:@selector(indexColorInChartView:atIndex:)])
        {
            indexColorArray = [_dataSource indexColorInChartView:self atIndex:j];
        }
        if (indexColorArray == nil)
        {
           indexColorArray = [NSArray arrayWithObject:[UIColor whiteColor]];
        }
        
        //取第一个颜色为显示颜色。
        CGContextSetStrokeColorWithColor(ctx, ((UIColor*)[indexColorArray objectAtIndex:0]).CGColor);
        CGContextSetLineWidth(ctx, 2);
        CGContextStrokePath(ctx);

        if (valuePointPath != NULL)
        {
            //绘制跟线颜色相反的点。
            CGFloat revRed, revGreen, revBlue, revAlpha;
           const CGFloat *xx = CGColorGetComponents(((UIColor*)[indexColorArray objectAtIndex:0]).CGColor);
            
            revRed = 1- xx[0];
            revGreen =1 - xx[1];
            revBlue = 1- xx[2];
            revAlpha = xx[3];
            CGContextSetStrokeColorWithColor(ctx, [UIColor colorWithRed:revRed green:revGreen blue:revBlue alpha:revAlpha].CGColor);
            CGContextSetFillColorWithColor(ctx, [UIColor colorWithRed:revRed green:revGreen blue:revBlue alpha:revAlpha].CGColor);
            CGContextSetLineWidth(ctx, 2);
            CGContextAddPath(ctx, valuePointPath);
            CGContextDrawPath(ctx,kCGPathFillStroke);
            CGPathRelease(valuePointPath);
            
        }
        
        
        //如果需要填充渐变区域则填充渐变区域
        if (linePath != NULL)
        {
            //绘制最后一点到x轴的0开始位置
            CGPathAddLineToPoint(linePath, NULL, xOffset - (_measureWidth * _measureUnit)/2 - _measureSpacing, _yAxisZeroScalePos);
            
            //绘制一条横线，形成闭合路径
            CGPathMoveToPoint(linePath, NULL, layer.bounds.origin.x, _yAxisZeroScalePos);
            CGPathAddLineToPoint(linePath, NULL, layer.bounds.origin.x + layer.bounds.size.width, _yAxisZeroScalePos);
            
            //形成闭合路径
            CGPathCloseSubpath(linePath);
            
            CGContextSaveGState(ctx);
            
            //将路径加入到裁剪区域。进行渐变的局部填充。
            CGContextAddPath(ctx, linePath);
            CGContextClip(ctx);
            
            //绘制渐变。
            const CGFloat *pp = CGColorGetComponents(((UIColor*)[indexColorArray objectAtIndex:0]).CGColor);
            CGFloat components[12] = {pp[0], pp[1],pp[2],0.7,pp[0], pp[1],pp[2],0.6, 0,0,0,0.4};
            CGFloat locations[3] = {0,0.1,1};  
            CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();    
            CGGradientRef colorGradient = CGGradientCreateWithColorComponents(colorSpace, components, locations, 3);  
            CGContextDrawLinearGradient(ctx, colorGradient,CGPointMake(CGRectGetMidX(layer.bounds), CGRectGetMinY(layer.bounds)), CGPointMake(CGRectGetMidX(layer.bounds), CGRectGetMaxY(layer.bounds)),0); 
            CGColorSpaceRelease(colorSpace);
            CGGradientRelease(colorGradient);
            
            CGPathRelease(linePath);
            CGContextRestoreGState(ctx);
        }
    }
    
     //UIGraphicsPopContext();
    
    if (strValueArray != nil)
    {
        [self drawMeasureText:ctx values:strValueArray points:strValuePointArray];
        [strValueArray release];
        [strValuePointArray release];
    }
    
    [self drawXAxisScale:layer inContext:ctx];
}

-(void)drawBarLayer:(CALayer *)layer inContext:(CGContextRef)ctx
{
     UIGraphicsPushContext(ctx);
    
     CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
       
    UIFont *font = [UIFont systemFontOfSize:15];

    //得到y坐标值
    for (NSInteger j = 0; j < _indexCount; j++)
    {        
        CGFloat xOffset =CHARTVIEW_LEFTINSET_WIDTH +  _startMeasure * (_measureSpacing + _measureUnit * _measureWidth);
        
        
        NSArray *indexColorArray = nil;
        if ([_dataSource respondsToSelector:@selector(indexColorInChartView:atIndex:)])
        {
            indexColorArray = [_dataSource indexColorInChartView:self atIndex:j];
        }
        if (indexColorArray == nil)
        {
            indexColorArray = [NSArray arrayWithObject:[UIColor whiteColor]];
        }
        
        CGGradientRef colorGradient = NULL;
        if (indexColorArray.count > 1)
        {
            const CGFloat *color1 = CGColorGetComponents(((UIColor*)[indexColorArray objectAtIndex:0]).CGColor); //获取一个color的rgb
            const CGFloat *color2 = CGColorGetComponents(((UIColor*)[indexColorArray objectAtIndex:1]).CGColor); //获取一个color的rgb
        
            CGFloat components[8] = {color1[0], color1[1],color1[2],color1[3],color2[0], color2[1],color2[2],color2[3]};
            CGFloat locations[2] = {0,1};  
            CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();    
            colorGradient = CGGradientCreateWithColorComponents(colorSpace, components, locations, 2);
            CGColorSpaceRelease(colorSpace);
        }
        
     
        
        for (NSInteger i = _startMeasure; i < _endMeasure; i++)
        {
            //计算得到x轴的值。
            xOffset += _measureWidth * j;             
            //取值。
            NSString *strValue  = [_dataSource valueInChartView:self atMeasure:i atIndex:j];
            CGFloat value = nanf("");
            if (strValue.length > 0 && ![strValue isEqualToString:@"-"] && ![strValue isEqualToString:@"--"])
                value = [strValue floatValue];

            //只有有值才计算。
            if (!isnan(value))
            {
                //根据值得到对应的y轴坐标值。
                CGFloat yOffset  = _valueAreaHeight / (_maxValue - _minValue)  *(_maxValue - value);
                
                CGRect rect  = CGRectMake(xOffset, yOffset, _measureWidth, _valueAreaHeight - yOffset);
                CGContextSaveGState(ctx);
                
                //如果多颜色则绘制渐变色。否则绘制单颜色。
                if (colorGradient != NULL)
                {
                    CGContextClipToRect(ctx, rect);
                    CGContextDrawLinearGradient(ctx, colorGradient,CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect)), CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect)),0); 
                }
                else
                {
                    CGContextSetFillColorWithColor(ctx, ((UIColor*)[indexColorArray objectAtIndex:0]).CGColor);
                    CGContextFillRect(ctx, CGRectMake(xOffset, yOffset, _measureWidth, _valueAreaHeight - yOffset));
                }
               
                CGContextRestoreGState(ctx);
                
                
                if (/*self.showValue*/(_measureSpacing + _measureUnit * _measureWidth) > 50 && _indexCount == 1)
                {
                    //计算文本的宽度。
                    CGSize sizeMeasure =[strValue sizeWithFont:font forWidth:200 lineBreakMode:UILineBreakModeCharacterWrap];   
                    
                    [strValue drawInRect:CGRectMake(xOffset + _measureWidth / 2 - sizeMeasure.width / 2, yOffset - 20, sizeMeasure.width, 20) 
                                withFont:font 
                           lineBreakMode:UILineBreakModeCharacterWrap
                               alignment:UITextAlignmentCenter];
                    
                }
                
            }
            
                       
            xOffset += (_indexCount - j)*_measureWidth + _measureSpacing;
        }
        
      
         if (colorGradient != NULL)
             CGGradientRelease(colorGradient);
    }
    
      UIGraphicsPopContext();
    
    [self drawXAxisScale:layer inContext:ctx];
}


-(void)drawPieLayer:(CALayer *)layer inContext:(CGContextRef)ctx
{
    //按80%来绘制圆。每个片段绘制层
    //只取第一个指标
       
    //删除以前的层
    NSArray *subLayers = layer.sublayers;
    for (int i = subLayers.count - 1; i >= 0; i--)
    {
        [[subLayers objectAtIndex:i] removeFromSuperlayer];
    }
    
    if (_indexCount == 0)
        return;
    

    
    //只取第一个指标。计算出所有的总数。然后再计算比例。
    //每个量值是一个层
    double totalValue = 0.0f;
    for (NSInteger  i = 0; i < _measureCount; i++)
    {
        NSString *strValue  = [_dataSource valueInChartView:self atMeasure:i atIndex:0];
        double value = nan("");
        if (strValue.length > 0 && ![strValue isEqualToString:@"-"] && ![strValue isEqualToString:@"--"])
            value = [strValue doubleValue];
        if (!isnan(value))
        {
            totalValue += fabs(value);
        }
    }
    
    //绘制饼
 //    UIGraphicsPushContext(ctx);
    
 //   CGContextSetStrokeColorWithColor(ctx, [UIColor whiteColor].CGColor);
 //   CGContextSetLineWidth(ctx, 2);
   
    //从第0个开始绘制。
    CGFloat radius = MIN(layer.bounds.size.width, layer.bounds.size.height) * 0.8 /2;
    CGPoint ptCenter = CGPointMake(CGRectGetMidX(layer.bounds), CGRectGetMidY(layer.bounds));
    CGRect  angleRect = CGRectMake(0, 0, radius*2, radius*2);
    CGPoint angleCenter = CGPointMake(CGRectGetMidX(angleRect), CGRectGetMidY(angleRect));
    
    UIFont *font = [UIFont systemFontOfSize:15];
    
    double startAngle = -1*M_PI_2;
    for (NSInteger  i = 0; i < _measureCount; i++)
    {
        NSString *strValue  = [_dataSource valueInChartView:self atMeasure:i atIndex:0];
        double value = nan("");
        if (strValue.length > 0 && ![strValue isEqualToString:@"-"] && ![strValue isEqualToString:@"--"])
            value = [strValue doubleValue];
        if (!isnan(value))
        {
            //计算弧的角度。
            double angle = (fabs(value) / totalValue) * M_PI * 2;
            

            CGMutablePathRef anglePath = CGPathCreateMutable();
            CGPathMoveToPoint(anglePath, NULL, angleCenter.x, angleCenter.y);
            CGPathAddArc(anglePath, NULL, angleCenter.x, angleCenter.y, radius, 0, angle,0);
            CGPathMoveToPoint(anglePath, NULL, angleCenter.x, angleCenter.y);
            CAShapeLayer *angleLayer = [[CAShapeLayer alloc] init];
            angleLayer.path = anglePath;
            CGPathRelease(anglePath);
           
            CAGradientLayer *gradLayer = [[CAGradientLayer alloc] init];
            gradLayer.bounds = angleRect;
            gradLayer.anchorPoint = CGPointMake(0.5, 0.5);
            gradLayer.position = ptCenter;
           // gradLayer.masksToBounds = NO;
           
            
            NSArray *measureColorArray = nil;
            if ([_dataSource respondsToSelector:@selector(measureColorInChartView:atMeasure:)])
            {
                measureColorArray = [_dataSource measureColorInChartView:self atMeasure:i];
            }
            if (measureColorArray == nil)
            {
                measureColorArray = [NSArray arrayWithObject:[UIColor whiteColor]];
            }
           
            NSMutableArray *measureColorArrayRef = NSMutableArray.new;
            for (UIColor *cl in measureColorArray)
            {
                [measureColorArrayRef addObject:(id)cl.CGColor];
            }
            gradLayer.colors = measureColorArrayRef;
            [measureColorArrayRef release];
            gradLayer.locations = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0], [NSNumber numberWithFloat:1.0f], nil];
            
            [gradLayer setMask:angleLayer];
            [angleLayer release];
            
            
            gradLayer.transform = CATransform3DMakeRotation(startAngle, 0, 0, 1);
            
            [layer addSublayer:gradLayer];
            [gradLayer release];
            
            //定位文字的位置。在圆的一半，和弧的中心角度。
            double quotient = 0.5;
            if (angle < M_PI / 9)
                quotient = 1.1;
            
            //计算出文字显示的部分。
            CGFloat textX = ptCenter.x + radius*quotient * cos(-1* (startAngle + angle / 2));
            CGFloat textY = ptCenter.y  - radius*quotient * sin(-1* (startAngle + angle / 2));
            
            
            //添加文字部分。
            CATextLayer *textLayer = CATextLayer.new;
            
            NSString *measureValue = [NSString stringWithFormat:@"%@\n%d%%",[_dataSource valueInChartView:self atMeasure:i],(int)(fabs(value)* 100 / totalValue)];

            CGSize sizeMeasure =[measureValue sizeWithFont:font forWidth:200 lineBreakMode:UILineBreakModeCharacterWrap];
            textLayer.string = measureValue;

            textLayer.frame =  CGRectMake(textX - sizeMeasure.width / 2, textY - sizeMeasure.height - 5, sizeMeasure.width, 2*sizeMeasure.height+10);
            //   textLayer.bounds = CGRectMake(0, 0, 320, 20);
            textLayer.font = @"HelveticaNeue"; //字体的名字 不是 UIFont
            textLayer.fontSize = 15.f; //字体的大小
            textLayer.alignmentMode = kCAAlignmentCenter;//字体的对齐方式
            // textLayer.position = CGPointMake(160, 410);
            
            if ((angle < M_PI / 9))
            {
                textLayer.foregroundColor = [UIColor whiteColor].CGColor;
            }
            else
            {
                CGFloat revRed, revGreen, revBlue, revAlpha;
                const CGFloat *xx = CGColorGetComponents(((UIColor*)[measureColorArray objectAtIndex:0]).CGColor);
                
                revRed = 1- xx[0];
                revGreen =1 - xx[1];
                revBlue = 1- xx[2];
                revAlpha = xx[3];
                textLayer.foregroundColor =  [UIColor colorWithRed:revRed green:revGreen blue:revBlue alpha:revAlpha].CGColor;
            }
            textLayer.backgroundColor = [UIColor clearColor].CGColor;
            [layer addSublayer:textLayer];
            [textLayer release];

            
            
            
            startAngle += angle;
        }
    }

  //   CGContextStrokePath(ctx);
    
   // UIGraphicsPopContext();
}

#pragma mark -Custom Methods

//重新计算有效的区域
-(void)calcValueRect
{
    _valueRect = self.bounds;
    
    //先扣除四周的边界
    _valueRect = CGRectInset(_valueRect, CHARTVIEW_ELEMENT_SPACING, CHARTVIEW_ELEMENT_SPACING);
    
    //如果显示主标题
    if (self.showMajorTitle)
    {
        _valueRect.origin.y += CHARTVIEW_MAJORTITLE_HEIGHT + CHARTVIEW_ELEMENT_SPACING;
        _valueRect.size.height -= CHARTVIEW_MAJORTITLE_HEIGHT + CHARTVIEW_ELEMENT_SPACING;
        //_valueRect =   //CGRectInset(_valueRect, 0, CHARTVIEW_MAJORTITLE_HEIGHT + CHARTVIEW_ELEMENT_SPACING);
    }
    else
    {
        _valueRect.origin.y += 20.0 + CHARTVIEW_ELEMENT_SPACING;
        _valueRect.size.height -= 20.0 + CHARTVIEW_ELEMENT_SPACING;
        //_valueRect =   //CGRectInset(_valueRect, 0, CHARTVIEW_MAJORTITLE_HEIGHT + CHARTVIEW_ELEMENT_SPACING);
    }
    
    //如果显示x轴标题
    if(self.showXaxisTitle)
        _valueRect.size.height -= CHARTVIEW_XAXISTITLE_HEIGHT + CHARTVIEW_ELEMENT_SPACING;
    
    //如果显示指示器则扣除这个高度。
    if (self.showIndicator)
        _valueRect.size.height -= CHARTVIEW_XAXISINDICATOR_HEIGHT + CHARTVIEW_ELEMENT_SPACING;
    
    //减去x轴刻度值的高度，和刻度线的高度。
    //这里不减去，因为x轴的刻度是在值的里面显示的。
    //_valueRect.size.height -= CHARTVIEW_XAXISSCALEVALUE_HEIGHT + CHARTVIEW_XAXISSCALESHORTLINE_HEIGHT;
    
    //如果显示y轴标题
    if (self.showYaxisTitle)
    {
        _valueRect.origin.x +=(CHARTVIEW_YAXISTITLE_WIDTH + CHARTVIEW_ELEMENT_SPACING);
        _valueRect.size.width -= (CHARTVIEW_YAXISTITLE_WIDTH + CHARTVIEW_ELEMENT_SPACING);
        //CGRectInset(_valueRect, CHARTVIEW_YAXISTITLE_WIDTH + CHARTVIEW_ELEMENT_SPACING, 0);
    }
    //减去y轴刻度值的宽度，和刻度线的宽度
    
    if (_indexCount > 0 && _measureCount > 0 && _chartType != ChartTypePie)
    {
        _valueRect.origin.x += _yAxisScaleValueWidth + CHARTVIEW_YAXISSCALESHORTLINE_WIDTH;
        _valueRect.size.width -= _yAxisScaleValueWidth + CHARTVIEW_YAXISSCALESHORTLINE_WIDTH;
    }
    
    //减去图例部分的宽度
    if (self.showCutline)
        _valueRect.size.width -= CHARTVIEW_CUTLINE_WIDTH + CHARTVIEW_ELEMENT_SPACING;
}

-(CGFloat)calcYAxisMaxScaleValueWidth
{
    //计算平均刻度值
    if (_indexCount == 0 || _measureCount == 0 || _chartType == ChartTypePie)
        return 0;
    
    double avgScaleValue = (_maxValue - _minValue) / (_yAxisScaleCount - 1);
    
    //默认最大刻度值字符串
    NSString *maxScaleValueStr =@"";
    for (NSInteger i = 0; i < _yAxisScaleCount; i++)
    {
        NSString *scaleValueStr = [NSString stringWithFormat:@"%f", round((_maxValue - i * avgScaleValue)*10000)/10000];
        //去除后面的0和小数点。
        scaleValueStr = DeleteZero(scaleValueStr);
        
        //得到最长的字符串
        if (maxScaleValueStr.length < scaleValueStr.length)
        {
            maxScaleValueStr = scaleValueStr;
        }
        
    }
    
    //取出最长的字符串，计算刻度值显示的宽度
    CGSize scaleSize = [maxScaleValueStr sizeWithFont:[UIFont systemFontOfSize:15] forWidth:self.bounds.size.width lineBreakMode:UILineBreakModeCharacterWrap];
    
    return scaleSize.width + 4;
}


-(void)RegulateAll:(CGFloat*)dMin dMax:(CGFloat*)dMax num:(int*)iMaxAxisNum
{
    CGFloat dDelta = *dMax - *dMin;
    if(dDelta < 1.0) //Modify this by your requirement.
    { 
        *dMax += (1.0 - dDelta)/2.0;
        *dMin -= (1.0 - dDelta)/2.0;
    }
    dDelta = *dMax - *dMin;
    
    int iExp = (int)(logf(dDelta)/logf(10.0))-2;
    CGFloat dMultiplier = powf(10, iExp);
    const CGFloat dSolutions[] = {1, 2, 2.5, 5, 10, 20, 25, 50, 100, 200, 250, 500};
    int i;
    for(i = 0; i < sizeof(dSolutions)/sizeof(CGFloat); i++)
    {
        CGFloat dMultiCal = dMultiplier * dSolutions[i];
        if(((int)(dDelta/dMultiCal) + 1) <= * iMaxAxisNum)
        {
            break;
        }
    }
    
    CGFloat dInterval = dMultiplier * dSolutions[i];
    
    CGFloat dStartPoint = ((int)ceilf(*dMin/dInterval) - 1) * dInterval;
    *dMin = dStartPoint;
    int iAxisIndex;
    for(iAxisIndex = 0; 1; iAxisIndex++)
    {
        if(dStartPoint + dInterval * iAxisIndex >* dMax)
        {
            *dMax = dStartPoint+dInterval*iAxisIndex;
            break;
        }
    }
    
    *iMaxAxisNum = iAxisIndex;
}

- (void)closeFolatView:(id)sender
{
    _floatView.hidden =YES;  
}

- (void)showDetailFloatView:(BOOL)aMustReload
{
    if (_indexCount != 0)
    {
        if (_floatView.hidden == YES)
        {
            _floatView.hidden = NO;
        }
        
        if (aMustReload)
        {
//            if (_showFloatIndex != -1 && _showFloatIndex < _measureCount)
//            {
//                _measurelabel.text = [_dataSource valueInChartView:self atMeasure:_showFloatIndex];
//                
//            }
//            else
//            {
//                _measurelabel.text = @"";
//                
//            }
            [self changeFloatViewFrame];
            [_tableView reloadData];
        }
        
    }
    
}





-(void)handlefloatPanGestureRecognizer:(UIPanGestureRecognizer*)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateChanged)
    {
//        CGPoint ptTranslation = [gestureRecognizer translationInView:self];
        CGPoint ptLocation = [gestureRecognizer locationInView:self];
        if (ptLocation.x -_floatView.frame.size.width/2 >_valueRect.origin.x &&
            ptLocation.x +_floatView.frame.size.width/2 <_valueRect.origin.x+_valueRect.size.width && 
            ptLocation.y - _floatView.frame.size.height/2 > _valueRect.origin.y &&
            ptLocation.y + _floatView.frame.size.height/2  < _valueRect.origin.y+_valueRect.size.height)
        {
            _floatView.center = ptLocation;
        }
    }
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded )
    {
        CGPoint ptLocation = [gestureRecognizer locationInView:self];
        if (ptLocation.x -_floatView.frame.size.width/2 >_valueRect.origin.x &&
            ptLocation.x +_floatView.frame.size.width/2 <_valueRect.origin.x+_valueRect.size.width && 
            ptLocation.y - _floatView.frame.size.height/2 > _valueRect.origin.y &&
            ptLocation.y + _floatView.frame.size.height/2  < _valueRect.origin.y+_valueRect.size.height)
        {
            _floatView.center = ptLocation;
        }
    }
}

-(void)construct
{
    _dataSource = nil;
    _indexCount = 0;
    _measureCount = 0;
    _startMeasure = 0;
    _endMeasure = 0;
    _minValue = 0;
    _maxValue = 60;
    _rawMinValue = 0;
    _rawMaxValue = 0;
    
    _yAxisLayer = nil;
    _lineLayer = nil;
    _barLayer = nil;
    _valueLayer = nil;
    _indicatorLayer = nil;
       
    _measureSpacing = 10;    //默认宽度是1
    _measureWidth = 5;     //单个刻度的宽度
    _measureUnit = 1;       //一个刻度下的宽度的数量，对于线性是1，对于条形图是指标的数量。如果是有线性和条形图则以条形为基础。刻度的单位
    _yAxisScaleCount = 6;

    _chartType = ChartTypeLine;
    
    _innerLayerDelegate = [[ChartViewLayerDelegate alloc] initWithView:self];
    
    _yAxisZeroScalePos = 0;
    _valueAreaHeight = 0;
    _yAxisScaleValueWidth = CHARTVIEW_YAXISSCALEVALUE_WIDTH;
    
    
    self.showMajorTitle = NO;
    self.showMinorTitle = NO;
        
    self.showYaxisTitle = NO;       //显示y轴标题。默认为no
    self.showYaxisScaleLine = NO;   //显示y轴横线。默认为no
    
    self.showXaxisTitle = NO;       //是否显示x轴标题
    
    self.showCutline = NO;          //显示图例。默认是no
    
    self.showValuePoint = YES;
    self.closedLine = YES;
    self.showValue = YES;
    self.showIndicator = YES;
    
    
    [self calcValueRect];           //计算值的有效区域。
    
    
    //默认在底部。也就是减去绘制刻度的部分。
    _yAxisZeroScalePos = _valueRect.size.height - CHARTVIEW_XAXISSCALEVALUE_HEIGHT - CHARTVIEW_XAXISSCALESHORTLINE_HEIGHT;
    //数据区域的高度
    _valueAreaHeight = _valueRect.size.height - CHARTVIEW_XAXISSCALEVALUE_HEIGHT - CHARTVIEW_XAXISSCALESHORTLINE_HEIGHT;

    //背景颜色层
    _valueBackLayer = [[CALayer alloc] init];
    _valueBackLayer.backgroundColor = [UIColor blackColor].CGColor;
    _valueBackLayer.frame = _valueRect;
    [self.layer addSublayer:_valueBackLayer];
    

    //绘制坐标轴层
    _yAxisLayer = [[CALayer alloc] init];
    _yAxisLayer.frame = self.layer.bounds;
    _yAxisLayer.delegate = _innerLayerDelegate;
    [self.layer addSublayer:_yAxisLayer];
    

    _lineLayer = [[CAScrollLayer alloc] init];
    _lineLayer.frame = _valueRect;
    _lineLayer.scrollMode = kCAScrollHorizontally;
    _lineLayer.delegate = _innerLayerDelegate;
    [self.layer addSublayer:_lineLayer];
        
    _barLayer = [[CAScrollLayer alloc] init];
    _barLayer.frame = _valueRect;
    _barLayer.scrollMode = kCAScrollHorizontally;
    _barLayer.delegate = _innerLayerDelegate;
    [self.layer addSublayer:_barLayer];
    
    _pieLayer = [[CAScrollLayer alloc] init];
    _pieLayer.frame = _valueRect;
    _pieLayer.scrollMode = kCAScrollHorizontally;
  //  _pieLayer.delegate = _innerLayerDelegate;
    [self.layer addSublayer:_pieLayer];

    
    _valueLayer = _lineLayer;
    
    // self.layer.masksToBounds = NO;
    //添加指示器层。
    _indicatorLayer = [[CALayer alloc] init];
    _indicatorLayer.frame = CGRectMake(_valueRect.origin.x, 
                                       _valueRect.origin.y + _valueRect.size.height + CHARTVIEW_ELEMENT_SPACING, 
                                       _valueRect.size.width, CHARTVIEW_XAXISINDICATOR_HEIGHT);
    _indicatorLayer.borderColor = [UIColor colorWithWhite:43/255.0 alpha:1].CGColor;
    _indicatorLayer.borderWidth = 2;
    _indicatorLayer.masksToBounds = NO;
    _indicatorLayer.cornerRadius = 6;
    _indicatorLayer.shadowColor = [UIColor colorWithWhite:0 alpha:1].CGColor;
    _indicatorLayer.backgroundColor = [UIColor colorWithWhite:22/255.0 alpha:1].CGColor;
    [self.layer addSublayer:_indicatorLayer];
    
    //绘制指示器。
    CGFloat width = CHARTVIEW_XAXISINDICATOR_HEIGHT*0.8 * tanf(30*3.14159265358/180);
    
    CGMutablePathRef pathRef = CGPathCreateMutable();
    
    CGPathMoveToPoint(pathRef, NULL, width + 6, 2);
    CGPathAddLineToPoint(pathRef,NULL, 0 + 6, CHARTVIEW_XAXISINDICATOR_HEIGHT*0.8 + 2);
    CGPathAddLineToPoint(pathRef,NULL, 2*width + 6, CHARTVIEW_XAXISINDICATOR_HEIGHT*0.8 + 2);
    CGPathAddLineToPoint(pathRef,NULL, width + 6, 2);
    //再绘制一条线。
    CGPathAddLineToPoint(pathRef, NULL,width + 6, -_valueRect.size.height);
    
    CAShapeLayer *shapelayer = [[CAShapeLayer alloc] init];
    shapelayer.path = pathRef;
    shapelayer.fillColor = [UIColor whiteColor].CGColor; 
    shapelayer.strokeColor =  [UIColor whiteColor].CGColor;
    shapelayer.lineWidth = 1;
    [_indicatorLayer addSublayer:shapelayer];
    
    NSMutableDictionary *customActions=[NSMutableDictionary dictionaryWithDictionary:[shapelayer actions]];
    // add the new action for sublayers
    [customActions setObject:[NSNull null] forKey:@"position"];
    // set theLayer actions to the updated dictionary
    shapelayer.actions=customActions;

    
    [shapelayer release];
    CGPathRelease(pathRef);
    
    
      
   
    //创建拖动手势
    _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self 
                                                          action:@selector(handlePanGestureRecognizer:)];
    [self addGestureRecognizer:_panGesture];
    [_panGesture release];
    
    
    _pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGestureRecognizer:)];
    [self addGestureRecognizer:_pinchGesture];
    [_pinchGesture release];
    
    _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGestureRecognizer:)];
    [self addGestureRecognizer:_tapGesture];
    [_tapGesture release];

    
    _floatView = [[UIView alloc] initWithFrame:CGRectMake(self.frame.size.width-250, 30, 207, 151)];
    _floatView.backgroundColor = [UIColor darkGrayColor];
    
    _floatView.alpha = 0.7;
    UIImageView *imageview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"floatback.png"]];
    imageview.frame = CGRectMake(0, 0, _floatView.frame.size.width, _floatView.frame.size.height);
    imageview.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;;
    [_floatView addSubview:imageview];
    [imageview release];
    
//    //移动用的
//    UIPanGestureRecognizer *floatViewGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlefloatPanGestureRecognizer:)];
//    [_floatView addGestureRecognizer:floatViewGesture];
//    [floatViewGesture release];
    
    _closeButton = [[UIButton alloc] initWithFrame:CGRectMake(_floatView.frame.size.width-34, 4, 30, 30)];
//    [button addTarget:self action:@selector(closeFolatView:) forControlEvents:UIControlEventTouchUpInside];
    [_closeButton setBackgroundImage:[UIImage imageNamed:@"floatclose.png"] forState:UIControlStateNormal];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeFolatView:)];
    [_closeButton addGestureRecognizer:tapGesture];
    [tapGesture release];
    _closeButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    [_floatView addSubview:_closeButton];
    
    _measurelabel = [[UILabel alloc] initWithFrame:CGRectMake(10,4, 160, 30)];
    _measurelabel.font = [UIFont fontWithName:@"Helvetica" size:16];
    _measurelabel.textColor = [UIColor whiteColor];
    _measurelabel.backgroundColor = [UIColor clearColor];
    _measurelabel.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
    [_floatView addSubview:_measurelabel];
    

    
     _showFloatIndex = -1;
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 38, 200, 113)];
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.separatorColor = [UIColor clearColor];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.bounces = NO;
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleLeftMargin;
    [_floatView addSubview:_tableView];
    
    _floatView.autoresizingMask  = UIViewAutoresizingFlexibleRightMargin;
    [self addSubview:_floatView];
    [self bringSubviewToFront:_floatView];
    _floatView.hidden = YES;
    
    
    _measureSpacing =  87 - _measureUnit * _measureWidth;
    if (_measureSpacing > 120)
        _measureSpacing = 120;
    if (_measureSpacing < 3)
        _measureSpacing = 3;

    
}

#pragma mark - View

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        [self construct];
    }
    
    return  self;
}

-(void)awakeFromNib
{
    [super awakeFromNib];
    
    [self construct];
}

-(void)dealloc
{
    [_closeButton release];
    _dataSource = nil;
    [_measurelabel release];
    [_floatView release];
    [_tableView release];
    _yAxisLayer.delegate = nil;
    [_yAxisLayer release];
     _valueBackLayer.delegate = nil;
    [_valueBackLayer release];
    _lineLayer.delegate = nil;
    [_lineLayer release];
    _barLayer.delegate = nil;
    [_barLayer release];
    _pieLayer.delegate  = nil;
    [_pieLayer release];
    
    [_innerLayerDelegate release];
    
    [_indicatorLayer release];
    
    [super dealloc];
}

#pragma mark - Property Methods

- (BOOL)showMajorTitle
{
    return  _chartAttr._showMajorTitle;
}

- (void)setShowMajorTitle:(BOOL)aShowMajorTitle
{
    if (_chartAttr._showMajorTitle == aShowMajorTitle)
        return;
    
    _chartAttr._showMajorTitle = aShowMajorTitle;
    [self calcValueRect];
}

- (BOOL)showMinorTitle
{
    return _chartAttr._showMinorTitle;
}

- (void)setShowMinorTitle:(BOOL)aShowMinorTitle
{
    _chartAttr._showMinorTitle = aShowMinorTitle;
}

- (BOOL)showYaxisTitle
{
    return _chartAttr._showYaxisTitle;
}

- (void)setShowYaxisTitle:(BOOL)aShowYaxisTitle
{
    if (_chartAttr._showYaxisTitle == aShowYaxisTitle)
        return;
    
    _chartAttr._showYaxisTitle = aShowYaxisTitle;
    [self calcValueRect];
}

- (BOOL) showYaxisScaleLine
{
    return _chartAttr._showYaxisScaleLine;
}

- (void)setShowYaxisScaleLine:(BOOL)aShowYaxisScaleLine
{
    if (_chartAttr._showYaxisScaleLine == aShowYaxisScaleLine)
        return;
    
    _chartAttr._showYaxisScaleLine = aShowYaxisScaleLine;
}

-(BOOL) showXaxisTitle
{
    return _chartAttr._showXaxisTitle;
}

-(void)setShowXaxisTitle:(BOOL)aShowXaxisTitle
{
    if (_chartAttr._showXaxisTitle == aShowXaxisTitle)
        return;
    
    _chartAttr._showXaxisTitle = aShowXaxisTitle;
    [self calcValueRect];
}

-(BOOL)showCutline
{
    return  _chartAttr._showCutline;
}

-(void)setShowCutline:(BOOL)aShowCutline
{
    if (_chartAttr._showCutline == aShowCutline)
        return;
    
    _chartAttr._showCutline = aShowCutline;
    [self calcValueRect];
}

-(BOOL)showValuePoint
{
    return  _chartAttr._showValuePoint;
}

-(void)setShowValuePoint:(BOOL)aShowValuePoint
{
    if (_chartAttr._showValuePoint == aShowValuePoint)
        return;
    
    _chartAttr._showValuePoint = aShowValuePoint;
    
}

-(BOOL)closedLine
{
    return _chartAttr._closedLine;
}

-(void)setClosedLine:(BOOL)aClosedLine
{
    if (_chartAttr._closedLine == aClosedLine)
        return;
    
    _chartAttr._closedLine  = aClosedLine;
}

-(BOOL)showValue
{
    return _chartAttr._showValue;
}

-(void)setShowValue:(BOOL)aShowValue
{
    if (_chartAttr._showValue == aShowValue)
        return;
    
    _chartAttr._showValue  = aShowValue;
  //  [self setNeedsDisplay];
}

-(BOOL)showIndicator
{
    return _chartAttr._showIndicator;
}

-(void)setShowIndicator:(BOOL)aShowIndicator
{
    if (_chartAttr._showIndicator == aShowIndicator)
        return;
    
    _chartAttr._showIndicator  = aShowIndicator;
   
    [self calcValueRect];
    
}

-(void)setChartType:(ChartType)aChartType
{
    if (_chartType == aChartType)
        return;
    
    _chartType = aChartType;
    _floatView.hidden = YES;
    if (_chartType == ChartTypeLine)
    {
        _measureUnit = 1;
        _measureWidth = 5;
        _barLayer.hidden = YES;
        _pieLayer.hidden = YES;
        _indicatorLayer.hidden = NO;
        _lineLayer.hidden = NO;
         _valueLayer = _lineLayer;
    }
    else if (_chartType == ChartTypeBar)
    {
        _measureUnit = _indexCount;
        _measureWidth = 15;
        _lineLayer.hidden = YES;
        _pieLayer.hidden = YES;
        _indicatorLayer.hidden = NO;
        _barLayer.hidden = NO;
         _valueLayer = _barLayer;
    }
    else
    {
        _lineLayer.hidden = YES;
        _barLayer.hidden = YES;
        _indicatorLayer.hidden = YES;
        _pieLayer.hidden = NO;
        _valueLayer = _pieLayer;
    }
    
    [self reloadData];
}

-(CGPoint) chartOffset
{
    return _valueLayer.visibleRect.origin;
}

-(void)setChartOffset:(CGPoint)aChartOffset
{
    //[_valueLayer scrollToPoint:aChartOffset];
   
     _measureSpacing =  87 - _measureUnit * _measureWidth;
     if (_measureSpacing > 120)
     _measureSpacing = 120;
     if (_measureSpacing < 3)
     _measureSpacing = 3;
    
    _floatView.hidden = YES;
    
    [_valueLayer scrollToRect:CGRectMake(aChartOffset.x, aChartOffset.y, _valueRect.size.width, _valueRect.size.height)];
}

#pragma mark - Extend Methods

-(void)drawChartLayer:(CALayer*)layer inContext:(CGContextRef)ctx
{

    if (layer == _yAxisLayer)
    {
        [self drawYAxisLayer:layer inContext:ctx];
    }
    else if (layer == _lineLayer)
    {
        [self drawLineLayer:layer inContext:ctx];
    }
    else if (layer == _barLayer)
    {
        [self drawBarLayer:layer inContext:ctx];
    }
  //  else if (layer == _pieLayer)
  //  {
   //     [self drawPieLayer:layer inContext:ctx];
   // }
    else;
}

- (void)changeFloatViewFrame
{
    _rightLabelWidth = 0;
    _leftLabelWidth = 0;
    
    if (_showFloatIndex != -1)
    {
        if (_showFloatIndex >= _measureCount)
            _measurelabel.text = @"";
        else 
            _measurelabel.text = [_dataSource valueInChartView:self atMeasure:_showFloatIndex];
        
        
    }
    else
    {
        _measurelabel.text = @"";
        
    }
     CGSize titleSize = [_measurelabel.text sizeWithFont:[UIFont fontWithName:@"Helvetica" size:16] forWidth:100000 lineBreakMode:UILineBreakModeWordWrap];
    _leftLabelWidth = titleSize.width+15;
    _rightLabelWidth = 40;
    for(NSInteger rowIndex = 0;rowIndex< _indexCount;++rowIndex)
    {
        NSString *nameString = nil;
        NSString *stringValue = nil;
        if ([_dataSource respondsToSelector:@selector(valueInChartView:atMeasure:atIndex:)])
        {
            if (_showFloatIndex != -1 && _showFloatIndex < _measureCount)
                stringValue = [_dataSource valueInChartView:self atMeasure:_showFloatIndex atIndex:rowIndex];
            else 
                stringValue = @"";
        }
        CGSize stringValueSize = [stringValue sizeWithFont:[UIFont fontWithName:@"Helvetica" size:15] forWidth:100000 lineBreakMode:UILineBreakModeWordWrap];
        if (stringValueSize.width > _rightLabelWidth)
        {
            _rightLabelWidth = stringValueSize.width;
        }
        
        if([_dataSource respondsToSelector:@selector(indexNameInChartView:atIndex:)])
        {
            nameString = [_dataSource indexNameInChartView:self atIndex:rowIndex];
        }
        CGSize nameStringSize = [nameString sizeWithFont:[UIFont fontWithName:@"Helvetica" size:15] forWidth:100000 lineBreakMode:UILineBreakModeWordWrap];
        if (nameStringSize.width > _leftLabelWidth)
        {
            _leftLabelWidth = nameStringSize.width;
        }
    }
    //    CGSize floatSize = _floatView.frame.size;
    CGRect  floatFrame = _floatView.frame;
    _floatView.frame = CGRectMake(self.frame.size.width-_leftLabelWidth-_rightLabelWidth-20-30, floatFrame.origin.y, _leftLabelWidth+_rightLabelWidth+20, floatFrame.size.height); 
    _closeButton.frame = CGRectMake(_floatView.frame.size.width-34, 4, 30, 30);
}


-(void)reloadData
{
    //得到指标数量和度量数量。
    _indexCount = [_dataSource indexCountInChartView:self];
    _measureCount = [_dataSource measureCountInChartView:self];
    
    if (_chartType == ChartTypeBar)
        _measureUnit = _indexCount;
    else 
        _measureUnit = 1;
    
    if (_chartType != ChartTypePie)
    {
        //根据偏移计算出开始移动的指标度量位置和结束的度量位置。
        _startMeasure = floorf((_valueLayer.visibleRect.origin.x - CHARTVIEW_LEFTINSET_WIDTH) / (_measureSpacing + _measureUnit * _measureWidth));
        if (_startMeasure < 0)
            _startMeasure = 0;
        
       // NSLog(@"SSSS:%@", NSStringFromCGRect(_valueLayer.visibleRect));
        _endMeasure = ceil((_valueLayer.visibleRect.origin.x- CHARTVIEW_LEFTINSET_WIDTH + _valueRect.size.width) / (_measureSpacing + _measureUnit * _measureWidth)) + 1;
        
        if (_endMeasure < 0)
            _endMeasure = 0;
        
        if (_endMeasure > _measureCount)
            _endMeasure = _measureCount;

        
      //  NSLog(@"offset:%f, width:%f, start:%d, end:%d", _valueLayer.visibleRect.origin.x, _valueLayer.bounds.size.width, _startMeasure,_endMeasure);
        
        
        //得到最小，最大值。并进行修改。
        double tempMinValue, tempMaxValue;
        
        _rawMinValue = [_dataSource minValueInChartView:self startMeasure:_startMeasure endMeasure:_endMeasure];
        tempMinValue = _rawMinValue;
        
        _rawMaxValue = [_dataSource maxValueInChartView:self startMeasure:_startMeasure endMeasure:_endMeasure];
        tempMaxValue = _rawMaxValue;
        
        NSInteger yAxisScaleCount = 6;
        
        //如果最大值和最小值相等。则最大加(_yAxisScaleCount-1)/2，最小减(_yAxisScaleCount-1)/2;
        if (tempMaxValue == tempMinValue)
        {
            tempMaxValue += (yAxisScaleCount-1)/2;
            tempMinValue -= (yAxisScaleCount - 1)/2;
        }
        
        //如果最大值小于最小值则反过来。
        if (tempMaxValue < tempMinValue)
        {
            double temp = tempMaxValue;
            tempMaxValue = tempMinValue;
            tempMinValue = temp;
        }
        
        NSInteger zooms = 0;
        while ((tempMaxValue - tempMinValue)/(yAxisScaleCount - 1) < 1/1.05)
        {
            tempMaxValue *= 10;
            tempMinValue *= 10;
            zooms++;
        }
        
        double unit = (tempMaxValue - tempMinValue)/(yAxisScaleCount - 1);
        double unitInt = ceil(unit);
        
        tempMinValue = floor(tempMinValue);
        tempMaxValue = tempMinValue + unitInt * (yAxisScaleCount);
       
        
        tempMinValue /= pow(10, zooms);
        tempMaxValue /= pow(10, zooms);
        
        _maxValue = tempMaxValue;
        _minValue = tempMinValue;
        
        _yAxisScaleCount = yAxisScaleCount + 1;
    }
    
    [self calcValueRect];
    
    //默认在底部。也就是减去绘制刻度的部分。
    _yAxisZeroScalePos = _valueRect.size.height - CHARTVIEW_XAXISSCALEVALUE_HEIGHT - CHARTVIEW_XAXISSCALESHORTLINE_HEIGHT;
    //数据区域的高度
    _valueAreaHeight = _valueRect.size.height - CHARTVIEW_XAXISSCALEVALUE_HEIGHT - CHARTVIEW_XAXISSCALESHORTLINE_HEIGHT;
    
    //y轴刻度值的宽度。
    _yAxisScaleValueWidth = [self calcYAxisMaxScaleValueWidth];
    
    
    //重新调整区域。
    [self calcValueRect];
    
    _valueBackLayer.frame = _valueRect;
    
    [_yAxisLayer setNeedsDisplay];
    

    /*
    //先按一般的显示，空格部分最小为1。
    _measureSpacing = 10;
    _measureWidth = 5;  //列宽部分最小为5
    
    //计算总体的宽度，如果宽度大于_valueRect的宽度,那么就按指定的区域显示,如果小于_valueRect则按满屏重新计算空间和宽度。
    CGFloat totalWidth = _measureCount * (_measureSpacing + _measureUnit * _measureWidth);
    if (totalWidth < _valueRect.size.width)
    {
        //固定元素的绘制区域为10
        _measureWidth = 5;
        
        //根据公式 (_measureSpacing + _measureUnit * _measureWidth) * _measureCount  = totalWidth;
        
        _measureSpacing = _valueRect.size.width /_measureCount  - _measureUnit * _measureWidth;
        
    }
    */
  
    
    _valueLayer.frame = _valueRect;
    
    if (_chartType == ChartTypePie)
    {
  
        [self drawPieLayer:_valueLayer inContext:nil];
    }
    else
    {
        [_valueLayer setNeedsDisplay];
    }
 
    _indicatorLayer.frame = CGRectMake(_valueRect.origin.x,
                                       _valueRect.origin.y + _valueRect.size.height + CHARTVIEW_ELEMENT_SPACING, 
                                       _valueRect.size.width, CHARTVIEW_XAXISINDICATOR_HEIGHT);
    
    //调整子层的中心点。
    CAShapeLayer *shapelayer = [_indicatorLayer.sublayers objectAtIndex:0];
    //xxx.frame = _indicatorLayer.bounds;
    //绘制指示器。
    CGFloat width = CHARTVIEW_XAXISINDICATOR_HEIGHT*0.8 * tanf(30*3.14159265358/180);
    
    CGMutablePathRef pathRef = CGPathCreateMutable();
    
    CGPathMoveToPoint(pathRef, NULL, width + 6, 2);
    CGPathAddLineToPoint(pathRef,NULL, 0 + 6, CHARTVIEW_XAXISINDICATOR_HEIGHT*0.8 + 2);
    CGPathAddLineToPoint(pathRef,NULL, 2*width + 6, CHARTVIEW_XAXISINDICATOR_HEIGHT*0.8 + 2);
    CGPathAddLineToPoint(pathRef,NULL, width + 6, 2);
    //再绘制一条线。
    CGPathAddLineToPoint(pathRef, NULL,width + 6, -_valueRect.size.height-25.0);
    shapelayer.path = pathRef;
    CGPathRelease(pathRef);
    //[_indicatorLayer setNeedsLayout];
         
    
    //绘制指示器数据层
    if (_indexCount == 0 || _measureCount == 0)
        _floatView.hidden = YES;
    
    [self bringSubviewToFront:_floatView];

    [self changeFloatViewFrame];
    [_tableView reloadData];
}

#pragma mark -tableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 30;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _indexCount;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *string =nil; 
    UIColor  *color = [UIColor whiteColor];
    NSString  *nameString = nil;
    if ([_dataSource respondsToSelector:@selector(indexColorInChartView:atIndex:)])
    {
        color = [[_dataSource indexColorInChartView:self atIndex:indexPath.row] objectAtIndex:0];
    }
    
    if ([_dataSource respondsToSelector:@selector(valueInChartView:atMeasure:atIndex:)])
    {
        if (_showFloatIndex != -1 && _showFloatIndex < _measureCount)
            string = [_dataSource valueInChartView:self atMeasure:_showFloatIndex atIndex:indexPath.row];
        else 
            string = @"";
    }
    
    if([_dataSource respondsToSelector:@selector(indexNameInChartView:atIndex:)])
    {
        nameString = [_dataSource indexNameInChartView:self atIndex:indexPath.row];
    }
    
    static NSString *chartCell = @"CHARTCELL";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:chartCell];
    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:chartCell] autorelease];
    }
    for (UIView *view in cell.contentView.subviews)
    {
        [view removeFromSuperview];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    UILabel *leftLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, _leftLabelWidth, 30)];
    leftLabel.backgroundColor = [UIColor clearColor];
    leftLabel.font = [UIFont fontWithName:@"Helvetica" size:15];
    leftLabel.textColor = color;
//    leftLabel.adjustsFontSizeToFitWidth = YES;
//    leftLabel.minimumFontSize = 13;
    if (nameString)
    {
        leftLabel.text = nameString;
    }
    [cell.contentView addSubview:leftLabel];
    [leftLabel release];
    
    UILabel *middleLabel = [[UILabel alloc] initWithFrame:CGRectMake(_leftLabelWidth+5, 0, 5, 30)];
    middleLabel.textColor = color;
    middleLabel.font = [UIFont fontWithName:@"Helvetica" size:15];
    middleLabel.text = @":";
    middleLabel.backgroundColor = [UIColor clearColor];
    [cell.contentView addSubview:middleLabel];
    [middleLabel release];
    
    UILabel *rightLabel = [[UILabel alloc] initWithFrame:CGRectMake(_leftLabelWidth+10, 0, _rightLabelWidth, 30)];
    rightLabel.textColor = color;
    rightLabel.font = [UIFont fontWithName:@"Helvetica" size:15];
    rightLabel.backgroundColor = [UIColor clearColor];
//    rightLabel.adjustsFontSizeToFitWidth = YES;
//    rightLabel.minimumFontSize = 13;
    rightLabel.textAlignment = UITextAlignmentRight;
    rightLabel.text = string;
    
    [cell.contentView addSubview:rightLabel];
    [rightLabel release];
    
    return cell;
}


@end




