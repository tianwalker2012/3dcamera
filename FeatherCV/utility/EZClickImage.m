//
//  EZClickImage.m
//  ShowHair
//
//  Created by xietian on 13-3-24.
//  Copyright (c) 2013年 xietian. All rights reserved.
//

#import "EZClickImage.h"
#import <QuartzCore/QuartzCore.h>


@implementation EZClickImage

- (void) config
{
    self.userInteractionEnabled = true;
    _enableTouchEffects = false;
    _longPressTime = 0.5;
    //self.backgroundColor = ButtonWhiteColor;
    self.backgroundColor = [UIColor clearColor];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self config];
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    [self config];
    return self;
}

- (id) initWithImage:(UIImage *)image
{
    self = [super initWithImage:image];
    [self config];
    return self;
}

- (void) pressed
{
    EZDEBUG(@"Pressed clicked");
    if(_enableTouchEffects){
        if(_touchStyle == kEZRandomColor){
            if(self.highlightedImage){
                _backupImage = self.image;
                self.image = self.highlightedImage;
            }else{
                if(!_pressedView){
                    _pressedView = [[UIView alloc] initWithFrame:self.bounds];
                    [self addSubview:_pressedView];
                }else{
                    [_pressedView setFrame:self.bounds];
                }
                [self bringSubviewToFront:_pressedView];
                _pressedView.backgroundColor = _pressedColor?_pressedColor:ClickedColor; //randBack(_pressedColor);
                _pressedView.hidden = false;
            
            }
        }else if(_touchStyle == kEZWhiteBlur){
            UIView* point = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 4, 4)];
            point.backgroundColor = RGBA(255, 255, 255, 128);
            [point enableRoundImage];
            point.center = CGPointMake(self.bounds.size.width/2.0, self.bounds.size.height/2.0);
            [self addSubview:point];
            [UIView animateWithDuration:0.3 animations:^(){
                point.transform = CGAffineTransformMakeScale(20, 20);
                point.alpha = 0;
            } completion:^(BOOL completed){
                [point removeFromSuperview];
            }];
        }
    }
        
}

//Mean the touch ended, doesn't mean a effective click
- (void) unpressed
{
    //_pressedView.hidden = true;
    if(_enableTouchEffects){
        if(_touchStyle == kEZRandomColor){
        if(self.highlightedImage){
            self.image = _backupImage;
        }else{
            [UIView animateWithDuration:0.3 animations:^(){
                _pressedView.alpha = 0;
            } completion:^(BOOL completed){
                _pressedView.hidden = true;
                _pressedView.alpha = 1.0;
            }];
        }
        }
    }

}


- (id) initWithImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage
{
    self = [super initWithImage:image highlightedImage:highlightedImage];
    [self config];
    return self;
}



- (void) recieveLongPress:(CGFloat)time callback:(EZEventBlock)block
{
    _longPressBlock = block;
    _longPressTime = time;
}


//Any finger pressed will trigger this event.
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    _touch = [touches anyObject];
    _fingerPressed = true;
    _longPressedCalled = false;
    if(_longPressBlock){
        dispatch_later(_longPressTime, ^(){
            if(_fingerPressed){
                EZDEBUG(@"long press triggered");
                _longPressedCalled = YES;
                _longPressBlock(self);
            }else{
                EZDEBUG(@"long press ignore for released");
            }
        });
    }
    [self pressed];
    if(_pressedBlock){
        _pressedBlock(self);
    }
    
}

- (void) touchFadeEffects:(UITouch*) touch
{
    UIImageView* imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"flash-light"]];
    CGPoint touchPT = [touch locationInView:self];
    //EZDEBUG(@"touched ended at:%@", NSStringFromCGPoint(touchPT));
    [imgView setCenter:touchPT];
    [self addSubview:imgView];
    
    [UIView animateWithDuration:0.4 animations:^(){
        imgView.transform = CGAffineTransformMakeScale(2, 2);
        imgView.alpha = 0;
    } completion:^(BOOL completed){
        [imgView removeFromSuperview];
    }];
}
//- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    _touch = [touches anyObject];
    _fingerPressed = false;
    [self unpressed];
    if(!_longPressedCalled){
        if(_releasedBlock){
            _releasedBlock(self);
        }
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    _fingerPressed = false;
    [self unpressed];
}


@end
