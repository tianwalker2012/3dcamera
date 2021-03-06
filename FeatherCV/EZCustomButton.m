//
//  EZCustomButton.m
//  BabyCare
//
//  Created by xietian on 14-7-28.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZCustomButton.h"
#import "UIButton+AFNetworking.h"

@implementation EZCustomButton

- (id)initWithFrame:(CGRect)frame imageURL:(NSString*)imageURL touchEffects:(BOOL)touchEffect
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.showsTouchWhenHighlighted = touchEffect;
        _touchEffects = touchEffect;
        //UIImageView* imageView = [[UIImageView alloc] initWithImage:image];
        //[self addSubview:imageView];
        //[self setImage:image forState:UIControlStateNormal];
        [self setImageForState:UIControlStateNormal withURL:str2url(imageURL)];
        [self addTarget:self action:@selector(touchInside:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}


- (id)initWithFrame:(CGRect)frame image:(UIImage *)image touchEffects:(BOOL)touchEffect
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.showsTouchWhenHighlighted = touchEffect;
        _touchEffects = touchEffect;
        //UIImageView* imageView = [[UIImageView alloc] initWithImage:image];
        //[self addSubview:imageView];
        [self setImage:image forState:UIControlStateNormal];
        [self addTarget:self action:@selector(touchInside:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void) touchInside:(id)obj
{
    if(_clicked){
        _clicked(obj);
    }
}

+ (EZCustomButton*) createButton:(CGRect)frame imageUrl:(NSString*)imageURL
{
    return [[EZCustomButton alloc] initWithFrame:frame imageURL:imageURL touchEffects:YES];
}

+ (EZCustomButton*) createButton:(CGRect)frame image:(UIImage*)image
{
    return [[EZCustomButton alloc] initWithFrame:frame image:image touchEffects:YES];
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
