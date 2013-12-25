//
//  ChartView.h
//  ChartGrid
//
//  Created by oybq on 12-7-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

//定义一些图像的宽度。
#define CHARTVIEW_ELEMENT_SPACING 3            //元素间隔
#define CHARTVIEW_MAJORTITLE_HEIGHT 55         //标题高度
#define CHARTVIEW_MINORTITLE_HEIGHT 30         //副标题高度

#define CHARTVIEW_YAXISTITLE_WIDTH 40          //y轴标题宽度
#define CHARTVIEW_YAXISSCALEVALUE_WIDTH 50     //y轴刻度值宽度
#define CHARTVIEW_YAXISSCALESHORTLINE_WIDTH 6  //Y轴刻度短线宽度

#define CHARTVIEW_XAXISTITLE_HEIGHT 40          //x轴标题高度
#define CHARTVIEW_XAXISSCALEVALUE_HEIGHT  40    //x轴刻度值高度
#define CHARTVIEW_XAXISINDICATOR_HEIGHT    20   //x轴指示器高度。
#define CHARTVIEW_XAXISSCALESHORTLINE_HEIGHT  6 //x轴短线的高度。
#define CHARTVIEW_CUTLINE_WIDTH  80             //图例宽度。
#define CHARTVIEW_LEFTINSET_WIDTH 39            //内容左边移动时可以的内容。
#define CHARTVIEW_XAXISSCALESTEP  6             //x轴刻度的步长
#define CHARTVIEW_RIGHTINSET_WIDTH 80           //内容右边移动时可以的内容。

typedef enum ChartType
{
    ChartTypeLine = 1,
    ChartTypeBar = 2,
    ChartTypePie = 3
}ChartType;


@class ChartView;

@protocol ChartViewDataSource <NSObject>

//得到最大值
- (double)maxValueInChartView:(ChartView*)chartView startMeasure:(NSInteger)aStartMeasure endMeasure:(NSInteger)aEndMeasure;

//得到最小值
- (double)minValueInChartView:(ChartView*)chartView startMeasure:(NSInteger)aStartMeasure endMeasure:(NSInteger)aEndMeasure;

//指标的数量
- (NSInteger)indexCountInChartView:(ChartView*)chartView;

//度量的数量
- (NSInteger)measureCountInChartView:(ChartView*)chartView;

//获取度量的值
- (NSString*)valueInChartView:(ChartView*)chartView atMeasure:(NSInteger)aMeasure;

//获取指标值。
- (NSString*)valueInChartView:(ChartView*)chartView atMeasure:(NSInteger)aMeasure atIndex:(NSInteger)aIndex;


@optional

//得到每个指标的名字
- (NSString*)indexNameInChartView:(ChartView*)chartView atIndex:(NSInteger)aIndex;

//得到每个指标的颜色,这里为了支持渐变，返回一个UIColor数组。如果是1个就只有一个颜色。
- (NSArray*)indexColorInChartView:(ChartView*)chartView atIndex:(NSInteger)aIndex;

//得到每个度量的颜色，这里为了支持饼图， 为了支持渐变，返回一个UIColor数组。如果是1个就只有一个颜色。
-(NSArray*)measureColorInChartView:(ChartView*)chartView atMeasure:(NSInteger)aMeasure;

//得到y轴的标题内容,如果返回nil则不显示y轴标题
- (NSString*)yAxisTitleOfChartView:(ChartView*)chartView;

//得到x轴的标题内容,如果返回nil则不显示x轴标题
- (NSString*)xAxisTitleOfChartView:(ChartView*)chartView;

@end

/*
  趋势图。线型,条型,饼型图。
  图视一个层，横坐标一个层，数据一个层，纵坐标一个层。
  先得到最高值和最低值，然后计算刻度，绘制横线。总是从0开始。得到最高和最低。然后最低
  然后得到多少行，当前的指标值，行值间隔。得到内容。
  绘制饼型图，一个系列一个饼。一个行一个区域, 然后计算。如果是负数呢
*/
@interface ChartView : UIView <UITableViewDelegate,UITableViewDataSource>
{
    id<ChartViewDataSource> _dataSource;
    
    NSInteger _indexCount;              //指标数量,也就是纵轴的数量
    NSInteger _measureCount;            //度量数量,也就是横轴的数量
    NSInteger _startMeasure;            //开始计算的度量索引位置 
    NSInteger _endMeasure;              //结束结算的索引位置。
    
        
    //用于绘制刻度
    double  _minValue;                 //最小值
    double  _maxValue;                 //最大值
    double _rawMinValue;               //原始最小值
    double _rawMaxValue;               //原始最大值
    
    CALayer *_valueBackLayer;          //背景颜色层
    CALayer *_yAxisLayer;               //y轴的层
    CAScrollLayer *_lineLayer;          //线型图层    
    CAScrollLayer *_barLayer;           //条形图层
    CAScrollLayer *_pieLayer;           //饼图层
    CAScrollLayer *_valueLayer;         //内容层，内容层只是线和条形的一个引用。
    CALayer *_indicatorLayer;           //指示器层。
    NSObject *_innerLayerDelegate;      //层的绘制委托

    CGFloat _measureSpacing;            //x轴每个值刻度的间隔
    CGFloat _measureWidth;              //x轴每个刻度的宽度
    NSInteger _measureUnit;             //一个刻度下的宽度的数量，对于线性是1，对于条形图是指标的数量。如果是有线性和条形图则以条形为基础。刻度的单位
                                        //整个的图表的宽度为 (_measureWidth*_measureUnit + _measureSpacing)*_measureCount;
    
        
    ChartType _chartType;          //图表类型1为线图，2为柱图
    
    CGRect _valueRect;                  //数据显示区域。从这个区域包括绘制的x轴的刻度部分
    CGFloat _yAxisZeroScalePos;         //y轴的0刻度线的位置。也叫初始刻度位置。默认是在_valueRect的底部
    CGFloat _valueAreaHeight;           //数据的显示高度值
    CGFloat _yAxisScaleValueWidth;      //y轴刻度值宽度。
    NSInteger _yAxisScaleCount;         //y轴刻度数量，目前约定为6


    //图表属性
    struct
    {
        unsigned int _showMajorTitle:1;  //显示主标题
        unsigned int _showMinorTitle:1;  //显示副标题
        unsigned int _showYaxisTitle:1;   //显示y轴标题
        unsigned int _showYaxisScaleLine:1;  //显示y轴刻度线
        unsigned int _showXaxisTitle:1;     //显示x轴标题
        unsigned int _showCutline:1;        //是否显示图例
        unsigned int _showValuePoint:1;     //是否显示值的原点，只对线图
        unsigned int _closedLine:1;         //是否显示渐变区域
        unsigned int _showValue:1;      //是否在图上显示值。
        unsigned int _showIndicator:1;   //是否显示指示器
        
    }_chartAttr;
    
    //移动手势，进行移动控制。
    UIPanGestureRecognizer *_panGesture;
    
    //缩放手势，进行缩放控制。
    UIPinchGestureRecognizer *_pinchGesture;
    
    //触摸手势，专门用于饼图的触摸控制。
    UITapGestureRecognizer  *_tapGesture;
    
    
    //指示器视图。
    UIView        *_floatView;
    UITableView   *_tableView;
    UILabel       *_measurelabel;  //指标名称
    NSInteger     _showFloatIndex; //浮动框显示数据的列
    NSInteger     _leftLabelWidth; //左边label的长度
    NSInteger     _rightLabelWidth; //右边label的长度
    UIButton      *_closeButton; // 关闭按钮，不能自适应
}

@property(nonatomic, assign) id<ChartViewDataSource> dataSource;

@property(nonatomic, readonly) NSInteger indexCount;
@property(nonatomic, readonly) NSInteger measureCount;

@property(nonatomic, assign) ChartType chartType;   //图表的类型。(线型,条形)

//显示标题
@property(nonatomic, assign) BOOL showMajorTitle;       //显示主标题。默认为yes
@property(nonatomic, assign) BOOL showMinorTitle;       //显示副标题。默认为no

//Y轴属性
@property(nonatomic, assign) BOOL showYaxisTitle;       //显示y轴标题。默认为yes。
@property(nonatomic, assign) BOOL showYaxisScaleLine;   //显示y轴横线。默认为no

//X轴属性
@property(nonatomic, assign) BOOL showXaxisTitle;       //是否显示x轴标题

//图例属性
@property(nonatomic, assign) BOOL showCutline;          //显示图例。默认是no

//线型图属性
@property(nonatomic, assign) BOOL showValuePoint;       //是否显示值的原点。
@property(nonatomic, assign) BOOL closedLine;           //线图是否是一个封闭的区域。默认为no

@property(nonatomic, assign) BOOL showValue;           //线图是否是一个封闭的区域。默认为no

@property(nonatomic, assign) BOOL showIndicator;        //显示指示器。

@property(nonatomic, assign) CGPoint chartOffset;      //调整图片的偏移位置。

-(void)drawChartLayer:(CALayer*)layer inContext:(CGContextRef)ctx;

-(void)reloadData;


@end

