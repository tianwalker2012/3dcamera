//
//  EZContactTableCell.h
//  FeatherCV
//
//  Created by xietian on 13-12-12.
//  Copyright (c) 2013年 tiange. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EZClickImage;
@class EZClickView;
@class EZEnlargedView;
@interface EZContactTableCell : UITableViewCell

@property (nonatomic, strong) UILabel* name;

@property (nonatomic, strong) EZEnlargedView* headIcon;

//The place will get clicked 
@property (nonatomic, strong) EZClickView* clickRegion;

@property (nonatomic, strong) UIButton* inviteButton;

@property (nonatomic, strong) EZEventBlock inviteClicked;

@property (nonatomic, strong) UILabel* photoCount;

@property (nonatomic, strong) UILabel* notesNumber;

- (void) fitLine;

@end
