//
//  EZPopupView.m
//  BabyCare
//
//  Created by xietian on 14-7-29.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "EZPopupView.h"
#import "EZCustomButton.h"


#define GradientBeginColor RGBCOLOR(51, 181, 225)

#define GradientEndColor RGBCOLOR(66, 179, 221)

#define ShowPositionRatio 3.0

@implementation EZPopupView

- (UIImage *) imageFromColor:(UIColor *)color {
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    //  [[UIColor colorWithRed:222./255 green:227./255 blue: 229./255 alpha:1] CGColor]) ;
    CGContextFillRect(context, rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        UIView* barView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 40)];
        [barView addGradient:@[GradientBeginColor, GradientEndColor] points:@[@(0.0), @(1.0)]];
        [self addSubview:barView];
        
        _title = [UILabel createLabel:CGRectMake(30, 8, frame.size.width - 2*30, 24) font:[UIFont boldSystemFontOfSize:20.0] color:[UIColor whiteColor]];
        _title.textAlignment = NSTextAlignmentCenter;
        [barView addSubview:_title];
        EZCustomButton* quitBtn = [EZCustomButton createButton:CGRectMake(0, 0, 40, 40) image:[UIImage imageNamed:@"header_btn_cancel"]];
        [quitBtn addTarget:self action:@selector(cancelClicked:) forControlEvents:UIControlEventTouchUpInside];
        //[barView addSubview:quitBtn];
        
        EZCustomButton* saveButton = [EZCustomButton createButton:CGRectMake(frame.size.width - 40, 0, 40, 40) image:[UIImage imageNamed:@"header_btn_save"]];
        [saveButton addTarget:self action:@selector(saveClicked:) forControlEvents:UIControlEventTouchUpInside];
        //[barView addSubview:saveButton];
        
        _cancelButton = [UIButton createButton:CGRectMake(0, self.height - 44, self.width/2.0, 44) font:[UIFont boldSystemFontOfSize:16] color:[UIColor whiteColor] align:NSTextAlignmentCenter];
        [_cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelButton addTarget:self action:@selector(cancelClicked:) forControlEvents:UIControlEventTouchUpInside];
        UIView* colorView = [[UIView alloc] initWithFrame:_cancelButton.frame];
        colorView.backgroundColor = RGBCOLOR(204, 204, 204);
        //[_confirmButton setBackgroundImage:[self imageFromColor:RGBCOLOR(204, 204, 204)] forState:UIControlStateNormal];
        
        _confirmButton = [UIButton createButton:CGRectMake(self.width/2.0, self.height - 44, self.width/2.0, 44) font:[UIFont boldSystemFontOfSize:16] color:[UIColor whiteColor] align:NSTextAlignmentCenter];
        [_confirmButton setTitle:@"确定" forState:UIControlStateNormal];
        [_confirmButton addTarget:self action:@selector(saveClicked:) forControlEvents:UIControlEventTouchUpInside];
        UIView* confirmColor = [[UIView alloc] initWithFrame:_confirmButton.frame];
        confirmColor.backgroundColor = RGBCOLOR(255, 105, 93);
        [self addSubview:colorView];
        [self addSubview:confirmColor];
        [self addSubview:_cancelButton];
        [self addSubview:_confirmButton];
        
        self.layer.cornerRadius = 5;
        self.clipsToBounds = true;
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void) cancelClicked:(id)obj
{
    [self dismiss:YES];
}

- (void) saveClicked:(id)obj
{
    [self dismiss:YES];
    if(_saveBlock){
        _saveBlock(self);
    }
}

- (void) tapped:(id)tap
{
    EZDEBUG(@"do nothing");
}

- (void) showInView:(UIView*)parentView animated:(BOOL)animated
{
    CGFloat finalY = (parentView.height - self.height)/ShowPositionRatio;
    CGFloat finalX = (parentView.width - self.width)/2.0;
    UIView* blackOut = [[UIView alloc] initWithFrame:parentView.bounds];
    blackOut.backgroundColor = RGBA(0, 0, 0, 80);
    blackOut.tag = 20061007;
    UITapGestureRecognizer* tapGesturer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    [blackOut addGestureRecognizer:tapGesturer];
    [parentView addSubview:blackOut];
    [parentView addSubview:self];
    if(animated){
        [self setPosition:CGPointMake(finalX,  -self.height)];
        [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^(){
            [self setY:finalY];
        } completion:nil];
    }else{
        [self setPosition:CGPointMake(finalX,  -self.height)];
        [parentView addSubview:self];
    }
}

- (void) dismiss:(BOOL)animted
{
    UIView* blackOut = [self.superview viewWithTag:20061007];
    if(animted){
        [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^(){
            [self setY:-self.height];
            blackOut.alpha = 0.0;
        } completion:^(BOOL completed){
            [self removeFromSuperview];
            [blackOut removeFromSuperview];
        }];
    }else{
        [self removeFromSuperview];
        [blackOut removeFromSuperview];
    }
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
