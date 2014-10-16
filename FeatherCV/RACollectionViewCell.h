//
//  RACollectionViewCell.h
//  RACollectionViewTripletLayout-Demo
//
//  Created by Ryo Aoyama on 5/27/14.
//  Copyright (c) 2014 Ryo Aoyama. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RACollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) UIButton* delBtn;

@property (nonatomic, strong) UIButton* addBtn;

@property (nonatomic, strong) EZEventBlock deleteClicked;

@property (nonatomic, strong) EZEventBlock addClicked;

- (void) showAdd;

- (void) showDelete:(BOOL)animated;

- (void) showImage:(BOOL)isDragMode;

@end
