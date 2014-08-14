//
//  EZMainPhotoCell.h
//  3DCamera
//
//  Created by xietian on 14-8-5.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EZMainPhotoCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView* photo;

@property (nonatomic, strong) UIButton* editBtn;

@property (nonatomic, strong) UILabel* name;

//Based on the recent change, this really make sense to me.
@property (nonatomic, strong) UILabel* updateDate;

@property (nonatomic, strong) EZEventBlock editClicked;

@end