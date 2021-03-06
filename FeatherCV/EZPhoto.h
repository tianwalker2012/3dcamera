//
//  EZPhoto.h
//  Feather
//
//  Created by xietian on 13-9-17.
//  Copyright (c) 2013年 tiange. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "EZAppConstants.h"

typedef enum {
    kPrivatePhoto,
    kFriendOnly,
    kSeenByAll
} EZShareStatus;



typedef enum {
    kUpdateNone,
    kUpdateStart,
    kUpdateFailure,
    kUpdateDone
} EZUpdateStatus;


typedef enum{
    kExchangeNone,
    kExchangeStart,
    kExchangeFailure,
    kExchangeDone
} EZExchangeStatus;


typedef enum {
    kNormalPhoto,
    kPhotoRequest
}EZPhotoType;

@class ALAsset;
@class EZPerson;
@class LocalPhotos;
@interface EZPhoto : NSObject<NSCopying>
//@property (nonatomic, assign) int photoID;
//For any stored object, we will have this id. 
//@property (nonatomic, strong) NSManagedObjectID* objectID;
@property (nonatomic, strong) LocalPhotos* localPhoto;

@property (nonatomic, strong) NSString* photoID;

@property (nonatomic, strong) NSString* personID;


@property (nonatomic, assign) EZPhotoType type;
//It is the same.
//But only change for the UI, to address the issue 2 purpose contradict with each other.
@property (nonatomic, assign) EZPhotoType typeUI;

//This is only shared among 2 persons
@property (nonatomic, assign) BOOL isPair;

//Only start upload when this flag is true
@property (nonatomic, assign) BOOL startUpload;

//Who has liked this photo.
//Add the user id into this place
@property (nonatomic, strong) NSMutableArray* likedUsers;
//@property (nonatomic, assign) int ownerID;

//@property (nonatomic, assign) int otherID;

@property (nonatomic, strong) NSString* screenURL;

//I could use this to compare if I have newly added photo or not.
//Great, I love this game
//This can not be used.
//Will be used to match the photo from the asset.

//For local image only, we will make use of the system thumbnail.
//@property (nonatomic, strong) UIImage* thumbnail;

//This is information I extracted from the photo itself.
@property (nonatomic, strong) NSDate* createdTime;

@property (nonatomic, assign) double latitude;

@property (nonatomic, assign) double longitude;

@property (nonatomic, assign) double altitude;

@property (nonatomic, assign) EZShareStatus shareStatus;

@property (nonatomic, strong) NSString* address;

//Just to keep it temporarily. 
//@property (nonatomic, strong) ALAsset* asset;

@property (nonatomic, strong) NSString* assetURL;

@property (nonatomic, strong) NSString* thumbURL;

//If the image uploaded or not?
//If not will retry.
@property (nonatomic, assign) BOOL uploaded;

//What's the purpose for this field?
//Don't know. left as a reminder.
@property (nonatomic, assign) BOOL findMatched;


//Only when the prefetch is ready, I will try to rotate the image.
@property (nonatomic, assign) BOOL prefetchDone;
//Whether this photo uploaded or not
//Mean if the photo is local photo or not
//Who need this?
//for what purpose?
//Why should I care it is local or not?
//Don't know, put it here, let's Darwin decide it
//This property don't seems very well.
@property (nonatomic, assign) BOOL isLocal;

@property (nonatomic, assign) BOOL isFrontCamera;

//Do I have any case to use this?
@property (nonatomic, strong) NSDate* uploadedTime;

//The comment given by the owner
@property (nonatomic, strong) NSString* photoTalk;

//It is true,mean only visible to specified user
//Otherwise mean everybody can combine with it
@property (nonatomic, assign) BOOL isPeerOnly;

//The size for the image. why do I need it?
//I need this because, I need to determine the height for the
//Image, that's why I need it.
@property (nonatomic, assign) CGSize size;

//The photo which have a relationship with this one
@property (nonatomic, strong) NSArray* photoRelations;

@property (nonatomic, strong) NSArray* conversations;

//Secret match, will remove the photo relations when user didn't store the image.
@property (nonatomic, strong) NSString* srcPhotoID;

//Get called when the match remote call failed
//Will trigger the upload once the call successful.
//It is a flag to coordinate the local and remote operation 
@property (nonatomic, assign) BOOL matchCompleted;

//Have successfully uploaded the photo information
//@property (nonatomic, assign) BOOL uploadInfoSuccess;

//Upload the photo file itself success
//@property (nonatomic, assign) BOOL uploadPhotoSuccess;
//@property (nonatomic, assign) EZUploadStatus uploadStatus;


@property (nonatomic, assign) EZUploadStatus contentStatus;

@property (nonatomic, assign) EZUploadStatus infoStatus;

@property (nonatomic, assign) EZExchangeStatus exchangeStatus;

@property (nonatomic, assign) EZUpdateStatus updateStatus;

//Mean I will delte this photo from server.
@property (nonatomic, assign) BOOL deleted;

//Will get called when upload have progress
@property (nonatomic, strong) EZEventBlock progress;

@property (nonatomic, strong) EZEventBlock uploadSuccess;


//Will get called before remove the task from the queue.
//@property (nonatomic, strong) EZEventBlock uploadCompleted;

@property (nonatomic, strong) NSString* exchangePersonID;

//@property (nonatomic, assign) BOOL conversationUploaded;

//@property (nonatomic, assign) BOOL pendingMatch;

//@property (nonatomic, strong) NSString* otherURL;

//@property (nonatomic, assign) BOOL likedByOther;

//@property (nonatomic, assign) BOOL liked;
//Fetch the asset image, which is huge, so only do this when we really need it
//Even for thumbnail, we also have the memory issue with it. We need to get it done.
- (UIImage*) getOriginalImage;

- (UIImage*) getScreenImage;

- (UIImage*) getThumbnail;

- (NSString*) getConversation;
//Set all the flag right, so that user will not upload the photo again.
- (void) setFromServer;

- (void) getAsyncImage:(EZEventBlock)block;

- (NSDictionary*) toJson;

- (void) fromLocalJson:(NSDictionary*)dict;

- (NSDictionary*) toLocalJson;

- (void) fromJson:(NSDictionary*)dict;

- (BOOL) isUploadDone;

@end
