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

- (id) init
{
    self = [super init];
    _conversations = [[NSMutableArray alloc] init];
    _likedUsers = [[NSMutableArray alloc] init];
    return self;
    
}

- (NSArray*) conversationToJson
{
    //if(!_conversations)
    //    return nil;
    NSMutableArray* res = [[NSMutableArray alloc] init];
    for(NSDictionary* dict in _conversations){
        NSString* dateStr = isoDateFormat([dict objectForKey:@"date"]);
        [res addObject:@{
                         @"text":[dict objectForKey:@"text"],
                         @"date":dateStr?dateStr:@""
                         }];
    }
    return res;
}

- (NSArray*) conversationFromJson:(NSArray*)jsons
{
    NSMutableArray* res = [[NSMutableArray alloc] init];
    for(NSDictionary* dict in jsons){
        NSDate* date = isoStr2Date([dict objectForKey:@"date"]);
        if(!date){
            [res addObject:@{
                         @"text":[dict objectForKey:@"text"]
                         }];
        }else{
            [res addObject:@{
                             @"text":[dict objectForKey:@"text"],
                             @"date":date
                             }];
        }
    }
    return res;
}


- (NSArray*) localRelationsToJson
{
    NSMutableArray* res = [[NSMutableArray alloc] init];
    for(EZPhoto* pt in _photoRelations){
        [res addObject:[pt toLocalJson]];
    }
    return res;
}

- (NSArray*) relationsToJson
{
    NSMutableArray* res = [[NSMutableArray alloc] init];
    for(EZPhoto* pt in _photoRelations){
        [res addObject:pt.photoID];
    }
    return res;
}

- (NSArray*) relationsUserID
{
    NSMutableArray* res = [[NSMutableArray alloc] init];
    for(EZPhoto* pt in _photoRelations){
        [res addObject:pt.personID];
    }
    return res;
}

//Have different needs
- (NSDictionary*) toLocalJson
{
    return @{
             //@"id":_photoID,
             @"photoID":null2Empty(_photoID),
             @"personID":null2Empty(_personID),
             @"assetURL":null2Empty(_assetURL),
             @"longtitude":@(_longitude),
             @"latitude":@(_latitude),
             @"altitude":@(_altitude),
             @"uploaded":@(_uploaded),
             @"shareStatus":@(_shareStatus),
             @"width":@(_size.width),
             @"height":@(_size.height),
             @"createdTime":_createdTime?isoDateFormat(_createdTime):@"",
             @"conversations":[self conversationToJson],
             @"photoRelations":[self localRelationsToJson],
             @"relationUsers":[self relationsUserID],
             @"screenURL":null2Empty([self screenURL]),
             @"likedUsers":_likedUsers.count?_likedUsers:@[],
             //@"uploadInfoSuccess":@(_uploadInfoSuccess),
             @"contentStatus":@(_contentStatus),
             @"infoStatus":@(_infoStatus),
             @"updateStatus":@(_updateStatus),
             @"exchangeStatus":@(_exchangeStatus),
             @"exchangePersonID":(_exchangePersonID ? _exchangePersonID : @""),
             //@"conversationUpdated":@(_conversationUploaded),
             @"deleted":@(_deleted),
             @"type":@(_type),
             @"isPair":@(_isPair),
             @"isFrontCamera":@(_isFrontCamera)
             };
}

- (NSDictionary*) toJson
{
    if(_photoID){
        return @{
             //@"id":_photoID,
             @"photoID":null2Empty(_photoID),
             @"personID":null2Empty(_personID),
             @"assetURL":null2Empty(_assetURL),
             @"longtitude":@(_longitude),
             @"latitude":@(_latitude),
             @"altitude":@(_altitude),
             @"uploaded":@(_uploaded),
             @"shareStatus":@(_shareStatus),
             @"width":@(_size.width),
             @"height":@(_size.height),
             @"createdTime":_createdTime?isoDateFormat(_createdTime):@"",
             @"conversations":[self conversationToJson],
             @"photoRelations":[self relationsToJson],
             @"relationUsers":[self relationsUserID],
             @"type":@(_type),
             //@"screenURL":[self screenURL],
             @"likedUsers":_likedUsers.count?_likedUsers:@[],
             @"isPair":@(_isPair),
             @"isFrontCamera":@(_isFrontCamera)
                 };
        
    }else{
        return @{
                 //@"id":_photoID,
                 @"personID":null2Empty(_personID),
                 @"assetURL":null2Empty(_assetURL),
                 @"longtitude":@(_longitude),
                 @"latitude":@(_latitude),
                 @"altitude":@(_altitude),
                 @"uploaded":@(_uploaded),
                 @"shareStatus":@(_shareStatus),
                 @"width":@(_size.width),
                 @"height":@(_size.height),
                 @"createdTime":_createdTime?isoDateFormat(_createdTime):@"",
                 @"conversations":[self conversationToJson],
                 @"photoRelations":[self relationsToJson],
                 @"relationUsers":[self relationsUserID],
                 //@"screenURL":[self screenURL],
                 @"type":@(_type),
                 @"liked":_likedUsers.count?_likedUsers:@[],
                 @"isPair":@(_isPair),
                 @"isFrontCamera":@(_isFrontCamera)
                 };

    }
}
/**
-(id)copyWithZone:(NSZone *)zone
{
    // We'll ignore the zone for now
    EZPhoto *another = [[EZPhoto alloc] init];
    another.obj = [obj copyWithZone: zone];
    
    return another;
}
**/
- (BOOL) isUploadDone
{
    if([_screenURL isNotEmpty]){
        _contentStatus = kUploadDone;
    }
    return (_contentStatus == kUploadDone && (_updateStatus == kUpdateDone || _updateStatus == kUpdateNone) && _infoStatus == kUploadDone && (_exchangeStatus == kExchangeNone || _exchangeStatus == kExchangeDone));
}

//Set all the flag right, so that user will not upload the photo again.
- (void) setFromServer
{
    _contentStatus = kUploadDone;
    _updateStatus = kUpdateDone;
    _infoStatus = kUploadDone;
    _exchangeStatus = kExchangeDone;
}

- (void) fromLocalJson:(NSDictionary*)dict
{
    //EZDEBUG(@"from local json raw string:%@", dict);
    _contentStatus = [[dict objectForKey:@"contentStatus"] integerValue];
    _infoStatus = [[dict objectForKey:@"infoStatus"] integerValue];
    _updateStatus = [[dict objectForKey:@"updateStatus"] integerValue];
    _exchangeStatus = [[dict objectForKey:@"exchangeStatus"] integerValue];
    //_uploadPhotoSuccess = [[dict objectForKey:@"uploadPhotoSuccess"] integerValue];
    _deleted = [[dict objectForKey:@"deleted"] integerValue];
    //_conversationUploaded = [[dict objectForKey:@"conversationUpdated"] integerValue];
    _exchangeStatus = [[dict objectForKey:@"exchangeStatus"] integerValue];
    _exchangePersonID = [dict objectForKey:@"exchangePersonID"];
    [self fromJson:dict];
}


- (id)copyWithZone:(NSZone *)zone
{
    EZPhoto* pt = [[EZPhoto alloc] init];
    pt.photoID = _photoID;
    pt.personID = _personID;
    pt.assetURL = _assetURL;
    pt.longitude = _longitude;
    pt.latitude = _latitude;
    pt.altitude = _altitude;
    pt.uploaded = _uploaded;
    pt.shareStatus = _shareStatus;
    pt.size = _size;
    pt.createdTime = _createdTime;
    pt.conversations = _conversations;
    pt.photoRelations = _photoRelations;
    pt.screenURL = _screenURL;
    pt.likedUsers = _likedUsers;
    pt.infoStatus = _infoStatus;
    pt.contentStatus = _contentStatus;
    pt.exchangeStatus = _exchangeStatus;
    pt.updateStatus = _updateStatus;
    //pt.conversationUploaded = _conversationUploaded;
    pt.deleted = _deleted;
    pt.type = _type;
    pt.typeUI = _type;
    pt.isPair = _isPair;
    pt.isFrontCamera = _isFrontCamera;
    return pt;
}


- (void) fromJson:(NSDictionary*)dict
{
    
    //NSDate* date = isoStr2Date([dict objectForKey:@"createdTime"]);
    //if(!date){
    //    EZDEBUG(@"photoID:%@,format:%@, string date:%@",[dict objectForKey:@"photoID"], [dict objectForKey:@"createdTime"], [EZDataUtil getInstance].isoFormatter.dateFormat);
    //}
    //EZDEBUG(@"json raw string:%@", dict);
    _personID = [dict objectForKey:@"personID"];
    //[[EZDataUtil getInstance] getPersonID:personID success:^(NSArray* ps){
    //    _owner = [ps objectAtIndex:0];
    //} failure:^(NSError* err){
    //    EZDEBUG(@"Error to find a person");
    //}];
    _type = [[dict objectForKey:@"type"] integerValue];
    _typeUI = _type;
    _photoID = [dict objectForKey:@"photoID"];
    _srcPhotoID = [dict objectForKey:@"srcPhotoID"];
    _assetURL = [dict objectForKey:@"assetURL"];
    _longitude = [[dict objectForKey:@"longitude"] doubleValue];
    _latitude = [[dict objectForKey:@"latitude"] doubleValue];
    _altitude = [[dict objectForKey:@"altitude"] doubleValue];
    _uploaded = [[dict objectForKey:@"uploaded"] integerValue];
    _shareStatus = [[dict objectForKey:@"shareStatus"] intValue];
    _createdTime = isoStr2Date([dict objectForKey:@"createdTime"]);
    _screenURL = [dict objectForKey:@"screenURL"];
    _thumbURL = url2thumb(_screenURL);
    _conversations = [self conversationFromJson:[dict objectForKey:@"conversations"]];
    [_likedUsers addObjectsFromArray:[dict objectForKey:@"likedUsers"]];
    _isPair = [[dict objectForKey:@"isPair"] boolValue];
    CGFloat width = [[dict objectForKey:@"width"] floatValue];
    CGFloat height = [[dict objectForKey:@"height"] floatValue];
    _isFrontCamera = [[dict objectForKey:@"isFrontCamera"] integerValue];

    _size = CGSizeMake(width, height);
    //EZDEBUG(@"The serialized size:%@, screenURL:%@", NSStringFromCGSize(_size), _screenURL);
    NSArray* photoRelation = [dict objectForKey:@"photoRelations"];
    //EZDEBUG(@"Photo count:%i", photoRelation.count);
    if(photoRelation.count > 0){
        _photoRelations = [[NSMutableArray alloc] initWithCapacity:photoRelation.count];
        for(int i = 0; i < photoRelation.count; i ++){
            NSDictionary* dict = [photoRelation objectAtIndex:i];
            EZPhoto* photo = [[EZPhoto alloc] init];
            [photo fromJson:dict];
            [_photoRelations addObject:photo];
        }
    }
    //EZDEBUG(@"The created date is:%@", _createdTime);
}


- (UIImage*) getThumbnail
{
    //return [[UIImage alloc] initWithCGImage:[_asset aspectRatioThumbnail]];
    return nil;
}

/**
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
 **/

/**
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
**/

- (UIImage*) getScreenImage
{
    //NSURL* fileURL = str2url(_assetURL);
    return  [UIImage imageWithContentsOfFile:_assetURL];
}

- (NSString*) getConversation
{
    if(_conversations.count){
        NSDictionary* convs = [_conversations objectAtIndex:0];
        return [convs objectForKey:@"text"];
    }
    //cell.ownTalk.text = [conversation objectForKey:@"text"];
    return @"";
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
