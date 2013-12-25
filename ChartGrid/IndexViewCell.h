//
//  IndexViewCell.h
//  ChartGrid
//
//  Created by oybq on 12-7-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IndexViewCell : UITableViewCell
{

}

@property (nonatomic, retain) IBOutlet UIView *leftView;
@property (nonatomic, retain) IBOutlet UIButton *leftBtn;
@property (nonatomic, retain) IBOutlet UIView *leftColorView;
@property (nonatomic, retain) IBOutlet UILabel *leftLabel;

@property (nonatomic, retain) IBOutlet UIView *rightView;
@property (nonatomic, retain) IBOutlet UIButton *rightBtn;
@property (nonatomic, retain) IBOutlet UIView *rightColorView;
@property (nonatomic, retain) IBOutlet UILabel *rightLabel;

@end
