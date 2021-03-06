//
//  EZMainPage.h
//  BabyCare
//
//  Created by xietian on 14-7-25.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "DLCImagePickerController.h"
#import "UMSocialSnsService.h"
#import "HorizontalPickerView.h"

@class EZScrollerView;
@class EZSlidingView;
@interface EZMainPage : UIViewController<UICollectionViewDataSource, UICollectionViewDelegate, UIActionSheetDelegate, UMSocialUIDelegate, HPickerViewDataSource, HPickerViewDelegate>//UICollectionViewController

- (EZMainPage*) initPage:(NSArray*)arr;

@property (nonatomic, strong) UICollectionViewFlowLayout* layout;

@property (nonatomic, strong) NSMutableArray* uploadedPhotos;

@property (nonatomic, strong) UICollectionView* collectionView;

@property (nonatomic, strong) UILabel* dateLabel;

@property (nonatomic, assign) NSInteger selectedCount;

@property (nonatomic, strong) NSDate* date;

@property (nonatomic, strong) EZSlidingView* slidingView;

@property (nonatomic, strong) UIView* topBar;

@property (nonatomic, strong) NSArray* topBtns;

@property (nonatomic, strong) UIButton* currentTopBtn;

@property (nonatomic, strong) UIView* bottomLine;

@property (nonatomic, strong) UIView* bottomBar;

@property (nonatomic, strong) UIActivityIndicatorView* loadingActivity;

@property (nonatomic, assign) NSInteger currentPos;

@property (nonatomic, assign) CGFloat minusHeight;
//@property (nonatomic, strong) NSMutableArray* uploadedPhotos;

@end
