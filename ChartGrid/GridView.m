//
//  GridView.m
//  ChartGrid
//
//  Created by oybq on 12-6-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//
//4444444444444
#import "GridView.h"

@implementation Col

@synthesize name;
@synthesize width;
@synthesize alignment;
@synthesize subCols;  //子列
@synthesize image;    //列的图片。
@synthesize type;
@synthesize indentation;
@synthesize lineBreakMode;
@synthesize parentCol;

-(id)init
{
    self = [super init];
    if (self != nil)
    {
        self.name = nil;
        self.width = 0;
        self.alignment = NSTextAlignmentCenter;
        NSMutableArray *array = [[NSMutableArray alloc] init];
        self.subCols = array;
        self.image = nil;
        self.type = 0;
        self.indentation = 0;
        self.lineBreakMode = 0;
    }
    
    return self;
}

-(void)dealloc
{

    self.name = nil;
    self.subCols = nil;
    self.image = nil;
    
}


@end


@implementation GridView

@synthesize dataSource = _dataSource;
@synthesize gridDelegate = _gridDelegate;
@synthesize selectedRowIndex = _selectedRowIndex;
@synthesize selectedColIndex = _selectedColIndex;
@synthesize columns = _columns;
@synthesize fixedColCount;
@synthesize rowCount = _rowCount;
@synthesize colCount = _colCount;
@synthesize colLineWidth;
@synthesize colLineColor;
@synthesize colLineStyle;
@synthesize rowLineWidth;
@synthesize rowLineColor;
@synthesize rowLineStyle;
@synthesize rowHeight;
@synthesize enableGroup;
@synthesize titleHeight;
@synthesize titleFont;
@synthesize fixedTitle;
@synthesize onlySelectTitle;
@synthesize titleColor;
@synthesize titleBackgroundColor;
@synthesize titleLineWidth;
@synthesize titleLineColor;
@synthesize borderWidth;
@synthesize borderColor;
@synthesize borderStyle;

@synthesize cellColor;
@synthesize cellFont;


-(void)construct
{
    
    _allColArray = [[NSMutableArray alloc] init];
    _allTitleHeight = 0;
    _moveState = 0;
    _firstMove = YES;
    _dataSource = nil;
    _gridDelegate = nil;
    _selectedColIndex = -1;
    _selectedRowIndex = -1;
    _columns = [NSArray array];
    self.fixedColCount = 0;
    _rowCount = 0;
    _colCount = 0;
    _fixedColWidth = 0;
    self.colLineWidth = 1;
    self.colLineColor = [UIColor blackColor];
    self.colLineStyle = 0;
    self.rowLineWidth = 1;
    self.rowLineColor = [UIColor blackColor];
    self.rowLineStyle = 0;
    self.rowHeight = 44;
    self.enableGroup = NO;
    self.titleHeight = 54;
    self.titleFont = [UIFont boldSystemFontOfSize:17];
    self.fixedTitle = NO;
    self.onlySelectTitle = YES;
    self.titleColor  =[UIColor blackColor];
    self.titleBackgroundColor = [UIColor clearColor];
    self.borderWidth = 2;
    self.borderColor = [UIColor blackColor];
    self.borderStyle = 0;
    self.titleLineColor = [UIColor blackColor];
    self.cellColor = [UIColor blackColor];
    self.cellFont = [UIFont systemFontOfSize:17];
    self.titleLineWidth = 0;
    self.delegate  = self;
    self.bounces = NO;

}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self construct];
    }
    
    return self;
}

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        [self construct];
    }
    
    return self;
}

//获取单个col的层数，这个只是用户刷新的时候使用 
- (void)getallCountwithCol:(Col*)aCol currentlayer:(NSInteger)aCurrentlayer layerCount:(NSInteger *)aLayerCount
{
    if (aCol.subCols != nil && aCol.subCols.count >0) 
    {
        aCurrentlayer ++;
        if (aCurrentlayer > *aLayerCount)
        {
            *aLayerCount = aCurrentlayer;
        }
        for (Col *subCol in aCol.subCols)
        {
            [self getallCountwithCol:subCol currentlayer:aCurrentlayer layerCount:aLayerCount];
        }
    }
    else
    {

        [_allColArray addObject:aCol];
        _colCount++;
        _totalColWidth += aCol.width;
    }
    
}


//获取一个col下面需要画的col的个数
- (void)getColsDrawColNumber:(NSInteger *)acount withCol:(Col*)aCol
{
    if (aCol.subCols && aCol.subCols.count >0)
    {
        for (Col *subCol in aCol.subCols)
        {
            [self getColsDrawColNumber:acount withCol:subCol];
        }
    }
    else
    {
        *acount +=1;
    }
    
}


//获取单个col的层数
- (void)getColLayerWithCol:(Col *)aCol currentLayer:(NSInteger)aCurrentLayer layerCount:(NSInteger *)aLayerCount
{
    if (aCol.subCols != nil && aCol.subCols.count >0) 
    {
        aCurrentLayer ++;
        if (aCurrentLayer >*aLayerCount)
        {
            *aLayerCount = aCurrentLayer;
        }
        for (Col *subCol in aCol.subCols)
        {
            
            [self getColLayerWithCol:subCol currentLayer:aCurrentLayer  layerCount:aLayerCount];
        }
    }
}


- (void)layoutSubviews
{
    [self setNeedsDisplay];
}


-(void)dealloc
{
    self.delegate = nil;
    self.colLineColor = nil;
    self.rowLineColor = nil;
    self.titleFont = nil;
    self.titleColor = nil;
    self.titleBackgroundColor = nil;
    self.borderColor = nil;
    self.titleLineColor = nil;
    self.cellColor = nil;
    self.cellFont  = nil;
    
}


//绘制内容
//区域
//文本
//文本颜色,文本字体,文本对齐方式,区域背景颜色


//新加的方法，用来处理缩进的
-(void)drawContent:(CGContextRef)ctx
              rect:(CGRect)rect
rectBackgroundColor:(UIColor*)rectBackgroundColor
             image:(UIImage*)image
              text:(NSString *)text
         textColor:(UIColor*)textColor
          textFont:(UIFont*)textFont
           colData:(Col *)coldata
              type:(NSInteger)type //type 0 是cell  1 是title  2 是group
{
       
    //绘制背景
//    NSLog(@"%@",NSStringFromCGRect(rect));

    if (rectBackgroundColor != nil && CGColorGetAlpha(rectBackgroundColor.CGColor) != 0.0)
    {
        CGContextSetFillColorWithColor(ctx, rectBackgroundColor.CGColor);
        CGContextFillRect(ctx, rect);
    }
    
    if (self.titleLineWidth) 
    {
        if (type == 1)
        {
            CGContextSetLineWidth(ctx, self.titleLineWidth);
            CGContextSetStrokeColorWithColor(ctx, self.titleLineColor.CGColor);
            
            CGContextMoveToPoint(ctx, rect.origin.x, rect.origin.y+rect.size.height);
            CGContextAddLineToPoint(ctx, rect.origin.x + rect.size.width, rect.origin.y+rect.size.height);

            //   CGContextMoveToPoint(ctx, rect.origin.x, rect.origin.y + rect.size.height);
            //   CGContextAddLineToPoint(ctx, rect.origin.x + rect.size.width, rect.origin.y + rect.size.height);
            
            CGContextStrokePath(ctx);
            
            if (self.borderStyle == 1)
            {
                CGContextSetLineWidth(ctx, 1);
                CGContextSetStrokeColorWithColor(ctx, [UIColor whiteColor].CGColor);
                
                CGContextMoveToPoint(ctx, rect.origin.x, rect.origin.y+rect.size.height-self.titleLineWidth);
                CGContextAddLineToPoint(ctx, rect.origin.x + rect.size.width, rect.origin.y+rect.size.height-self.titleLineWidth);
                //   CGContextMoveToPoint(ctx, rect.origin.x, rect.origin.y + rect.size.height);
                //   CGContextAddLineToPoint(ctx, rect.origin.x + rect.size.width, rect.origin.y + rect.size.height);
                
                CGContextStrokePath(ctx);
                
                CGContextSetLineWidth(ctx, self.titleLineWidth);
                CGContextSetStrokeColorWithColor(ctx, self.titleLineColor.CGColor);
                
                CGContextMoveToPoint(ctx, rect.origin.x, rect.origin.y+rect.size.height-self.titleLineWidth-1);
                CGContextAddLineToPoint(ctx, rect.origin.x + rect.size.width, rect.origin.y+rect.size.height-self.titleLineWidth-1);
                
                //   CGContextMoveToPoint(ctx, rect.origin.x, rect.origin.y + rect.size.height);
                //   CGContextAddLineToPoint(ctx, rect.origin.x + rect.size.width, rect.origin.y + rect.size.height);
                
                CGContextStrokePath(ctx); 
            }

        }
    }


    
    
    
    //UIColor 
    /*
     CGContextSaveGState(ctx);
     CGContextClipToRect(ctx, rect);
     CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
     CGFloat locations[2] = {0,1};
     //	CGFloat components[8] = {0.675, 0.675, 0.675, 1.0,
     //       0.837, 0.837, 0.837, 1.0};// dark
     
     //   const CGFloat *colorpt = CGColorGetComponents(rectBackgroundColor.CGColor);
     
     
     CGGradientRef gradient = CGGradientCreateWithColorComponents (rgb, components, locations, 2);
     
     CGPoint start, end;
     
     
     //画外边框 Light top to dark bottom.
     start = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
     end = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
     
     CGContextDrawLinearGradient(ctx, gradient, start, end, 0);	
     
     CGColorSpaceRelease(rgb);
     CGGradientRelease(gradient);
     
     CGContextRestoreGState(ctx);
     */
    
    
    //如果image不为nil则绘制图片。
    if (image != nil)
    {
        [image drawInRect:rect]; 
    }
    
    //绘制文本,特殊文本@@不进行绘制，表示合并处理。
    if (text != nil && text.length > 0 && ![text isEqualToString:@"@@"])
    {
        CGRect newrect = rect;
        if (type == 0)
        {
            NSInteger width = rect.size.width-2*coldata.indentation;
            if (width >0)
            {
                newrect = CGRectMake(rect.origin.x+coldata.indentation, rect.origin.y, width, rect.size.height);  
            }
        }
        NSTextAlignment alignment;
        if (type == 1 || type == 2)
        {
            alignment =  NSTextAlignmentCenter; //UITextAlignmentCenter;
        }
        else
        {
            alignment = coldata.alignment;
        }
         
        CGContextSetFillColorWithColor(ctx, textColor.CGColor);
        [text drawInRect:CGRectMake(newrect.origin.x, newrect.origin.y + (newrect.size.height - textFont.xHeight -textFont.capHeight)/2.0, newrect.size.width, textFont.xHeight)
                withFont:textFont
           lineBreakMode:coldata.lineBreakMode
               alignment:alignment];
    }
    
      
    //绘制表格的行的线,如果文本为@@则不绘制行。进行的合并。
    if (self.rowLineWidth != 0 && CGColorGetAlpha(self.rowLineColor.CGColor) != 0.0 && ![text isEqualToString:@"@@"])
    {
        CGContextSetLineWidth(ctx, self.rowLineWidth);
        CGContextSetStrokeColorWithColor(ctx, self.rowLineColor.CGColor);
        
        CGContextMoveToPoint(ctx, rect.origin.x, rect.origin.y+rect.size.height);
        CGContextAddLineToPoint(ctx, rect.origin.x + rect.size.width, rect.origin.y+rect.size.height);
        
        //   CGContextMoveToPoint(ctx, rect.origin.x, rect.origin.y + rect.size.height);
        //   CGContextAddLineToPoint(ctx, rect.origin.x + rect.size.width, rect.origin.y + rect.size.height);
        
        CGContextStrokePath(ctx);
    }
    
    //绘制竖的线
    if (self.colLineWidth != 0 && CGColorGetAlpha(self.colLineColor.CGColor) != 0.0)
    {
        CGContextSetLineWidth(ctx, self.colLineWidth);
        CGContextSetStrokeColorWithColor(ctx, self.colLineColor.CGColor);
        
        CGContextMoveToPoint(ctx, rect.origin.x, rect.origin.y);
        CGContextAddLineToPoint(ctx, rect.origin.x, rect.origin.y + rect.size.height);
        
        CGContextMoveToPoint(ctx, rect.origin.x + rect.size.width, rect.origin.y);
        CGContextAddLineToPoint(ctx, rect.origin.x + rect.size.width, rect.origin.y + rect.size.height);
        
        CGContextStrokePath(ctx);
    }

}


-(CGFloat)dealTitle:(NSInteger)startBindColIndex
    endBindColIndex:(NSInteger)endBindColIndex 
       xStartOffset:(CGFloat)xStartOffset
       yStartOffset:(CGFloat)yStartOffset
          drawIndex:(NSInteger)drawIndex
         drawHeight:(CGFloat)drawHeight
            drawCol:(Col *)drawCol
         titleblock:(void(^)(Col *col, NSInteger bindColIndex, NSInteger colIndex, CGRect rect))titleblock
{
    
    CGFloat leftInset = self.contentInset.left;
    
    CGFloat xOffset = self.contentOffset.x + leftInset;
    
    CGFloat ytitleset = self.contentOffset.y+self.contentInset.top +_allTitleHeight;
    
    //计算开始绘制的偏移量。
    CGFloat xTitleOffset = xStartOffset;
    NSInteger bindColIndex = 0;
    NSInteger ColIndex = -2;
    CGFloat  subColxStartOffset = xStartOffset;//subcol开始画的位置
    if (drawCol.subCols == nil || drawCol.subCols.count < 1)
    {
        ColIndex = [_allColArray indexOfObject:drawCol];
        drawHeight = ytitleset - yStartOffset;
    }
    if (drawIndex < self.fixedColCount && xOffset > 0)
    {
        titleblock(drawCol, bindColIndex,ColIndex,CGRectMake(xTitleOffset + xOffset, yStartOffset, drawCol.width,drawHeight));
    }
    else
    {
        titleblock(drawCol, bindColIndex,ColIndex,CGRectMake(xTitleOffset, yStartOffset, drawCol.width, drawHeight));
        
    }
    
    
    if (drawCol.subCols != nil && drawCol.subCols.count > 0)
    {
        for (Col *subCol in drawCol.subCols)
        {

            [self dealTitle:startBindColIndex 
            endBindColIndex:endBindColIndex
               xStartOffset:subColxStartOffset 
               yStartOffset:yStartOffset+drawHeight 
                  drawIndex:drawIndex
                 drawHeight:drawHeight
                    drawCol:subCol 
                 titleblock:(void(^)(Col *col, NSInteger bindColIndex, NSInteger colIndex, CGRect rect))titleblock];
            subColxStartOffset += subCol.width;
        }
         
    }
    return xTitleOffset;
}


-(CGFloat)drawTitleHelper:(CGContextRef)ctx 
                     rect:(CGRect)rect1 
             xStartOffset:(CGFloat)xStartOffset
        startBindColIndex:(NSInteger)startBindColIndex
          endBindColIndex:(NSInteger)endBindColIndex
{
//    NSLog(@"%@",NSStringFromCGRect(rect1));
    CGFloat titleWidth = 0;
    if (endBindColIndex > _columns.count )
    {
        endBindColIndex = _columns.count;
    }
    if (startBindColIndex <0)
    {
        startBindColIndex = 0;
    }
    CGFloat topInset = self.contentInset.top;
    CGFloat yOffset = self.contentOffset.y + topInset;
    CGFloat yTitleOffset = self.isFixedTitle ? yOffset : 0;
    
    titleWidth = xStartOffset;
    for (NSInteger i = startBindColIndex; i< endBindColIndex; i++)
    {
        Col *col = [_columns objectAtIndex:i];
        titleWidth += col.width;
        NSInteger layer= 1;
        [self getColLayerWithCol:col currentLayer:1 layerCount:&layer];
       
//        titleWidth += [self dealTitle:startBindColIndex
                      [self dealTitle:startBindColIndex
                      endBindColIndex:endBindColIndex
                         xStartOffset:xStartOffset
                         yStartOffset:yTitleOffset
                            drawIndex:i
                           drawHeight:_allTitleHeight/layer
                              drawCol:col
                           titleblock:^(Col *col, NSInteger bindColIndex, NSInteger colIndex, CGRect rect)
                       {
                           
                           //这里附加了一个条件，就是只对非绑定列操作。
                           UIColor *backgroundColor = nil;
                           if (colIndex == _selectedColIndex && _gridDelegate != nil && [_gridDelegate respondsToSelector:@selector(selectedColColorInGridView:)] && col.subCols == nil)
                           {
                               backgroundColor = [_gridDelegate selectedColColorInGridView:self];
                           }
                           
                           if (colIndex == _selectedColIndex && _gridDelegate != nil && [_gridDelegate respondsToSelector:@selector(selectedTitleColorInGridView:)] && col.subCols == nil)
                           {
                               backgroundColor = [_gridDelegate selectedTitleColorInGridView:self];
                           }
                           
                           if (backgroundColor == nil)
                               backgroundColor = self.titleBackgroundColor;
                           
                           [self drawContent:ctx 
                                        rect:rect
                         rectBackgroundColor:backgroundColor
                                       image:nil 
                                        text:col.name
                                   textColor:self.titleColor 
                                    textFont:self.titleFont
                                     colData:col
                                        type:1];  
                       }];
         xStartOffset += col.width;
    }
    return titleWidth;
}



-(void)drawTitle:(CGContextRef)ctx rect:(CGRect)rect
{
//    NSLog(@"%@",NSStringFromCGRect(rect));

    CGFloat topInset = self.contentInset.top;
    CGFloat leftInset = self.contentInset.left;
    
    CGFloat xOffset = self.contentOffset.x + leftInset;
    CGFloat yOffset = self.contentOffset.y + topInset;
    
    CGFloat xClipOffset = 0;
    CGFloat yClipOffset = 0;
    
    //设置裁剪区域并绘制固定部分
    CGContextClipToRect(ctx, CGRectMake(xOffset + xClipOffset, yOffset + yClipOffset, self.contentSize.width - xOffset, self.contentSize.height - yOffset));
    //画出固定的列，
    xClipOffset = [self drawTitleHelper:ctx rect:rect xStartOffset:xClipOffset startBindColIndex:0 endBindColIndex:self.fixedColCount];
    
    _fixedColWidth = xClipOffset;
    
    //重设裁剪区域并绘制可变部分
    CGContextClipToRect(ctx, CGRectMake(xOffset + xClipOffset, yOffset + yClipOffset, self.contentSize.width - xOffset, self.contentSize.height - yOffset));
    xClipOffset = [self drawTitleHelper:ctx rect:rect xStartOffset:xClipOffset startBindColIndex:self.fixedColCount endBindColIndex:_columns.count];
    
    
    //绘制标题部分的底部线段。
    
    
}



//返回单元格列的宽度。
-(CGFloat)dealCell:(NSInteger)startBindColIndex
   endBindColIndex:(NSInteger)endBindColIndex
      xStartOffset:(CGFloat)xStartOffset
          rowblock:(void(^)(NSInteger rowIndex))rowblock
         cellblock:(void(^)(Col *col, NSInteger rowIndex, NSInteger colIndex, CGRect *prect))cellblock
{
    
    CGFloat topInset = self.contentInset.top;
    CGFloat leftInset = self.contentInset.left;
    
    CGFloat xOffset = self.contentOffset.x + leftInset;
    CGFloat yOffset = self.contentOffset.y + topInset;
    
    //获取开始偏移量
    CGFloat xCellOffset = xStartOffset;
    CGFloat yCellOffset = _allTitleHeight;
    
    
    //计算从0列到startBindColIndex之间的真实列。
//    NSInteger bindColIndex = 0;
//    NSInteger startColIndex = 0;
//    for (;bindColIndex < startBindColIndex; bindColIndex++)
//    {
//         Col *col = [_columns objectAtIndex:bindColIndex];
//        [self getColsDrawColNumber:&startColIndex withCol:col];
//
//    }
    
    
    //循环行，这里可以进行优化，只绘制显示的行。。
    NSInteger newStartRow = floorf((yOffset - (self.fixedTitle ? 0: _allTitleHeight)) / self.rowHeight);
    NSInteger newEndRow = ceilf(((yOffset - (self.fixedTitle ? 0: _allTitleHeight)) + self.frame.size.height) / self.rowHeight) + 1;
    
    if (newStartRow < 0)
        newStartRow = 0;
    
    if (newEndRow >= _rowCount)
        newEndRow = _rowCount;
    

        for (NSInteger colIndex =startBindColIndex ; colIndex < endBindColIndex; ++colIndex)
        {
            //循环新生成的只有需要画的col的数组，
            Col *col = [_allColArray objectAtIndex:colIndex];
            for (NSInteger rowIndex = newStartRow; rowIndex <newEndRow; rowIndex++)
            {
                if (rowblock != nil)
                    rowblock(rowIndex);
                
                if (colIndex < _allfixSubColCount && xOffset > 0)
                {
                    CGRect rc  = CGRectMake(xCellOffset + xOffset, yCellOffset + rowIndex * self.rowHeight, col.width, self.rowHeight);
                    cellblock(col, rowIndex, colIndex, &rc);
                }
                else
                {
                    CGRect rc = CGRectMake(xCellOffset , yCellOffset + rowIndex * self.rowHeight, col.width, self.rowHeight);
                    cellblock(col, rowIndex, colIndex, &rc);
                }
                
            }
            xCellOffset += col.width;
         }    
        /*
        NSInteger colIndex = startColIndex;
        xCellOffset = xStartOffset;
        for (bindColIndex = startBindColIndex; bindColIndex < endBindColIndex; bindColIndex++)
        {
            Col *col = [_columns objectAtIndex:bindColIndex];
            
            if (col.subCols != nil && col.subCols.count != 0)
            {
                for (Col *subCol in col.subCols)
                {
                    if (bindColIndex < self.fixedColCount && xOffset > 0)
                    {
                        cellblock(subCol, rowIndex, colIndex, CGRectMake(xCellOffset + xOffset, yCellOffset + rowIndex * self.rowHeight, subCol.width, self.rowHeight));
                    }
                    else
                    {
                        cellblock(subCol, rowIndex, colIndex,CGRectMake(xCellOffset, yCellOffset + rowIndex * self.rowHeight, subCol.width, self.rowHeight));
                    }                    
                    colIndex++;
                    xCellOffset += subCol.width;
                }
            }
            else 
            {
                //计算区域。
                if (bindColIndex < self.fixedColCount && xOffset > 0)
                {
                    cellblock(col, rowIndex, colIndex, CGRectMake(xCellOffset + xOffset, yCellOffset + rowIndex * self.rowHeight, col.width, self.rowHeight));
                }
                else
                {
                    cellblock(col, rowIndex, colIndex, CGRectMake(xCellOffset, yCellOffset + rowIndex * self.rowHeight, col.width, self.rowHeight));
                }
                
                xCellOffset += col.width;
                colIndex++;
            }
        }
         */
    
    
    return xCellOffset;
}


-(CGFloat)drawCellHelper:(CGContextRef)ctx 
                    rect:(CGRect)rect1 
            xStartOffset:(CGFloat)xStartOffset
       startBindColIndex:(NSInteger)startBindColIndex
         endBindColIndex:(NSInteger)endBindColIndex
{
    return [self dealCell:startBindColIndex endBindColIndex:endBindColIndex
             xStartOffset:xStartOffset
                 rowblock:^(NSInteger rowIndex)
            {
                //获取背景行
                _cellBackgroundColor = nil;
                if (_gridDelegate != nil && [_gridDelegate respondsToSelector:@selector(gridView:colorAtRow:)])
                {
                    _cellBackgroundColor = [_gridDelegate gridView:self colorAtRow:rowIndex];
                }
                
                //取选中的行
                if (rowIndex == _selectedRowIndex &&  _gridDelegate != nil && [_gridDelegate respondsToSelector:@selector(selectedRowColorInGridView:)])
                {
                    _cellBackgroundColor = [_gridDelegate selectedRowColorInGridView:self];
                }
                
                                
            }
                cellblock:^(Col *col, NSInteger rowIndex, NSInteger colIndex, CGRect *prect) {
                    
                    
                    //先绘制视图。
                    UIView *cellView = nil;
                    if (col.type == 1 )
                    {
                        [[self viewWithTag:(100 + rowIndex)] removeFromSuperview];
                        
                        //判断当前列的位置，如果位置在顶部则不创建。
                        CGFloat topInset = self.contentInset.top;
                        CGFloat leftInset = self.contentInset.left;
                        
                        CGFloat xOffset = self.contentOffset.x + leftInset;
                        CGFloat yOffset = self.contentOffset.y + topInset;
                        if (self.isFixedTitle)
                            yOffset +=_allTitleHeight;
                        xOffset += _fixedColWidth;
                        
                        
                        
                        //if (rect.origin.y > yOffset
                        
                        if ((prect->origin.y >=  yOffset - 10) &&
                            (prect->origin.x >= xOffset - 10) &&
                            [_dataSource respondsToSelector:@selector(gridView:viewFromRow:viewFromCol:)])
                            cellView = [_dataSource gridView:self viewFromRow:rowIndex viewFromCol:colIndex]; 
                    }
                    
                    //如果有视图则先画视图。
                    if (cellView != nil)
                    {
                        cellView.frame = *prect;
                        cellView.tag = 100 + rowIndex; //行和列的结合体。
                        [self addSubview:cellView];
                    }
                    
                    //如果是列选中则选中的格子为列的颜色
                    UIColor *backgroundColor = nil;
                    if (!onlySelectTitle &&  colIndex == _selectedColIndex && _gridDelegate != nil && [_gridDelegate respondsToSelector:@selector(selectedColColorInGridView:)])
                    {
                        backgroundColor = [_gridDelegate selectedColColorInGridView:self];
                    }
                    
                    
                    if (backgroundColor == nil)
                        backgroundColor = _cellBackgroundColor;
                    
                    if (backgroundColor == nil)
                    {
                        if (_gridDelegate != nil && [_gridDelegate respondsToSelector:@selector(gridView:colorAtRow:atCol:)])
                        {
                            backgroundColor = [_gridDelegate gridView:self colorAtRow:rowIndex atCol:colIndex];
                        }
                        
                    }
                    
                    
                    //取图片
                    UIImage *image = nil;
                    if ([_dataSource respondsToSelector:@selector(gridView:imageFromRow:imageFromCol:)])
                    {
                        image = [_dataSource gridView:self imageFromRow:rowIndex imageFromCol:colIndex];
                    }
                    
                    
                    //绘制格子内容
//                    [self drawContent:ctx 
//                                 rect:rect 
//                  rectBackgroundColor:backgroundColor 
//                                image:image 
//                                 text:[_dataSource gridView:self cellFromRow:rowIndex cellFromCol:colIndex] 
//                            textColor:self.cellColor 
//                             textFont:self.cellFont 
//                        textAlignment:col.alignment];
                    
                    
                    //检查是否单元格有特定的颜色。
                    
                    
                    [self drawContent:ctx 
                                 rect:*prect
                  rectBackgroundColor:backgroundColor
                                image:image
                                 text:[_dataSource gridView:self cellFromRow:rowIndex cellFromCol:colIndex]
                            textColor:self.cellColor
                             textFont:self.cellFont
                              colData:col
                                 type:0];  
                    
                }];
}

//通过一个点，获取该点所在的col，画表格用
- (NSInteger)getLimitColIndexWithPoint:(NSInteger) aPoint 
{
    NSInteger limitColIndex = 0;
    NSInteger width = 0;
    for (NSInteger i = 0; i < _allColArray.count; ++i)
    {
        Col *drawCol = [_allColArray objectAtIndex:i];
        width += drawCol.width;
        if (width > aPoint)
        {
            limitColIndex = i;
//            NSLog(@"width:%d--limitcolIndex:%d",width,limitColIndex);
            break;
        }
    }
    if (width != 0 && width <= aPoint)
    {
        limitColIndex = _allColArray.count -1;
    }
    return limitColIndex;
}

//获取一个点所在的位置  需要考虑偏移，处理点击事件
- (NSInteger)getRealColIndexWithPoint:(NSInteger)aPoint
{
    NSInteger realColIndex = -1;
    NSInteger width = 0;
    for (NSInteger i = 0; i < _allColArray.count; ++i)
    {
        Col *drawCol = [_allColArray objectAtIndex:i];
        width += drawCol.width;
        CGFloat realxOffset = width + (i<_allfixSubColCount ? self.contentOffset.x :0);
        if (realxOffset > aPoint)
        {
            realColIndex = i;
//            NSLog(@"width:%0.2f--realColIndex:%d",realxOffset,realColIndex);
            break;
        }
    }
    if (realColIndex == -1)
    {
        realColIndex = _allColArray.count -1;
    }
    
    return realColIndex; 
}

- (float)getStratxwithStratColIndex:(NSInteger)aColIndex 
{
    float startX = 0;
    if (aColIndex > _allColArray.count)
    {
        aColIndex = _allColArray.count;
    }
    for (NSInteger i = 0; i <aColIndex; ++i)
    {
        Col *col = [_allColArray objectAtIndex:i];
        startX += col.width;
       
    }

//    NSLog(@"startX  %0.2f",startX);
    return startX;
}

 
-(void)drawCell:(CGContextRef)ctx rect:(CGRect)rect1
{
    CGFloat topInset = self.contentInset.top;
    CGFloat leftInset = self.contentInset.left;
    
    CGFloat xOffset = self.contentOffset.x + leftInset;
    CGFloat yOffset = self.contentOffset.y + topInset;
    
    
    CGFloat xClipOffset = 0;
    CGFloat yClipOffset = self.isFixedTitle ? _allTitleHeight : 0;
    
    //设置裁剪区域。绘制固定部分
    CGContextClipToRect(ctx, CGRectMake(xOffset + xClipOffset,  yOffset + yClipOffset, self.contentSize.width, self.contentSize.height));
    //这边绘制固定的列，_allfixSubColCount为所有的固定列，固定的单个col（没有subcol的col）
    xClipOffset = [self drawCellHelper:ctx rect:rect1 xStartOffset:xClipOffset startBindColIndex:0 endBindColIndex:_allfixSubColCount];
 
    
    //重新设置裁剪区域。绘制可变部分
    CGContextClipToRect(ctx, CGRectMake(xOffset + xClipOffset,  yOffset + yClipOffset, self.contentSize.width, self.contentSize.height));
    
    NSInteger strartColIndex = _allfixSubColCount;
    NSInteger endColIndex = _allColArray.count;
    
    //根据当前的contentoffset来判断应该从那个列开始画起，这边只画不固定的部分
    NSInteger limitStart = [self getLimitColIndexWithPoint:(NSInteger)xOffset];
    if (limitStart  > strartColIndex)
    {
        strartColIndex = limitStart ;
    }
    
    NSInteger limitEnd = [self getLimitColIndexWithPoint:(NSInteger)(xOffset+self.frame.size.width)];
    endColIndex = limitEnd+1;
    if (limitEnd +1 > _allColArray.count)
    {
        endColIndex = _allColArray.count;
    }
    
    //根据开始列，求出画列开始的位置，由于做了修改
    xClipOffset = [self getStratxwithStratColIndex:strartColIndex];
//    NSLog(@"newxClipOffset%0.2f",xClipOffset);
    
    //这边从xClipOffset开始画，strartColIndex为开始画的列，endColIndex为最后的列
    xClipOffset = [self drawCellHelper:ctx rect:rect1 xStartOffset:xClipOffset startBindColIndex:strartColIndex endBindColIndex:endColIndex];
    
}



-(void)drawGroup:(CGContextRef)ctx rect:(CGRect)rect
{
    CGFloat topInset = self.contentInset.top;
    CGFloat leftInset = self.contentInset.left;
    
    CGFloat xOffset = self.contentOffset.x + leftInset;
    CGFloat yOffset = self.contentOffset.y + topInset;
    
    
    CGFloat xClipOffset = 0;
    CGFloat yClipOffset = self.isFixedTitle ? _allTitleHeight : 0;
    
    //设置裁剪区域。绘制固定部分
    CGContextClipToRect(ctx, CGRectMake(xOffset + xClipOffset,  yOffset + yClipOffset, self.contentSize.width, self.contentSize.height));
    
    
    for (NSInteger rowIndex = 0; rowIndex < _rowCount; rowIndex++)
    {
        if ([_dataSource respondsToSelector:@selector(gridView:groupTextFromRow:)])
        {
            NSString *groupText = [_dataSource gridView:self groupTextFromRow:rowIndex];
            if (groupText != nil)
            {
                
//                [self drawContent:ctx 
//                             rect:CGRectMake(xOffset, _allTitleHeight + rowIndex * self.rowHeight, self.contentSize.width, self.rowHeight)
//              rectBackgroundColor:[UIColor greenColor]
//                            image:nil 
//                             text:groupText 
//                        textColor:[UIColor blackColor]
//                         textFont:[UIFont systemFontOfSize:20]
//                    textAlignment:1];
                
                [self drawContent:ctx 
                             rect:CGRectMake(xOffset, _allTitleHeight + rowIndex * self.rowHeight, self.frame.size.width, self.rowHeight)
              rectBackgroundColor:[UIColor clearColor]
                            image:nil 
                             text:groupText
                        textColor:self.titleColor 
                         textFont:self.titleFont
                          colData:nil
                             type:2];  
            }
        }
    }    
}


-(void)drawControl:(CGContextRef)ctx rect:(CGRect)rect
{

    //画标题部分
    CGContextSaveGState(ctx);
    [self drawTitle:ctx rect:rect];
    CGContextRestoreGState(ctx);

    //画格子部分
    CGContextSaveGState(ctx);
    [self drawCell:ctx rect:rect];
    CGContextRestoreGState(ctx);
    
    //绘制组部分
    if (self.enableGroup)
    {
        CGContextSaveGState(ctx);
        [self drawGroup:ctx rect:rect];
        CGContextRestoreGState(ctx);
    }
    
    if (self.borderWidth != 0 && CGColorGetAlpha(self.borderColor.CGColor) != 0.0)
    {
        CGContextSetLineWidth(ctx, self.borderWidth);
        CGContextSetStrokeColorWithColor(ctx, self.borderColor.CGColor);
        
        //线框在字的外面
      
        //线框固定的
        CGContextStrokeRect(ctx, CGRectMake(self.contentOffset.x + self.contentInset.left, 
                                            self.contentOffset.y + self.contentInset.top, 
                                            self.frame.size.width -self.contentInset.left*2,
                                            self.frame.size.height - self.contentInset.top*2));
        
        
        if (self.borderStyle == 1)
        {
             //线框在字的外面
           //线框固定的
            CGContextStrokeRect(ctx, CGRectMake(self.contentOffset.x+1, 
                                                self.contentOffset.y+1, 
                                                self.frame.size.width-2,
                                                self.frame.size.height-2));
            //需要画一个白色的框来遮住多出来的字
            CGContextSetLineWidth(ctx, 0.5);
            CGContextSetStrokeColorWithColor(ctx, [UIColor whiteColor].CGColor);
            CGContextStrokeRect(ctx, CGRectMake(self.contentOffset.x+1+self.borderWidth, 
                                                self.contentOffset.y+1+self.borderWidth, 
                                                self.frame.size.width-2-self.borderWidth*2,
                                                self.frame.size.height-2-self.borderWidth*2));

        }
        
        
    }
    
}



-(void)drawRect:(CGRect)rect
{    
    if (_columns.count <fixedColCount)
    {
        return;
    }
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.0f);
    
    CGContextRef ctx1 = UIGraphicsGetCurrentContext();
    
    
    //这里可以先在内存中绘制，然后统一贴到设备上下文中。
    
    CGContextTranslateCTM(ctx1, 0, 1*rect.size.height);
    CGContextScaleCTM(ctx1, 1, -1);
    CGContextTranslateCTM(ctx1, -1*self.contentOffset.x, -1*self.contentOffset.y);
    
    
    [self drawControl:ctx1 rect:rect];
    
    UIImage *ii = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGContextDrawImage(ctx, rect, ii.CGImage);
    
 
    
}
 

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
   // [super touchesBegan:touches withEvent:event];
    
    CGPoint ptOrg = [[touches anyObject] locationInView:self];   //[ gestureRecognizer locationInView:self];
    CGPoint pt = ptOrg;
    
    //在外面单击不做处理。
    if (pt.x < 0 || pt.y < 0 || pt.x > self.contentSize.width || pt.y > self.contentSize.height)
        return;
    
    
    CGFloat topInset = self.contentInset.top;
//    CGFloat leftInset = self.contentInset.left;
    
//    CGFloat xOffset = self.contentOffset.x + leftInset;
    CGFloat yOffset = self.contentOffset.y + topInset;
    
    //计算单击的列
    NSInteger selectedColIndex = -1;
    selectedColIndex = [self getRealColIndexWithPoint:(NSInteger)ptOrg.x];
//    NSLog(@"选中列 %d  点击的x： %0.2f",selectedColIndex,ptOrg.x);
    
    //如果是在列头单击则更新当前选中的列。
    if (ptOrg.y - _allTitleHeight - (self.isFixedTitle ? yOffset : 0) < 0)
    {
        //计算单击的列。
        if (selectedColIndex != -1)
        {
//            if (selectedColIndex >self.fixedColCount -1 && selectedColIndex < _colCount-2) 
//            {
                _selectedColIndex = selectedColIndex; 
//                if (_gridDelegate != nil && selectedColIndex > self.fixedColCount -1) //选中的标题列大于绑定列
//                {
                    if ([_gridDelegate respondsToSelector:@selector(selectedTitleColorInGridView:)]|| [_gridDelegate respondsToSelector:@selector(selectedColColorInGridView:)])
                    {
                        [self setNeedsDisplay];
                    }
                    
//                }
                
                //处理单击处理协议函数
                if (_gridDelegate != nil && [_gridDelegate respondsToSelector:@selector(gridView:clickAtCol:)])
                {
                    [_gridDelegate gridView:self clickAtCol:_selectedColIndex];
                }

//            }
        }
        
        return;
        
    }
    
    
    
    
    //计算在行上单击
    
    //减去标题头部分的高度。
    NSInteger  selectedRowIndex = -1;
    pt.y -= _allTitleHeight;
    selectedRowIndex = pt.y / self.rowHeight;
    if (selectedRowIndex < 0 || selectedRowIndex >= _rowCount )//|| selectedRowIndex == _selectedRowIndex)
        return;
    
    _selectedRowIndex = selectedRowIndex;
    
    //是否需要重绘表格。看有没有选中行的颜色。如果没有则不需要重新绘制。
    if (_gridDelegate != nil && [_gridDelegate respondsToSelector:@selector(selectedRowColorInGridView:)])
    {
        [self setNeedsDisplay];
    }
    //处理单击处理协议函数
    if (_gridDelegate != nil && [_gridDelegate respondsToSelector:@selector(gridView:clickAtRow:atCol:)])
    {
        [_gridDelegate gridView:self clickAtRow:_selectedRowIndex atCol:selectedColIndex];
    }
    
    
    
    
}





#pragma mark -
#pragma mark public method




-(void)reloadGridData
{
    
    //如果偏移大于当前的最大宽高，则重置当前的偏移量为最大宽高
    CGPoint offsetPt = self.contentOffset;
    if (offsetPt.x > _totalColWidth)
        offsetPt.x = _totalColWidth;
    if (offsetPt.y > _totalRowHeight)
        offsetPt.y = _totalRowHeight;
    
    if (!CGPointEqualToPoint(offsetPt, self.contentOffset))
        self.contentOffset = offsetPt;
    
    
    [self setNeedsDisplay];
//    [self setNeedsDisplayInRect:CGRectMake(self.contentOffset.x, self.contentOffset.y, self.frame.size.width, self.frame.size.height)];
    
}


//外界刷新重新设置gridview的值
- (void)getData
{
    [_allColArray removeAllObjects];
    _userReload = YES;
    _allfixSubColCount  = 0;
    _scrollStratPoint = CGPointMake(0, 0);
    _allTitleHeight =0;
    //根据行数和列数计算容器的大小。
    _totalColWidth = 0;
    _totalRowHeight = 0;
    _maxTitleLayerCount = 0;
    if (_dataSource == nil)
        return;
    
    //得到列数组
   
    
    _columns = [[_dataSource columnsInGridView:self] copy];
    
    //计算列宽
    _colCount = 0;
    for (Col *col in _columns)
    {
        NSInteger layerCount = 1;
        [self getallCountwithCol:col currentlayer:1 layerCount:&layerCount];
        if (layerCount > _maxTitleLayerCount)
        {
            _maxTitleLayerCount = layerCount;
        }
        /*
         //判断是否有子列，如果有则以子列为标准计算。
         if (col.subCols != nil && col.subCols.count != 0)
         {
         for (Col *subCol in col.subCols)
         {
         _totalColWidth += subCol.width;
         _colCount++;
         }
         }
         else 
         {
         _totalColWidth += col.width;
         _colCount++;
         }
         */
        
    }
    for (NSInteger i = 0 ; i<self.fixedColCount; i++)
    {
        if (i < [_columns count])
        {
            Col *fixedCol = [_columns objectAtIndex:i];
            [self getColsDrawColNumber:&_allfixSubColCount withCol:fixedCol];
            //        [self addFixedColCountWithCol:fixedCol];
        }
    }
    //    NSLog(@"%d",_allfixSubColCount);

    
    _allTitleHeight =self.titleHeight * _maxTitleLayerCount;
    if (_maxTitleLayerCount == 1)
    {
        _allTitleHeight = self.rowHeight;
    }
    
    //计算行高，行高由标题行高＋行数*行高
    _rowCount = [_dataSource rowCountInGridView:self];
    _totalRowHeight = _allTitleHeight + self.rowHeight * _rowCount;
    
    //重新设置当前的内容的size
    self.contentSize = CGSizeMake(_totalColWidth, _totalRowHeight);  
}

-(void)reloadData
{
    
    [self getData];
    [self changeAllColumnWidth];
    self.contentOffset = CGPointMake(0, 0);
    [self reloadGridData];
    
}

//保持现有的位置
- (void)reloadCurrentOffsettData
{
    [self getData];
    [self reloadGridData];
}


- (void)reloadDataChangeCurrentOffset:(BOOL)aBool
{
    if (aBool)
    {
        self.contentOffset = CGPointMake(0, 0);
    }
    [self getData];
    [self changeAllColumnWidth];
    [self reloadGridData];
}



//得到某行某列的文本串
-(NSString*)cellTextFromRow:(NSInteger)aRowIndex col:(NSInteger)aColIndex
{
    if (aRowIndex < 0 || aRowIndex >= _rowCount || aColIndex < 0 || aColIndex >= _colCount)
        return nil;
    
    return [_dataSource gridView:self cellFromRow:aRowIndex cellFromCol:aColIndex];
    
}

//得到某列的数据结构，这里不是绑定列。  这个放后面做，用来获取到这边的col的
-(Col*) columnFrom:(NSInteger)aColIndex
{
    if (aColIndex < 0 || aColIndex >= _colCount)
        return nil;

    
    NSInteger colIndex = 0;
    for (Col *col in _columns)
    {
        if (col.subCols != nil && col.subCols.count >0)
        {
            for (Col *subCol in col.subCols)
            {
                if (colIndex == aColIndex)
                    return subCol;
                
                colIndex++;
            }
            
        }
        else
        {
            if (colIndex == aColIndex)
                return col;
            
            colIndex++;
            
        }
    }
    
    return nil;
}


-(Col*)subColumnFrom:(NSInteger)aColIndex
{
    Col *subCol = nil;
    if (aColIndex >=0 && aColIndex < _allColArray.count )
    {
        subCol = [_allColArray objectAtIndex:aColIndex];
    }
    return subCol;
}

-(void)changeColumWidth:(Col *)aCol
{
    NSInteger width = 0;
    if (aCol)
    {
        
        for (Col *subCol in aCol.subCols)
        {
            width += subCol.width;
        }
        aCol.width = width;
    }
    if (aCol.parentCol)
    {
        [self changeColumWidth:aCol.parentCol];
    }
}

//改变各个列的宽度
-(void)changeAllColumnWidth
{
    for (Col *col in _allColArray)
    {
        if (col.parentCol)
        {
            [self changeColumWidth:col.parentCol]; 
        }
    }
}

-(NSInteger) getColumnIndexFromBindColIndex:(NSInteger)aBindColIndex subColIndex:(NSInteger)aSubColIndex
{
    NSInteger index = 0;
//    NSLog(@"column.count:%d", _columns.count);
    for (NSInteger i = 0; i < aBindColIndex; i++)
    {
        Col *col = [_columns objectAtIndex:i];
        if (col.subCols != nil && col.subCols.count > 0)
        {
            index += col.subCols.count;
        }
        else
        {
            index ++;
        }
    }
    index += aSubColIndex;
    
    return index;
}

-(CGRect) rectForRow:(NSInteger)aRowIndex col:(NSInteger)aColIndex
{
 /*   CGFloat topInset = self.contentInset.top;
    CGFloat leftInset = self.contentInset.left;
    
    CGFloat xOffset = self.contentOffset.x + leftInset;
    CGFloat yOffset = self.contentOffset.y + topInset;
    
    
    CGFloat xClipOffset = 0;
    CGFloat yClipOffset = self.isFixedTitle ? _allTitleHeight : 0;
    
    
    
    //这边绘制固定的列，_allfixSubColCount为所有的固定列，固定的单个col（没有subcol的col）
    xClipOffset = [self drawCellHelper:ctx rect:rect1 xStartOffset:xClipOffset startBindColIndex:0 endBindColIndex:_allfixSubColCount];
    
    
    //重新设置裁剪区域。绘制可变部分
    CGContextClipToRect(ctx, CGRectMake(xOffset + xClipOffset,  yOffset + yClipOffset, self.contentSize.width, self.contentSize.height));
    
    NSInteger strartColIndex = _allfixSubColCount;
    NSInteger endColIndex = _allColArray.count;
    
    //根据当前的contentoffset来判断应该从那个列开始画起，这边只画不固定的部分
    NSInteger limitStart = [self getLimitColIndexWithPoint:(NSInteger)xOffset];
    if (limitStart  > strartColIndex)
    {
        strartColIndex = limitStart ;
    }
    
    NSInteger limitEnd = [self getLimitColIndexWithPoint:(NSInteger)(xOffset+self.frame.size.width)];
    endColIndex = limitEnd+1;
    if (limitEnd +1 > _allColArray.count)
    {
        endColIndex = _allColArray.count;
    }
    
    //根据开始列，求出画列开始的位置，由于做了修改
    xClipOffset = [self getStratxwithStratColIndex:strartColIndex];
    //    NSLog(@"newxClipOffset%0.2f",xClipOffset);
    
    //这边从xClipOffset开始画，strartColIndex为开始画的列，endColIndex为最后的列
    xClipOffset = [self drawCellHelper:ctx rect:rect1 xStartOffset:xClipOffset startBindColIndex:strartColIndex endBindColIndex:endColIndex];*/
    
    return CGRectZero;
    

}


#pragma mark -scrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGPoint movePoint = CGPointMake(fabsf(scrollView.contentOffset.x), fabsf(scrollView.contentOffset.y));
    if (_firstMove)
    {
        float differentx = movePoint.x - _scrollStratPoint.x;
        float differenty = movePoint.y - _scrollStratPoint.y;
        if (fabs(differentx) > fabs(differenty))
        {
            _moveState = 1;
        }
        else
        {
            _moveState = 2;
        }
        _firstMove = NO;
    }

    if (_moveState == 0)
    {
   
    }
    else if(_moveState == 1)
    {
        scrollView.contentOffset = CGPointMake(movePoint.x, _scrollStratPoint.y);  
    }
    else
    {
        scrollView.contentOffset = CGPointMake(_scrollStratPoint.x, movePoint.y);
    }
//    if (_userReload)
//    {
//        scrollView.contentOffset = CGPointMake(0, 0); 
//    }
//    NSLog(@"%d,contentOffset :%@",_moveState,NSStringFromCGPoint(movePoint));
    [self reloadGridData]; 
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
//    NSLog(@"11");
    _scrollStratPoint =CGPointMake(fabsf(scrollView.contentOffset.x), fabsf(scrollView.contentOffset.y));// scrollView.contentOffset;
    
    _firstMove = YES;
    _userReload = NO;
}


@end

