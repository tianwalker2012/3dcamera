//
//  EZNote.m
//  FeatherCV
//
//  Created by xietian on 14-3-20.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZNote.h"
#import "EZDataUtil.h"


@implementation EZNote

- (void) fromJson:(NSDictionary*)dict
{
    _type = [dict objectForKey:@"type"];
    _noteID = [dict objectForKey:@"noteID"];
    _photoID = [dict objectForKey:@"photoID"];
    _otherID = [dict objectForKey:@"otherID"];
    _like = [[dict objectForKey:@"like"] integerValue];

    //This is the source photoID
    _srcID = [dict objectForKey:@"srcID"];
    _matchedID = [dict objectForKey:@"matchedID"];
    NSDictionary* matchedDict = [dict objectForKey:@"matchedPhoto"];
    if(matchedDict){
        _matchedPhoto = [[EZPhoto alloc] init];
        [_matchedPhoto fromJson:matchedDict];
    }
    _createdTime = isoStr2Date([dict objectForKey:@"createdTime"]);
}

@end