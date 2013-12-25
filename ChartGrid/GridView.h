//
//  GridView.h
//  ChartGrid
//
//  Created by  oybq on 12-6-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Col : NSObject {
}

@property(nonatomic, retain) NSString *name;
@property(nonatomic, assign) NSInteger width;
@property(nonatomic, assign) UITextAlignment alignment;
@property(nonatomic, retain) NSMutableArray *subCols;  //子列
@property(nonatomic, retain) UIImage *image;    //列的图片。
@property(nonatomic, assign) NSInteger type; // 列的类型。0为文本，1为视图。
@property(nonatomic, assign) NSInteger indentation; //缩进 给非绑定行用的
@property(nonatomic, assign) NSInteger lineBreakMode; //断字模式
@property(nonatomic, assign) Col *parentCol;

@end


@class GridView;

@protocol GridViewDelegate <NSObject>

@optional

//得到选中的行的颜色。如果没有或者返回为nill则没有选中的行和列颜色。
-(UIColor*) gridView:(GridView*)aGridView colorAtRow:(NSInteger)aRowIndex;
//选中的行的背景颜色。
-(UIColor*) selectedRowColorInGridView:(GridView*)aGridView;
//选中列的背景颜色
-(UIColor*) selectedColColorInGridView:(GridView*)aGridView;
//选中标题的背景色
-(UIColor*) selectedTitleColorInGridView:(GridView*)aGridView;



//在某个列上单击了某行。
-(void) gridView:(GridView*)aGridView clickAtRow:(NSInteger)aRowIndex atCol:(NSInteger)aColIndex;

//双击某行
-(void) gridView:(GridView *)aGridView doubleClickAtRow:(NSInteger)aRowIndex;

//单击某列标题
-(void)gridView:(GridView *)aGridView clickAtCol:(NSInteger)aColIndex;

@end



@protocol GridViewDataSource <NSObject>

//得到列数组
-(NSArray*)columnsInGridView:(GridView*)aGridView;

//得到行的数量
-(NSInteger)rowCountInGridView:(GridView*)aGridView;

//得到单元格数据,如果返回@@则表示跟上一行合并为一行。
-(NSString*)gridView:(GridView*)aGridView cellFromRow:(NSInteger)aRowIndex cellFromCol:(NSInteger)aColIndex;

@optional

//得到视图。如果有视图则不取文本,如果视图返回nil则取文本。
-(UIView*)gridView:(GridView*)aGridView viewFromRow:(NSInteger)aRowIndex viewFromCol:(NSInteger)aColIndex;

//得到图片，如果有图片则不取文本。如果没有图片返回nil,如果返回nil，那么就应该取文本。
-(UIImage*)gridView:(GridView*)aGridView imageFromRow:(NSInteger)aRowIndex imageFromCol:(NSInteger)aColIndex;

//填充行数据,整个行将被一行数据填充。如果填充了行数据则这一行的单元数据将不会被填充。如果返回了nil则行填充也不起作用。
-(NSString*)gridView:(GridView *)aGridView groupTextFromRow:(NSInteger)aRowIndex;

//填充行的视图。整行将被一个视图填充。如果视图返回nil则考虑整行是文本
-(UIView*)gridView:(GridView *)aGridView viewFromRow:(NSInteger)aRowIndex;


@end





@interface GridView:UIScrollView <UIScrollViewDelegate>
{
    id<GridViewDataSource> _dataSource;
    id<GridViewDelegate> _gridDelegate;
    
    //列信息。
    NSArray *_columns;
    NSInteger _rowCount;
    NSInteger _colCount;
    
    
    //选中的行
    NSInteger _selectedRowIndex;
    //选中的列,
    NSInteger _selectedColIndex;
    
    
    
    //单元格背景颜色。
    UIColor *_cellBackgroundColor;
    
    //固定列的列宽
    CGFloat _fixedColWidth;
    
    CGPoint _scrollStratPoint;
   // CGPoint *_scrollMovePoint;
    BOOL    _firstMove; //是否第一次进入移动
    NSInteger    _moveState; // 0 为不做限制  1为水平方向 2为竖直方向
    BOOL    _userReload; // 用户切换栏目主动刷新
    
    CGFloat _totalColWidth ; //总宽度
    CGFloat _totalRowHeight; //总高度
    NSInteger _maxTitleLayerCount;//最大的头部层数
    
    NSMutableArray  *_allColArray; // 所有的列数组
    NSInteger       _allfixSubColCount; //所有绑定列的总数 
    
    CGFloat     _allTitleHeight;
}

//委托
@property(nonatomic, assign) id<GridViewDataSource> dataSource;
@property(nonatomic, assign) id<GridViewDelegate> gridDelegate;

//选中的行和列标识。如果没有选中则是－1
@property(nonatomic, assign) NSInteger selectedRowIndex;
@property(nonatomic, assign) NSInteger selectedColIndex;

/*
 全部属性
 */

//列数组,注意这里是绑定列的数组。
@property(nonatomic, readonly) NSArray *columns;
//固定列数量，注意这里是大列数量,而不是绑定列数量。
@property(nonatomic, assign) NSInteger fixedColCount;
//行数量
@property(nonatomic, readonly) NSInteger rowCount;
//列数量
@property(nonatomic, readonly) NSInteger colCount;


//列线宽度
@property(nonatomic, assign) CGFloat colLineWidth;
//列线颜色
@property(nonatomic, retain) UIColor *colLineColor;
//列线风格
@property(nonatomic, assign) NSInteger colLineStyle;
//行线宽度
@property(nonatomic, assign) CGFloat rowLineWidth;
//行线颜色
@property(nonatomic, retain) UIColor *rowLineColor;
//行线风格
@property(nonatomic, assign) NSInteger rowLineStyle;
//行高
@property(nonatomic, assign) NSInteger rowHeight;

//提供行组功能,默认是NO.启动行组后，-(NSString*)gridView:(GridView *)aGridView groupTextFromRow:(NSInteger)aRowIndex; 才有效。
@property(nonatomic,assign) BOOL enableGroup;

//组的文字对齐方式。

//单元格文字颜色和单元格字体。
@property(nonatomic, retain) UIColor *cellColor;
@property(nonatomic, retain) UIFont *cellFont;

/*
 列标题属性
 */
//列标题高度
@property(nonatomic, assign) CGFloat titleHeight;
//列标题字体
@property(nonatomic, retain) UIFont  *titleFont;
//是否固定列标题
@property(nonatomic, assign, getter = isFixedTitle)  BOOL fixedTitle; 
//选中时是否只选中列标题,默认为YES
@property(nonatomic, assign) BOOL onlySelectTitle;
//列标题的文字颜色
@property(nonatomic, retain) UIColor *titleColor;
//列标题的背景颜色,
@property(nonatomic, retain) UIColor *titleBackgroundColor;
//列标题下方的线的粗细  有就是双线  无就是没线
@property(nonatomic, assign) NSInteger titleLineWidth;
//列标题下方线的颜色
@property(nonatomic, retain) UIColor *titleLineColor;



/*
 边框属性
 */
//边框的粗细,如果为0则无边框
@property(nonatomic, assign) CGFloat borderWidth;
//边框的颜色
@property(nonatomic, retain) UIColor *borderColor;
//边框的类型,0是单线，1是双线，2是点线，3是间断线。
@property(nonatomic, assign) NSInteger borderStyle;

//标题底部是否具有边框,默认是NO
//@property(nonatomic, assign) BOOL borderAtTitleBottom;


//当滚动条为移到负数时,标题部分和固定列部分是否也跟着移动。默认为NO
//@property(nonatomic, assign) BOOL  x1;
//@property(nonatomic, assign) BOOL  x2;

//重新装载数据
-(void)reloadData;

//保持现有的位置
- (void)reloadCurrentOffsettData;

//把当前的offset变为0
- (void)reloadDataChangeCurrentOffset:(BOOL)aBool;

//得到某行某列的文本串
-(NSString*)cellTextFromRow:(NSInteger)aRowIndex col:(NSInteger)aColIndex;

//得到某列的数据结构，这里不是绑定列。
-(Col*) columnFrom:(NSInteger)aColIndex;

//获取某一列对应的subcol
-(Col*)subColumnFrom:(NSInteger)aColIndex;

//改变各个列的宽度
-(void)changeAllColumnWidth;

//根据绑定列，已级绑定列内的索引得到真实的列索引。
-(NSInteger) getColumnIndexFromBindColIndex:(NSInteger)aBindColIndex subColIndex:(NSInteger)aSubColIndex;

@end


