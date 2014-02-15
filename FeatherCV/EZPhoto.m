//
//  EZPhoto.m
//  Feather
//
//  Created by xietian on 13-9-17.
//  Copyright (c) 2013年 tiange. All rights reserved.
//

#import "EZPhoto.h"
#import "EZDataUtil.h"
#import "EZThreadUtility.h"
#import "EZDataUtil.h"

@implementation EZPhoto


- (NSArray*) conversationToJson
{
    //if(!_conversations)
    //    return nil;
    NSMutableArray* res = [[NSMutableArray alloc] init];
    for(NSDictionary* dict in _conversations){
        [res addObject:@{
                         @"text":[dict objectForKey:@"text"],
                         @"date":isoDateFormat([dict objectForKey:@"date"])
                         }];
    }
    return res;
}

- (NSArray*) conversationFromJson:(NSArray*)jsons
{
    NSMutableArray* res = [[NSMutableArray alloc] init];
    for(NSDictionary* dict in jsons){
        [res addObject:@{
                         @"text":[dict objectForKey:@"text"],
                         @"date":isoStr2Date([dict objectForKey:@"date"])
                         }];
    }
    return res;
}

- (NSDictionary*) toJson
{

    
    return @{
             //@"id":_photoID,
             @"personID":null2Empty(_owner.personID),
             @"assetURL":null2Empty(_assetURL),
             @"longtitude":@(_longitude),
             @"latitude":@(_latitude),
             @"altitude":@(_altitude),
             @"uploaded":@(_uploaded),
             @"shareStatus":@(_shareStatus),
             @"width":@(_size.width),
             @"height":@(_size.height),
             @"createdTime":_createdTime?isoDateFormat(_createdTime):@"",
             @"conversations":[self conversationToJson]
                 };
}

- (void) fromJson:(NSDictionary*)dict
{
    EZDEBUG(@"json raw string:%@", dict);
    NSString* personID = [dict objectForKey:@"personID"];
    [[EZDataUtil getInstance] getPersonID:personID success:^(NSArray* ps){
        _owner = [ps objectAtIndex:0];
    } failure:^(NSError* err){
        EZDEBUG(@"Error to find a person");
    }];
    _srcPhotoID = [dict objectForKey:@"srcPhotoID"];
    _assetURL = [dict objectForKey:@"assetURL"];
    _longitude = [[dict objectForKey:@"longitude"] doubleValue];
    _latitude = [[dict objectForKey:@"latitude"] doubleValue];
    _altitude = [[dict objectForKey:@"altitude"] doubleValue];
    _uploaded = [[dict objectForKey:@"uploaded"] integerValue];
    _shareStatus = [[dict objectForKey:@"shareStatus"] intValue];
    _createdTime = isoStr2Date([dict objectForKey:@"createdTime"]);
    _screenURL = [dict objectForKey:@"screenURL"];
    _conversations = [self conversationFromJson:[dict objectForKey:@"conversations"]];
    
    CGFloat width = [[dict objectForKey:@"width"] floatValue];
    CGFloat height = [[dict objectForKey:@"height"] floatValue];

    _size = CGSizeMake(width, height);
    EZDEBUG(@"The serialized size:%@, screenURL:%@", NSStringFromCGSize(_size), _screenURL);
    NSArray* photoRelation = [dict objectForKey:@"photoRelations"];
    EZDEBUG(@"Photo count:%i", photoRelation.count);
    if(photoRelation.count > 0){
        _photoRelations = [[NSMutableArray alloc] initWithCapacity:photoRelation.count];
        for(int i = 0; i < photoRelation.count; i ++){
            NSDictionary* dict = [photoRelation objectAtIndex:i];
            EZPhoto* photo = [[EZPhoto alloc] init];
            [photo fromJson:dict];
            [_photoRelations addObject:photo];
        }
    }
    EZDEBUG(@"The created date is:%@", _createdTime);
}

- (UIImage*) getThumbnail
{
    return [[UIImage alloc] initWithCGImage:[_asset aspectRatioThumbnail]];
}


- (UIImage*) getOriginalImage
{
    ALAssetRepresentation *assetRepresentation = [_asset defaultRepresentation];
    
    UIImage *fullScreenImage = [UIImage imageWithCGImage:[assetRepresentation fullResolutionImage]
                                                   scale:[assetRepresentation scale]
                                             orientation:UIImageOrientationUp];
    
    ALAssetOrientation orientation = (ALAssetOrientation)[[_asset valueForProperty:ALAssetPropertyOrientation] integerValue];
    EZDEBUG(@"photo orientation:%i", orientation);
    return fullScreenImage;

}

- (UIImage*) getScreenImage
{
    ALAssetRepresentation *assetRepresentation = [_asset defaultRepresentation];
    
    UIImage *fullScreenImage = [UIImage imageWithCGImage:[assetRepresentation fullScreenImage]
                                                   scale:[assetRepresentation scale]
                                             orientation:UIImageOrientationUp];
    
    ALAssetOrientation orientation = (ALAssetOrientation)[[_asset valueForProperty:ALAssetPropertyOrientation] integerValue];
    EZDEBUG(@"photo orientation:%i", orientation);
    return fullScreenImage;

}

- (void) getAsyncImage:(EZEventBlock)block
{
    [[EZThreadUtility getInstance] executeBlockInQueue:^(){
        UIImage* img = [self getScreenImage];
        dispatch_async(dispatch_get_main_queue(), ^(){
            block(img);
        });
    }];
}

@end
