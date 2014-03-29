//
//  EZPhotoCell.m
//  Feather
//
//  Created by xietian on 13-9-17.
//  Copyright (c) 2013年 tiange. All rights reserved.
//

#import "EZPhotoCell.h"
#import "EZClickView.h"
#import "EZClickImage.h"
#import "EZExtender.h"
#import "AFNetworking.h"
#import "EZExtender.h"
#import "UIImageView+AFNetworking.h"
#import "EZSimpleClick.h"
#import "EZShapeButton.h"

#define kHeartRadius 35

@implementation EZPhotoCell





- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    EZDEBUG(@"InitStyle get called:%i, id:%@", style, reuseIdentifier);
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = VinesGray;//[UIColor clearColor];
        // Initialization code
        _container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CurrentScreenWidth, CurrentScreenHeight)];
        _container.backgroundColor = VinesGray;
        
        //Then I can adjust it once for all.
        CGFloat startPos = -100;
        //_container.backgroundColor = [UIColor clearColor];
        
        //_container.layer.cornerRadius = 5;
        //_container.clipsToBounds = true;
        //_container.backgroundColor = [UIColor greenColor];
        //UIImage* img = [UIImage imageNamed:@"featherpage.jpg"];
       
        _rotateContainer = [self createRotateContainer:CGRectMake(0, 0, CurrentScreenWidth,CurrentScreenHeight)];
        _rotateContainer.backgroundColor = VinesGray;
        //_rotateContainer.backgroundColor = [UIColor clearColor];
        
        [_container addSubview:_rotateContainer];
        //_rotateContainer.backgroundColor = [UIColor redColor];
        //[_container makeInsetShadowWithRadius:20 Color:RGBA(255, 255, 255, 128)];
        _frontImage = [self createFrontImage];
        //_frontImage.backgroundColor = RGBCOLOR(255, 255, 0);
        //_toolRegion = [self createToolRegion:ToolRegionRect];
        /**
        _photoTalk = (UILabel*)[_toolRegion viewWithTag:MainLabelTag];
        
        _clickHeart = [[EZClickImage alloc] initWithFrame:CGRectMake(310 - kHeartRadius, _frontImage.frame.size.height - kHeartRadius, kHeartRadius, kHeartRadius)];
        [_clickHeart enableRoundImage];
        [_container addSubview:_clickHeart];
        //_clickHeart.backgroundColor = randBack(nil);
        **/
        _gradientView = [[EZUIUtility sharedEZUIUtility] createGradientView];
        [self.container addSubview:_gradientView];
        
        
        _otherIcon = [[EZClickImage alloc] initWithFrame:CGRectMake(10, CurrentScreenHeight - 300 - startPos, smallIconRadius, smallIconRadius)];
        _otherIcon.backgroundColor = randBack(nil);
        [_otherIcon enableRoundImage];
        [_otherIcon enableTouchEffects];
        [self.container addSubview:_otherIcon];
        
        _otherName = [[UILabel alloc] initWithFrame:CGRectMake(10, CurrentScreenHeight - 265 - startPos, 300, 30)];
        [_otherName setTextColor:[UIColor whiteColor]];
        _otherName.font = [UIFont boldSystemFontOfSize:13];
        [_otherName enableShadow:[UIColor blackColor]];
        [self.container addSubview:_otherName];
        
        _otherTalk = [[UILabel alloc] initWithFrame:CGRectMake(10, CurrentScreenHeight - 250 - startPos, 300, 30)];
        [_otherTalk setTextColor:[UIColor whiteColor]];
        _otherTalk.font = [UIFont systemFontOfSize:13];
        [_otherTalk enableShadow:[UIColor blackColor]];
        [_otherTalk enableTextWrap];
        [self.container addSubview:_otherTalk];

        UILabel* andSymbol = [[UILabel alloc] initWithFrame:CGRectMake(10, CurrentScreenHeight - 225 - startPos, 20, 20)];
        [andSymbol setTextColor:[UIColor whiteColor]];
        andSymbol.font = [UIFont systemFontOfSize:13];
        [andSymbol enableShadow:[UIColor blackColor]];
        andSymbol.text = @"&";
        [self.container addSubview:andSymbol];
        
        _headIcon = [[EZClickImage alloc] initWithFrame:CGRectMake(10, CurrentScreenHeight - 198 - startPos, smallIconRadius, smallIconRadius)];
        _headIcon.backgroundColor = randBack(nil);
        [_headIcon enableRoundImage];
        [_headIcon enableTouchEffects];
        [self.container addSubview:_headIcon];
        
        _authorName = [[UILabel alloc] initWithFrame:CGRectMake(10, CurrentScreenHeight - 163 - startPos, 300, 30)];
        [_authorName setTextColor:[UIColor whiteColor]];
        _authorName.font = [UIFont boldSystemFontOfSize:13];
        [_authorName enableShadow:[UIColor blackColor]];
        [self.container addSubview:_authorName];

        
        _ownTalk = [[UILabel alloc] initWithFrame:CGRectMake(10, CurrentScreenHeight - 148 - startPos, 300, 30)];
        [_ownTalk setTextColor:[UIColor whiteColor]];
        _ownTalk.font = [UIFont systemFontOfSize:13];
        [_ownTalk enableShadow:[UIColor blackColor]];
        [_ownTalk enableTextWrap];
        [self.container addSubview:_ownTalk];
        
        _likeButton = [[EZClickView alloc] initWithFrame:CGRectMake(255, CurrentScreenHeight - 105, 45,45)]; //[[EZCenterButton alloc] initWithFrame:CGRectMake(255, 23, 60,60) cycleRadius:21 lineWidth:2];
        [_likeButton enableRoundImage];
        
        _otherLike = [[EZClickView alloc] initWithFrame:CGRectMake(255, CurrentScreenHeight - 105, 45, 45)];
        _otherLike.layer.borderColor = [UIColor whiteColor].CGColor;
        _otherLike.layer.borderWidth = 2;
        [_otherLike enableRoundImage];
        //[self.container addSubview:_otherLike];
        
        _likeButton.layer.borderColor = [UIColor whiteColor].CGColor;
        _likeButton.layer.borderWidth = 2;
        _likeButton.backgroundColor = [UIColor clearColor];
        _likeButton.enableTouchEffects = FALSE;
        //[self.container addSubview:_likeButton];
        
        _moreButton = [[EZShapeButton alloc] initWithFrame:CGRectMake(0, 0, 60, 44)];
        _moreButton.center = CGPointMake(CurrentScreenWidth - 30, CurrentScreenHeight - 27);
        [self.container addSubview:_moreButton];
        
        _cameraView = [[EZClickView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        _cameraView.center = _container.center;
        _cameraView.backgroundColor = RGBCOLOR(255, 128, 0);
        _cameraView.hidden = YES;
        [_container addSubview:_cameraView];
        
        
        [self.contentView addSubview:_container];
        //[self.contentView addSubview:_toolRegion];
        //[self.contentView addSubview:_feedbackRegion];
        [_rotateContainer addSubview:_frontImage];
        
        //[self createTimeLabel];
        //[_frontImage addSubview:_toolRegion];
        //[_rotateContainer addSubview:_toolRegion];
        //_container.enableTouchEffects = NO;
        //_chatUnit = [[EZChatUnit alloc] initWithFrame:CGRectMake(10, CurrentScreenHeight - 200, CurrentScreenWidth, 40)];
        //[_container addSubview:_chatUnit];
        
    }
    return self;
}


- (void) createTimeLabel
{

    _photoDate = [[UILabel alloc] initWithFrame:CGRectMake(150, CurrentScreenHeight - 80, 160, 21)];
    _photoDate.font = [UIFont systemFontOfSize:13];
    _photoDate.textAlignment = NSTextAlignmentRight;
    _photoDate.textColor = [UIColor whiteColor];
    _photoDate.backgroundColor = [UIColor clearColor];
    //[self addSubview:_textDate];
    [_photoDate enableShadow:[UIColor blackColor]];
    _photoDate.layer.cornerRadius = 3.0;
    [_container addSubview:_photoDate];

}

- (UIView*) createRotateContainer:(CGRect)rect
{
    UIView* rotateContainer = [[UIView alloc] initWithFrame:rect];
    rotateContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    rotateContainer.clipsToBounds = true;
    //[rotateContainer enableRoundImage];
    return rotateContainer;
}

- (EZSimpleClick*) createFrontImage
{
    EZSimpleClick* frontImage = [[EZSimpleClick alloc] initWithFrame:CGRectMake(0, 0, CurrentScreenWidth, CurrentScreenHeight)];
    frontImage.contentMode = UIViewContentModeScaleAspectFill;
    frontImage.clipsToBounds = true;
    frontImage.backgroundColor = VinesGray;
    //[frontImage enableRoundImage];
    return frontImage;
}

- (EZBarRegion*) createToolRegion:(CGRect)rect
{
    
    EZBarRegion* res = [[EZBarRegion alloc] initWithFrame:rect];
    res.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin;
    res.location.text = @"上海, 张江";
    res.time.text = @"10:20";
    /**
    UIView* toolRegion = [[UIView alloc] initWithFrame:rect];
    toolRegion.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin;
    toolRegion.backgroundColor = [UIColor whiteColor];//randBack(nil);
    //_toolRegion.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
    //_toolRegion.backgroundColor = [UIColor clearColor];//RGBCOLOR(128, 128, 255);
    //My feedback will grow gradually.
    UILabel* photoTalk = [[UILabel alloc] initWithFrame:CGRectMake(15, (ToolRegionHeight - 20)/2.0, 290, 20)];
    photoTalk.font = [UIFont systemFontOfSize:10];
    photoTalk.tag = MainLabelTag;
    photoTalk.textAlignment = NSTextAlignmentLeft;
    photoTalk.textColor = [UIColor blackColor];
    photoTalk.backgroundColor = [UIColor clearColor];
    photoTalk.text = @"I love you 我爱大萝卜 哈哈 1234";
    [toolRegion addSubview:photoTalk];
     **/
    return res;
}

- (UIView*) createDupContainerTest:(UIImage *)img
{
    CGFloat adjustedHeight = [self calHeight:img.size];
    UIView* rt = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ContainerWidth, adjustedHeight + ToolRegionHeight)];
    rt.backgroundColor = RGBCOLOR(128, 128, 128);
    return rt;
}


- (UIView*) createDupContainer:(UIImage*)img
{
    CGFloat adjustedHeight = [self calHeight:img.size];
    UIView* rotateContainer = [self createRotateContainer:CGRectMake(0, 0, ContainerWidth, adjustedHeight + ToolRegionHeight)];
    UIImageView* frontImage = [self createFrontImage];
    frontImage.image = img;
    //[frontImage setSize:CGSizeMake(ContainerWidth, adjustedHeight)];
    [rotateContainer addSubview:frontImage];
    UIView* toolRegion = [self createToolRegion:CGRectMake(0, adjustedHeight, ContainerWidth, ToolRegionHeight)];
    [rotateContainer addSubview:toolRegion];
    [frontImage setSize:CGSizeMake(ContainerWidth, adjustedHeight)];
    return rotateContainer;
}
//Newly added method.
//I will adjust the image size and layout accordingly.
- (void) adjustInnerSize:(CGSize)size
{
    CGFloat adjustedHeight = [self calHeight:size];
    [_rotateContainer setSize:CGSizeMake(ContainerWidth, adjustedHeight+ToolRegionHeight)];
    //[_frontNoEffects setSize:CGSizeMake(320, adjustedHeight)];
    [_frontImage setSize:CGSizeMake(ContainerWidth, adjustedHeight)];
}

- (void) adjustCellSize:(CGSize)size
{
    CGFloat adjustedHeight = [self calHeight:size];
    //CGRect adjustedFrame = CGRectMake(0, 0, 320, adjustedHeight);
    [_container setSize:CGSizeMake(ContainerWidth, adjustedHeight+ToolRegionHeight)];
    [_rotateContainer setSize:CGSizeMake(ContainerWidth, adjustedHeight+ToolRegionHeight)];
    //[_frontNoEffects setSize:CGSizeMake(320, adjustedHeight)];
    [_frontImage setSize:CGSizeMake(ContainerWidth, adjustedHeight)];
    //[_frontImage adjustShadowSize:CGSizeMake(320, adjustedHeight)];
    //[_frontImage adjustImageShadowSize:CGSizeMake(320, adjustedHeight)];
    //[_toolRegion setPosition:CGPointMake(0, adjustedHeight)];
    //[_feedbackRegion setPosition:CGPointMake(0, adjustedHeight+_toolRegion.frame.size.height)];
    
}

- (void) displayEffectImage:(UIImage*)img
{
    CGSize imgSize = img.size;
    CGFloat adjustedHeight = [self calHeight:imgSize];
    CGRect adjustedFrame = CGRectMake(0, 0, 320, adjustedHeight);
    if(!_frontImage){
        //_frontImage = [EZStyleImage createFilteredImage:adjustedFrame];
        _frontImage = [[UIImageView alloc] initWithFrame:adjustedFrame];
        //_frontImage.contentMode = UIViewContentModeScaleAspectFill;
        [_container setFrame:adjustedFrame];
        [_container addSubview:_frontImage];
    }else{
        [_frontImage setFrame:adjustedFrame];
        [_container setFrame:adjustedFrame];
        [_container addSubview:_frontImage];
    }
    [_frontImage setImage:img];
}


- (void) displayImage:(UIImage*)img
{
    [_frontImage setImage:img];

}

//Why not get the size directly?
//This is hard.
//The name is just misleading.
//Mean I only the size for the image.
- (CGFloat) calHeight:(CGSize)size
{
    return  ceilf((size.height/size.width) * ContainerWidth);
}

- (void) backToOriginSize
{
    [_container setSize:CGSizeMake(ContainerWidth, ContainerWidth+ToolRegionHeight)];
    [_frontImage setSize:CGSizeMake(ContainerWidth, ContainerWidth)];
    //[_toolRegion setFrame:ToolRegionRect];
    //[_feedbackRegion setFrame:FeedbackRegionRect];
}



//What's the purpose of this method?
//Is to display an image on the cell, right?
//Cool, I will be clicked and display again.
//Let's just keep it simple and stupid.
//Make sure front image is always on the front.
- (void) displayPhoto:(NSString*)url
{
    //[self addSubview:_frontImage];
    //[_frontImage setImageWithURL:str2url(url) placeholderImage:PlaceHolderLargest];
}


- (void) switchImage:(EZPhoto*)photo photo:(EZDisplayPhoto*)dp complete:(EZEventBlock)blk tableView:(UITableView*)tableView index:(NSIndexPath*)path
{
    
        EZPhoto* curPhoto = photo;
  
        UIView* srcView = [_rotateContainer snapshotViewAfterScreenUpdates:YES];
        srcView.tag = animateCoverViewTag;
        EZDEBUG(@"Will come up with the old animation.src:%i, _rotatePointer:%i, isFront:%i, screenURL:%@",(int)srcView, (int)_rotateContainer, dp.isFront, curPhoto.screenURL);
        [_container addSubview:srcView];
        //_rotateContainer.hidden = TRUE;
        EZDEBUG(@"Assume the switch is ready");
        if(dp.isFront){
            [_frontImage setImage:curPhoto.getScreenImage];
        }else{
            //[_frontImage setImageWithURL:str2url(curPhoto.screenURL) placeholderImage:placeholdImage];
            [_frontImage setImageWithURL:str2url(curPhoto.screenURL)];
        }
        [UIView flipTransition:srcView dest:_rotateContainer container:_container isLeft:YES duration:2 complete:^(id obj){
            [srcView removeFromSuperview];
        }];
      
}

//I am happy that define a good interface to handle the image switch action
- (void) switchImageTo:(NSString*)url
{
    __weak EZPhotoCell* weakSelf = self;
    //[_backImage setImageWithURL:str2url(url) placeholderImage:PlaceHolderLargest];
    [UIView flipTransition:_frontImage dest:_backImage container:_container isLeft:YES duration:1.0 complete:^(id obj){
        //UIImageView* tmp = _frontImage;
        //_frontImage = _backImage;
        //_backImage = tmp;
        if(weakSelf.flippedCompleted){
            weakSelf.flippedCompleted(nil);
        }
    }];
    //make the front image always there to recieve the image url.
    //I love this game, right?
    //UIImageView* tmp = _frontImage;
    //_frontImage = _backImage;
    //_backImage = tmp;
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
