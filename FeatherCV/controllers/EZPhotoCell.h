//
//  EZPhotoCell.h
//  Feather
//
//  Created by xietian on 13-9-17.
//  Copyright (c) 2013年 tiange. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EZConstants.h"
#import "EZPhoto.h"
#import "EZCombinedPhoto.h"
#import "EZStyleImage.h"
#import "ILTranslucentView.h"
#import "EZDisplayPhoto.h"
#import "EZBarRegion.h"
/**
 What's the purpose of this class?
 I will display a cell on the screen. 
 Have following parts:
 1. The photo.
    Click will trigger the rotation animation. 
 2. The functional part.
    Comments button will get into the comments window, it is another controller. 
    I can reuse the comments controller. Enjoy 30 minutes. 
   2.1 Heart clicked can be liked. 
 **/
@class EZClickImage;
@class EZClickView;


#define MainLabelTag 20140103

#define ToolRegionHeight 80
#define InitialFeedbackRegion 60

#define ToolRegionRect CGRectMake(0, 300, 300, ToolRegionHeight)

#define FeedbackRegionRect CGRectMake(0,380, 300, 40)

@interface EZPhotoCell : UITableViewCell

@property (nonatomic, assign) int currentPos;

@property (nonatomic, assign) BOOL isLarge;

//The purpose of the container is to limit the scope of the flip animation.
//Otherwise the whole thing rotate together, this is not what I expected.
@property (nonatomic, strong) EZClickView* container;

//This view will in charge of the whole rotate, because I need to rotate the whole thing.
@property (nonatomic, strong) UIView* rotateContainer;

@property (nonatomic, strong) EZBarRegion* toolRegion;

@property (nonatomic, strong) UIView* feedbackRegion;

//The UIImage which have no effects
//@property (nonatomic, strong) UIImageView* frontNoEffects;

@property (nonatomic, strong) UIImageView* frontImage;

@property (nonatomic, strong) UIImageView* backImage;

@property (nonatomic, strong) UILabel* photoTalk;

@property (nonatomic, strong) EZClickImage* headIcon;

//The icon which represent the relationship between the headIcon and other icons
//Which could be lock or other icons.
@property (nonatomic, strong) EZClickImage* linkIcon;

//The head icon for the image which on the back of the current image.
@property (nonatomic, strong) EZClickImage* backIcon;

//The icon will show the available image to match this image
@property (nonatomic, strong) UILabel* countIcon;

@property (nonatomic, strong) UITextView* photoWord;

@property (nonatomic, strong) EZClickImage* likeButton;
//You can talk as you like.
@property (nonatomic, strong) EZClickImage* talkButton;

@property (nonatomic, strong) EZEventBlock clicked;

//Name of the current image
@property (nonatomic, strong) UILabel* name;

//Used to record the status of the photo cell, so when I turn I knew which one is on the front.
@property (nonatomic, assign) BOOL isFrontImage;

//The flipped status will be with the EZCombinedPhotot object itself, then the flipped will
//Decouple the logic. I love this game.
@property (nonatomic, strong) EZEventBlock flippedCompleted;

//I will use small image initially, then switch to the large image.
@property (nonatomic, assign) BOOL isLargeImage;

//Don't use the cell which is turning.
@property (nonatomic, assign) BOOL isTurning;

//- (void) adjust

- (void) displayPhoto:(NSString*)photo;

//I am happy that define a good interface to handle the image switch action
- (void) switchImageTo:(NSString*)url;

//I will show the rotation animation;
- (void) switchImage:(EZPhoto*)photo photo:(EZDisplayPhoto*)dp complete:(EZEventBlock)blk tableView:(UITableView*)tableView index:(NSIndexPath*)path;

- (void) displayImage:(UIImage*)img;

- (void) displayEffectImage:(UIImage*)img;

//Why have a different method do this?
//Why not use a single method to handle all of them?
//This is great idea.
- (void) backToOriginSize;

- (void) adjustCellSize:(CGSize)size;

- (UIView*) createDupContainer:(UIImage*)img;

- (id) init;

@end
