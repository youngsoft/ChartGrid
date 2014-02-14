//
//  ViewController.m
//  ChartGrid
//
//  Created by oybq on 13-1-1.
//  Copyright (c) 2013年 youngsoft. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (NSInteger)getColWidth:(NSInteger)aStringLength indentation:(NSInteger)aIndentation
{
    NSInteger realColWidth = 0;
    NSString *testFontSting = @"9";
    NSString *string = [[[NSString alloc] init] autorelease];
    for (NSInteger appendIndex = 0; appendIndex < aStringLength; ++appendIndex)
    {
        string = [string stringByAppendingString:testFontSting];
    }
    
    CGSize size = [string sizeWithFont:[UIFont fontWithName:@"Helvetica" size:15]
                              forWidth:30000
                         lineBreakMode:UILineBreakModeWordWrap];
    
    if (size.width+aIndentation*2+10 < 120)
    {
        realColWidth = 120;
    }
    else
    {
        realColWidth = size.width+aIndentation*2;
    }
    return realColWidth;
}

-(BOOL)isIndexSelected:(NSInteger)index
{
    BOOL selected = NO;
    for (NSNumber *num in selectedIndexs)
    {
        if (num.integerValue == index)
            return YES;
    }
    
    return selected;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    /*
    
     地区  人口数  国民生产总值 居民总收入 居民总支出 房屋价格
     北京
     上海
     天津
     深圳
     广州
     杭州
     长沙
     南京
     合肥
     大连
     青岛
     郑州
     西安
     厦门
     福州
    */
    
    
    //NSArray *columns = [NSArray arrayWithObjects:@"人口数",@"国民生产总值",@"居民总收入",@"居民总支出",@"房屋价格", nil];
   // NSArray *rows = [NSArray arrayWithObjects:<#(id), ...#>, nil]
    
    NSArray *col = [NSArray arrayWithObjects:@"北京",@"上海",@"天津", @"深圳",@"广州",@"杭州",@"长沙",@"南京",@"合肥",@"大连",@"青岛",@"郑州",@"西安",@"厦门",@"福州", nil];
    
    
    rows = [[NSMutableArray alloc] init];
    
    NSArray *row1 = [NSArray arrayWithObjects:@"地区", @"人口数",@"国民生产总值(万元)",@"居民总收入(万元)",@"居民总支出(万元)",@"房屋价格(元/m2)", nil];
    [rows addObject:row1];
    
    //默认选中第一个。
    totalIndexs = row1.count - 1;
    selectedIndexs = NSMutableArray.new;
    [selectedIndexs addObject:[NSNumber numberWithInteger:0]];
    
    
    srand((unsigned)time(NULL));
    for (int i = 0; i < col.count; i++)
    {
        NSMutableArray *row = [[NSMutableArray alloc] init];
        
        //第一列
        [row addObject:[col objectAtIndex:i]];
        
        //第二列人口，是整数，限制在1万－20000万
        NSInteger rk = (rand() % (20000000 - 10000)) + 10000;
        [row addObject:[NSString stringWithFormat:@"%d", rk]];
        
        //第三列国名生产总值。是小数，单位万元. 限制在500000元到10亿之间
        double gmsczz = ((rand() % (1000000000 - 500000)) + 500000) / 10000.0;
        [row addObject:[NSString stringWithFormat:@"%.2f",gmsczz]];
        
        
        //居民总收入  单位万元， 是小数 限制在100，000 到  1亿之间
        double jmzsr = ((rand() % (100000000 - 100000)) + 100000) / 10000.0;
        [row addObject:[NSString stringWithFormat:@"%.2f",jmzsr]];
        
        //具名总支出, 支出是收入的20%－80%
        double  jmzzc = (rand() % 60 + 20) / 100.0f * jmzsr;
        [row addObject:[NSString stringWithFormat:@"%.2f",jmzzc]];
        

        //房屋价格，限制在1000千－25000之间
        NSInteger fwjg = (rand() % (25000 - 1000))+ 1000;
        [row addObject:[NSString stringWithFormat:@"%d",fwjg]];
        
        [rows addObject:row];
        [row release];
    }
    
    
    [self.tableViewIndex reloadData];
    
    
    self.gridViewChart.dataSource = self;
    self.gridViewChart.gridDelegate = self;
    self.gridViewChart.titleBackgroundColor = [UIColor colorWithRed:43.0/255.0 green:43.0/255.0 blue:53.0/255 alpha:1];
    
    self.gridViewChart.titleFont = [UIFont fontWithName:@"Helvetica" size:16];
    self.gridViewChart.titleColor = [UIColor colorWithRed:179.0/255.0 green:172.0/255.0 blue:197.0/255.0 alpha:1];
    self.gridViewChart.titleHeight = 40;
    self.gridViewChart.titleLineWidth = 2;
    self.gridViewChart.titleLineColor = [UIColor colorWithRed:56.0/255.0 green:56.0/255.0 blue:66.0/255.0 alpha:1];
    
    self.gridViewChart.fixedTitle = YES;
    self.gridViewChart.fixedColCount = 1;
    
    self.gridViewChart.colLineWidth = 1;
    self.gridViewChart.colLineColor = [UIColor colorWithRed:56.0/255.0 green:56.0/255.0 blue:66.0/255.0 alpha:1];
    
    self.gridViewChart.rowLineWidth = 1;
    self.gridViewChart.rowLineColor = [UIColor colorWithRed:56.0/255.0 green:56.0/255.0 blue:66.0/255.0 alpha:1];
    
    self.gridViewChart.borderColor = [UIColor colorWithRed:56.0/255.0 green:56.0/255.0 blue:66.0/255.0 alpha:1];
    self.gridViewChart.borderWidth = 2;
    self.gridViewChart.borderStyle = 0;
    
    self.gridViewChart.selectedRowIndex = -1;
    
    self.gridViewChart.cellColor = [UIColor colorWithRed:163.0/255.0 green:157.0/255.0 blue:180.0/255.0 alpha:1];
    self.gridViewChart.cellFont  = [UIFont fontWithName:@"Helvetica" size:15];
    self.gridViewChart.rowHeight = 50;
    
    self.gridViewChart.hidden = YES;
    
    [self.gridViewChart reloadData];
    
    
    ///////////
    
    self.chartViewChart.dataSource = self;
    self.chartViewChart.clipsToBounds = YES;
    self.chartViewChart.showXaxisTitle = NO;
    self.chartViewChart.showYaxisTitle = YES;
    self.chartViewChart.chartType = 1;
    self.chartViewChart.closedLine = YES;
    self.chartViewChart.showMajorTitle = YES;
    self.chartViewChart.showValue = NO;
    self.chartViewChart.showValuePoint = NO;
    [self.chartViewChart reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return (toInterfaceOrientation == UIInterfaceOrientationPortrait) || (toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
    
}

- (void)dealloc {
    [_segctrlChartType release];
    [_gridViewChart release];
    [_chartViewChart release];
    [_tableViewIndex release];
    [super dealloc];
}
- (IBAction)dataChanged:(id)sender {
    
    //rows 转换。
    NSMutableArray *rowsTemp = [[NSMutableArray alloc] init];
    
    NSArray *row1 = [rows objectAtIndex:0];
    
    for (int i = 0; i < row1.count; i++)
    {
        NSMutableArray *newRow = [[NSMutableArray alloc] init];
        
        for (int j = 0; j < rows.count; j++)
        {
            NSArray *rowi = [rows objectAtIndex:j];
            [newRow addObject:[rowi objectAtIndex:i]];
        }
        
        [rowsTemp addObject:newRow];
        [newRow release];
        
     }
    
    [rows release];
    rows = rowsTemp;
    
    totalIndexs = ((NSArray*)[rows objectAtIndex:0]).count - 1;
    [selectedIndexs release];
    selectedIndexs = NSMutableArray.new;
    [selectedIndexs addObject:[NSNumber numberWithInteger:0]];

    
    [self.tableViewIndex reloadData];
    [self.gridViewChart reloadData];
    [self.chartViewChart  reloadData];
    
}

- (IBAction)handleChartTypeChanged:(id)sender
{
    UISegmentedControl *seg = (UISegmentedControl*)sender;
    
    switch (seg.selectedSegmentIndex) {
        case 0:
            self.gridViewChart.hidden = YES;
            self.chartViewChart.hidden = NO;
            self.chartViewChart.chartType = ChartTypeLine;
            break;
        case 1:
            self.gridViewChart.hidden = YES;
            self.chartViewChart.hidden = NO;
            self.chartViewChart.chartType = ChartTypeBar;
            break;
        case 2:
            self.gridViewChart.hidden = YES;
            self.chartViewChart.hidden = NO;
            self.chartViewChart.chartType = ChartTypePie;
            break;
        case 3:
            self.gridViewChart.hidden = NO;
            self.chartViewChart.hidden = YES;
            break;
        default:
            break;
    }
    
    
}

#pragma mark - 
#pragma mark ChartViewDataSource

//得到最大值
- (double)maxValueInChartView:(ChartView*)chartView startMeasure:(NSInteger)aStartMeasure endMeasure:(NSInteger)aEndMeasure
{
    //计算最小
    double maxValue =  INT32_MIN;
    for (int i = aStartMeasure; i < aEndMeasure; i++)
    {
        NSArray *row = [rows objectAtIndex:i + 1];
        
        for (NSNumber *num in selectedIndexs)
        {
            double maxTemp = ((NSString*)[row objectAtIndex:num.integerValue + 1]).doubleValue;
            if ( maxTemp > maxValue)
                maxValue = maxTemp;
        }
    }
    
    return maxValue;

}

//得到最小值
- (double)minValueInChartView:(ChartView*)chartView startMeasure:(NSInteger)aStartMeasure endMeasure:(NSInteger)aEndMeasure
{
    //计算最小
    double minValue =  INT32_MAX;
    for (int i = aStartMeasure; i < aEndMeasure; i++)
    {
        NSArray *row = [rows objectAtIndex:i + 1];
        
        for (NSNumber *num in selectedIndexs)
        {
            double minTemp = ((NSString*)[row objectAtIndex:num.integerValue + 1]).doubleValue;
            if ( minTemp < minValue)
                minValue = minTemp;
        }
    }
    
    return minValue;
}

//指标的数量
- (NSInteger)indexCountInChartView:(ChartView*)chartView
{
    return selectedIndexs.count;
}

//度量的数量
- (NSInteger)measureCountInChartView:(ChartView*)chartView
{
    return rows.count - 1;
}

//获取度量的值
- (NSString*)valueInChartView:(ChartView*)chartView atMeasure:(NSInteger)aMeasure
{
    NSArray *row = [rows objectAtIndex:aMeasure + 1];
    return [row objectAtIndex:0];
}

//获取指标值。
- (NSString*)valueInChartView:(ChartView*)chartView atMeasure:(NSInteger)aMeasure atIndex:(NSInteger)aIndex
{
    
    NSInteger realIndex = ((NSNumber*)[selectedIndexs objectAtIndex:aIndex]).integerValue;
    
    NSArray *row = [rows objectAtIndex:aMeasure + 1];
    return  [row objectAtIndex:realIndex + 1];
}




//得到每个指标的名字
- (NSString*)indexNameInChartView:(ChartView*)chartView atIndex:(NSInteger)aIndex
{
    NSArray *row = [rows objectAtIndex:0];
    
    NSInteger realIndex = ((NSNumber*)[selectedIndexs objectAtIndex:aIndex]).integerValue;
    
    return [row objectAtIndex:realIndex + 1];
}

//得到每个指标的颜色,这里为了支持渐变，返回一个UIColor数组。如果是1个就只有一个颜色。
- (NSArray*)indexColorInChartView:(ChartView*)chartView atIndex:(NSInteger)aIndex
{
    NSInteger realIndex = ((NSNumber*)[selectedIndexs objectAtIndex:aIndex]).integerValue;
    
    return [GetChartIndexColor getChartIndexColorAtIndex:realIndex];
}

-(NSArray*)measureColorInChartView:(ChartView*)chartView atMeasure:(NSInteger)aMeasure
{
    return [GetChartIndexColor getChartIndexColorAtIndex:aMeasure];
}

//得到y轴的标题内容,如果返回nil则不显示y轴标题
- (NSString*)yAxisTitleOfChartView:(ChartView*)chartView
{
    return nil;
}

//得到x轴的标题内容,如果返回nil则不显示x轴标题
- (NSString*)xAxisTitleOfChartView:(ChartView*)chartView
{
    return nil;
}

#pragma mark - 
#pragma mark GridViewDelegate

//得到选中的行的颜色。如果没有或者返回为nill则没有选中的行和列颜色。
-(UIColor*) gridView:(GridView*)aGridView colorAtRow:(NSInteger)aRowIndex
{
    if (aRowIndex %2 == 0)
    {
        return  [UIColor grayColor];
    }
    else
    {
        return [UIColor darkGrayColor];
    }
    
}
//选中的行的背景颜色。
/*
-(UIColor*) selectedRowColorInGridView:(GridView*)aGridView
{
    return [UIColor lightGrayColor];
}
//选中列的背景颜色
-(UIColor*) selectedColColorInGridView:(GridView*)aGridView
{
    return nil;
}
//选中标题的背景色
-(UIColor*) selectedTitleColorInGridView:(GridView*)aGridView
{
    return nil;
}
*/


//在某个列上单击了某行。
-(void) gridView:(GridView*)aGridView clickAtRow:(NSInteger)aRowIndex atCol:(NSInteger)aColIndex
{
  
}

//双击某行
-(void) gridView:(GridView *)aGridView doubleClickAtRow:(NSInteger)aRowIndex
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"单击列标题" message:[NSString stringWithFormat:@"您双击了第%d行", aRowIndex] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    
    [alert show];
    [alert release];
}

//单击某列标题
-(void)gridView:(GridView *)aGridView clickAtCol:(NSInteger)aColIndex
{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"单击列标题" message:[NSString stringWithFormat:@"您单击了第%d列", aColIndex] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    
    [alert show];
    [alert release];
    
}



#pragma mark - 
#pragma mark GridViewDataSource



//得到列数组
-(NSArray*)columnsInGridView:(GridView*)aGridView
{
    //构造Column
    
    NSMutableArray *columns = [[NSMutableArray alloc] init];
    
    NSArray *row = [rows objectAtIndex:0];
    for (int i = 0; i < row.count; i++)
    {
        NSString *colname = [row objectAtIndex:i];
        
        Col *col  = Col.new;
        col.name = colname;
        col.width = [self getColWidth:colname.length*2 indentation:10];
        col.indentation = 10;
        
        if (i != 0)
            col.alignment = UITextAlignmentRight;
        else
        {
            Col *scol = Col.new;
            scol.name = @"地市";
            scol.parentCol = col;
            scol.width = col.width;
            col.subCols = [@[scol] mutableCopy];
            [scol release];
        }
        
        
        
        
        [columns addObject:col];
        [col release];
    }
    
    return [columns  autorelease];
}

//得到行的数量
-(NSInteger)rowCountInGridView:(GridView*)aGridView
{
    return rows.count - 1;
}

//得到单元格数据,如果返回@@则表示跟上一行合并为一行。
-(NSString*)gridView:(GridView*)aGridView cellFromRow:(NSInteger)aRowIndex cellFromCol:(NSInteger)aColIndex
{
    NSArray *row  = [rows objectAtIndex:aRowIndex + 1];
    return [row objectAtIndex:aColIndex];
}



//得到视图。如果有视图则不取文本,如果视图返回nil则取文本。
/*-(UIView*)gridView:(GridView*)aGridView viewFromRow:(NSInteger)aRowIndex viewFromCol:(NSInteger)aColIndex
{
    return nil;
}

//得到图片，如果有图片则不取文本。如果没有图片返回nil,如果返回nil，那么就应该取文本。
-(UIImage*)gridView:(GridView*)aGridView imageFromRow:(NSInteger)aRowIndex imageFromCol:(NSInteger)aColIndex
{
    return nil;
}

//填充行数据,整个行将被一行数据填充。如果填充了行数据则这一行的单元数据将不会被填充。如果返回了nil则行填充也不起作用。
-(NSString*)gridView:(GridView *)aGridView groupTextFromRow:(NSInteger)aRowIndex
{
    return @"";
}

//填充行的视图。整行将被一个视图填充。如果视图返回nil则考虑整行是文本
-(UIView*)gridView:(GridView *)aGridView viewFromRow:(NSInteger)aRowIndex
{
    return nil;
}
*/

#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 40.0;
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section
{
    if (totalIndexs%2 > 0 )
	{
		return totalIndexs/2 + 1;
	}
	else
	{
		return totalIndexs/2;
	}
}

-(void)handleIndexBtnEvent:(id)sender
{
    UIButton *btn = (UIButton*)sender;
    btn.selected = !btn.isSelected;
    
    for (int i = 0; i < selectedIndexs.count; i++)
    {
        NSNumber *num = [selectedIndexs objectAtIndex:i];
        if (num.integerValue == btn.tag)
        {
            [selectedIndexs removeObjectAtIndex:i];
            break;
        }
    }
    
    if (btn.isSelected)
    {
        [selectedIndexs addObject:[NSNumber numberWithInteger:btn.tag]];
    }
    
    [self.chartViewChart reloadData];
}


- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"OrganizationCell";
    IndexViewCell *cell = (IndexViewCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        cell = (IndexViewCell *)[[[NSBundle mainBundle] loadNibNamed:@"IndexViewCell"
                                                                   owner:nil
                                                                 options:nil] objectAtIndex:0];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }
    
    cell.contentView.userInteractionEnabled = NO;
    
    NSInteger firstIndex = 2*indexPath.row;
    NSInteger secondIndex = firstIndex+1;
    
    cell.leftView.hidden = YES;
    cell.rightView.hidden = YES;
    
    if (firstIndex < totalIndexs)
    {
        cell.leftView.hidden = NO;
        cell.leftBtn.selected = [self isIndexSelected:firstIndex];
        cell.leftBtn.tag = firstIndex;
        [cell.leftBtn removeTarget:self action:@selector(handleIndexBtnEvent:) forControlEvents:UIControlEventTouchUpInside];
        [cell.leftBtn addTarget:self action:@selector(handleIndexBtnEvent:) forControlEvents:UIControlEventTouchUpInside];
        
        NSArray *colorArray = [GetChartIndexColor getChartIndexColorAtIndex:firstIndex];
        UIColor *startColor = [colorArray objectAtIndex:0];
        UIColor *endColor = [colorArray objectAtIndex:1];
        
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = cell.leftColorView.bounds;
        gradient.colors = [NSArray arrayWithObjects:(id)startColor.CGColor,(id)endColor.CGColor,nil];
        
        NSArray *sublayers = cell.leftColorView.layer.sublayers;
        for (CALayer *sublayer in sublayers)
            [sublayer removeFromSuperlayer];
        
        [cell.leftColorView.layer insertSublayer:gradient atIndex:0];
        
        cell.leftLabel.text =  [((NSArray*)[rows objectAtIndex:0]) objectAtIndex:firstIndex + 1];
        
    }
    if (secondIndex < totalIndexs)
    {
        cell.rightView.hidden = NO;
        cell.rightBtn.selected = [self isIndexSelected:secondIndex];
        cell.rightBtn.tag = secondIndex;
        [cell.rightBtn removeTarget:self action:@selector(handleIndexBtnEvent:) forControlEvents:UIControlEventTouchUpInside];
        [cell.rightBtn addTarget:self action:@selector(handleIndexBtnEvent:) forControlEvents:UIControlEventTouchUpInside];
        
        NSArray *colorArray = [GetChartIndexColor getChartIndexColorAtIndex:secondIndex];
        UIColor *startColor = [colorArray objectAtIndex:0];
        UIColor *endColor = [colorArray objectAtIndex:1];
        
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = cell.rightColorView.bounds;
        gradient.colors = [NSArray arrayWithObjects:(id)startColor.CGColor,(id)endColor.CGColor,nil];
        
        NSArray *sublayers = cell.rightColorView.layer.sublayers;
        for (CALayer *sublayer in sublayers)
            [sublayer removeFromSuperlayer];
        
        [cell.rightColorView.layer insertSublayer:gradient atIndex:0];
        
        cell.rightLabel.text =  [((NSArray*)[rows objectAtIndex:0]) objectAtIndex:secondIndex + 1];
    }
    
    
    return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //[tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

@end

