//
//  ViewController.h
//  ChartGrid
//
//  Created by oybq on 13-1-1.
//  Copyright (c) 2013年 youngsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChartView.h"
#import "GridView.h"
#import "GetChartIndexColor.h"
#import "IndexViewCell.h"

@interface ViewController : UIViewController<ChartViewDataSource,GridViewDataSource,GridViewDelegate,UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray *rows;
    //总指标数
    NSInteger totalIndexs;
    //选中的指标索引
    NSMutableArray *selectedIndexs;
    
}

@property (retain, nonatomic) IBOutlet UISegmentedControl *segctrlChartType;
@property (retain, nonatomic) IBOutlet GridView *gridViewChart;
@property (retain, nonatomic) IBOutlet ChartView *chartViewChart;

@property (retain, nonatomic) IBOutlet UITableView *tableViewIndex;

- (IBAction)dataChanged:(id)sender;

- (IBAction)handleChartTypeChanged:(id)sender;
@end
