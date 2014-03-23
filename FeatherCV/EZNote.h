//
//  EZNote.h
//  FeatherCV
//
//  Created by xietian on 14-3-20.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import <Foundation/Foundation.h>


@class  EZPhoto;
@interface EZNote : NSObject

@property (nonatomic, strong) NSString* noteID;



@property (nonatomic, strong) NSString* type;
//MongoUtil.save('notes', {'type':'like','personID':str(photo['personID']),'photoID':photoID,"otherID":personID,"like":likeStr})
//Like it or not.
//Only useful when use like as type
@property (nonatomic, strong) NSString* photoID;
@property (nonatomic, assign) BOOL like;
@property (nonatomic, strong) NSString* otherID;


//match flag
//'notes', {'type':'match','personID':str(subPhoto['personID']), 'srcID':pid, 'matchedID':str(srcID),
@property (nonatomic, strong) NSString* srcID;
@property (nonatomic, strong) NSString* matchedID;

@property (nonatomic, strong) NSDate* createdTime;

@property (nonatomic, strong) EZPhoto* matchedPhoto;

- (void) fromJson:(NSDictionary*)dict;

@end