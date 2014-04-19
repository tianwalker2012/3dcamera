//
//  EZContactTableCell.m
//  FeatherCV
//
//  Created by xietian on 13-12-12.
//  Copyright (c) 2013年 tiange. All rights reserved.
//

#import "EZContactTableCell.h"
#import "EZClickImage.h"
#import "EZClickView.h"
#import "EZEnlargedView.h"

#define slimFont [UIFont fontWithName:@"HelveticaNeue-Thin" size:20]
#define slimFontCN [UIFont fontWithName:@"STHeitiSC-Light" size:20]

#define buttonFontCN [UIFont fontWithName:@"STHeitiSC-Light" size:16]

#define numberFontCN [UIFont fontWithName:@"STHeitiSC-Light" size:12]

@implementation EZContactTableCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    CGFloat cellHeight = 60;
    if (self) {
        __weak EZContactTableCell* weakSelf = self;
        // Initialization code
        _name = [[UILabel alloc] initWithFrame:CGRectMake(20, (cellHeight - 22)/2, 220, 22)];
        _name.font = slimFontCN;//[UIFont systemFontOfSize:16];
        _name.textColor = [UIColor whiteColor];//RGBCOLOR(128, 128, 128);//RGBCOLOR(128, 128, 128);
        [self.contentView addSubview:_name];
        
        //[_name enableShadow:[UIColor blackColor]];
        _clickRegion = [[EZClickView alloc] initWithFrame:CGRectMake(0, 0, CurrentScreenWidth, cellHeight)];
        [self.contentView addSubview:_clickRegion];

        _headIcon = [[EZEnlargedView alloc] initWithFrame:CGRectMake(265, (cellHeight - 35.0)/2.0, 35.0, 35.0) enlargeRatio:EZEnlargeIconRatio];
        [_headIcon enableRoundImage];
        [self.contentView addSubview:_headIcon];
        
        _headIcon.releasedBlock = ^(id obj){
            EZDEBUG(@"icon clicked");
        };
        
        
        //EZClickView* clickView = [[EZClickView alloc] initWithFrame:CGRectMake(265, 0, 44, 60)];
        
        _photoCount = [[UILabel alloc] initWithFrame:CGRectMake(200, (cellHeight - 14.0)/2.0, 30.0,14.0)];
        _photoCount.font = numberFontCN;
        _photoCount.textColor = [UIColor whiteColor];
        _photoCount.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:_photoCount];
        
        //_notesNumber = [[EZUIUtility sharedEZUIUtility] createNumberLabel];
        //_notesNumber.center = CGPointMake(_name.frame.origin.x + _name.frame.size.width - 5 , (cellHeight - 14.0)/2.0);
        //[self.contentView addSubview:_notesNumber];
        
        _inviteButton = [[UIButton alloc] initWithFrame:CGRectMake(265, 0, 40, 60)];
        //[clickView addSubview:_inviteButton];
        //[self.contentView addSubview:_inviteButton];
        //[_inviteButton setTitle:@"邀请" forState:UIControlStateNormal];
        _inviteButton.titleLabel.font = buttonFontCN;
        //_inviteButton.text = @"邀请";
        //_inviteButton.textColor = [UIColor whiteColor];
        //_inviteButton.titleLabel.text = @"邀请";
        [_inviteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_inviteButton setTitleColor:ClickedColor forState:UIControlStateHighlighted];
        [_inviteButton setTitle:@"邀请" forState:UIControlStateNormal];
        [_inviteButton setTitle:@"邀请" forState:UIControlStateHighlighted];
        [_inviteButton addTarget:self action:@selector(inviteClicked:) forControlEvents:UIControlEventTouchUpInside];
        //[_inviteButton enableShadow:[UIColor blackColor]];
                //[_inviteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        //[_inviteButton addTarget:self action:@selector(inviteClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_inviteButton];
        self.backgroundColor =[UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void) fitLine
{
    CGSize sizeToFit = [self.name sizeThatFits:CGSizeMake(200, _name.frame.size.height)];
    CGFloat width = sizeToFit.width;
    if(width > 180){
        width = 180;
    }
    [_photoCount setX:_name.frame.origin.x + width + 10];
    [self.name setWidth:width];
    //[_notesNumber setX:self.name.frame.origin.x + sizeToFit.width + 10];
}

- (void) inviteClicked:(id)obj
{
    dispatch_later(0.15, ^(){
    if(_inviteClicked){
        _inviteClicked(self);
    }
    });
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
