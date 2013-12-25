//
//  IndexViewCell.m
//  ChartGrid
//
//  Created by oybq on 12-7-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "IndexViewCell.h"

@implementation IndexViewCell

@synthesize leftView;
@synthesize leftBtn;
@synthesize leftColorView;
@synthesize leftLabel;

@synthesize rightView;
@synthesize rightBtn;
@synthesize rightColorView;
@synthesize rightLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) 
    {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc
{
    self.leftView = nil;
    self.leftBtn = nil;
    self.leftColorView = nil;
    self.leftLabel = nil;
    
    self.rightView = nil;
    self.rightBtn = nil;
    self.rightColorView = nil;
    self.rightLabel = nil;

    [super dealloc];
}

@end
