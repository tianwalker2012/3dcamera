// UIImageView+AFNetworking.m
//
// Copyright (c) 2013 AFNetworking (http://afnetworking.com)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "UIImageView+AFNetworking.h"

#import <objc/runtime.h>

#if defined(__IPHONE_OS_VERSION_MIN_REQUIRED)

#import "AFHTTPRequestOperation.h"
#import "EZImageCache.h"
@interface AFImageCache : NSCache <AFImageCache>
@end

#pragma mark -

static char kAFSharedImageCacheKey;
static char kAFImageRequestOperationKey;
static char kAFResponseSerializerKey;

@interface UIImageView (_AFNetworking)
@property (readwrite, nonatomic, strong, setter = af_setImageRequestOperation:) AFHTTPRequestOperation *af_imageRequestOperation;
@end

@implementation UIImageView (_AFNetworking)

+ (NSOperationQueue *)af_sharedImageRequestOperationQueue {
    static NSOperationQueue *_af_sharedImageRequestOperationQueue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _af_sharedImageRequestOperationQueue = [[NSOperationQueue alloc] init];
        _af_sharedImageRequestOperationQueue.maxConcurrentOperationCount = NSOperationQueueDefaultMaxConcurrentOperationCount;
    });

    return _af_sharedImageRequestOperationQueue;
}

- (AFHTTPRequestOperation *)af_imageRequestOperation {
    return (AFHTTPRequestOperation *)objc_getAssociatedObject(self, &kAFImageRequestOperationKey);
}

- (void)af_setImageRequestOperation:(AFHTTPRequestOperation *)imageRequestOperation {
    objc_setAssociatedObject(self, &kAFImageRequestOperationKey, imageRequestOperation, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

#pragma mark -

@implementation UIImageView (AFNetworking)
@dynamic imageResponseSerializer;

+ (id <AFImageCache>)sharedImageCache {
    static AFImageCache *_af_defaultImageCache = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _af_defaultImageCache = [[AFImageCache alloc] init];

        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidReceiveMemoryWarningNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * __unused notification) {
            [_af_defaultImageCache removeAllObjects];
        }];
    });

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgnu"
    return objc_getAssociatedObject(self, &kAFSharedImageCacheKey) ?: _af_defaultImageCache;
#pragma clang diagnostic pop
}

+ (void)setSharedImageCache:(id<AFImageCache>)imageCache {
    objc_setAssociatedObject(self, &kAFSharedImageCacheKey, imageCache, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id <AFURLResponseSerialization>)imageResponseSerializer {
    static id <AFURLResponseSerialization> _af_defaultImageResponseSerializer = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _af_defaultImageResponseSerializer = [AFImageResponseSerializer serializer];
    });

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgnu"
    return objc_getAssociatedObject(self, &kAFResponseSerializerKey) ?: _af_defaultImageResponseSerializer;
#pragma clang diagnostic pop
}

- (void)setImageResponseSerializer:(id <AFURLResponseSerialization>)serializer {
    objc_setAssociatedObject(self, &kAFResponseSerializerKey, serializer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark -

- (void)setImageWithURL:(NSURL *)url {
    [self setImageWithURL:url placeholderImage:nil];
}

- (void)setImageWithURL:(NSURL *)url
       placeholderImage:(UIImage *)placeholderImage
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];

    [self setImageWithURLRequest:request placeholderImage:placeholderImage success:nil failure:nil];
}


- (void) setImageWithURL:(NSURL *)url loading:(BOOL)loading
{
    [self setImageWithURL:url loading:loading success:nil failure:nil];
}

- (void)setImageWithURL:(NSURL*)url loading:(BOOL)loading
                success:(EZEventBlock)success
                failure:(EZEventBlock)failure
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
    UIActivityIndicatorView* ai = nil;
    if(loading){
        ai = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        ai.center = CGPointMake(self.width/2.0, self.height/2.0);
        [self addSubview:ai];
        [ai startAnimating];
    }
    
    [self setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        if(loading){
            [ai stopAnimating];
            [ai removeFromSuperview];
        }
        if(success){
            success(image);
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        if(loading){
            [ai stopAnimating];
            [ai removeFromSuperview];
        }
        if(failure){
            failure(error);
        }
    }];
}

//Load image before user notice anything
- (void) preloadImageURL:(NSURL *)url success:(EZEventBlock)success failed:(EZEventBlock)failed
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
    UIImage *cachedImage = [[EZImageCache sharedEZImageCache] getImage:request.URL.absoluteString]; //[[[self class] sharedImageCache] cachedImageForRequest:request];
    if (cachedImage) {
        if (success) {
            success(cachedImage);
        }
        //self.af_imageRequestOperation = nil;
    } else {
        //self.image = placeholderImage;
        //__weak __typeof(self)weakSelf = self;
        AFHTTPRequestOperation* imageRequestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        imageRequestOperation.responseSerializer = [AFImageResponseSerializer serializer];
        [imageRequestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            //[[[self class] sharedImageCache] cacheImage:responseObject forRequest:request];
            [[EZImageCache sharedEZImageCache] storeImage:responseObject key:[url absoluteString]];
            //UIImage *fetchBack = [[[self class] sharedImageCache] cachedImageForRequest:request];
            //EZDEBUG(@"Prefetch immediate fetch back:%@, %i, sharedCache:%i", url.absoluteString, (int)fetchBack, (int)[[self class] sharedImageCache]);
            if ([[request URL] isEqual:[operation.request URL]]) {
                if (success) {
                    success(responseObject);
                }
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if ([[request URL] isEqual:[operation.request URL]]) {
                if (failed) {
                    failed(error);
                }
            }
        }];
        [[[self class] af_sharedImageRequestOperationQueue] addOperation:imageRequestOperation];
    }
}

- (void)setImageWithURLRequest:(NSURLRequest *)urlRequest
              placeholderImage:(UIImage *)placeholderImage
                       success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image))success
                       failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error))failure
{
    [self cancelImageRequestOperation];

    UIImage *cachedImage = [[EZImageCache sharedEZImageCache] getImage:[urlRequest.URL absoluteString]]; //[[[self class] sharedImageCache] cachedImageForRequest:urlRequest];
    //EZDEBUG(@"load image from url:%@, %i, cache pointer:%i",urlRequest.URL.absoluteString, (int)cachedImage, (int) [[self class] sharedImageCache]);
    if (cachedImage) {
        if (success) {
            success(nil, nil, cachedImage);
        }
        self.image = cachedImage;
        self.af_imageRequestOperation = nil;
    } else {
        
        self.image = placeholderImage;

        __weak __typeof(self)weakSelf = self;
        self.af_imageRequestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:urlRequest];
        self.af_imageRequestOperation.responseSerializer = self.imageResponseSerializer;
        [self.af_imageRequestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            if ([[urlRequest URL] isEqual:[operation.request URL]]) {
                if (responseObject) {
                    strongSelf.image = responseObject;
                }
                if (success) {
                    success(urlRequest, operation.response, responseObject);
                }
            }
            [[EZImageCache sharedEZImageCache] storeImage:responseObject key:[urlRequest.URL absoluteString]];
            //[[[strongSelf class] sharedImageCache] cacheImage:responseObject forRequest:urlRequest];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if ([[urlRequest URL] isEqual:[operation.request URL]]) {
                if (failure) {
                    failure(urlRequest, operation.response, error);
                }
            }
        }];

        [[[self class] af_sharedImageRequestOperationQueue] addOperation:self.af_imageRequestOperation];
    }
}

- (void)cancelImageRequestOperation {
    [self.af_imageRequestOperation cancel];
    self.af_imageRequestOperation = nil;
}

@end

#pragma mark -

static inline NSString * AFImageCacheKeyFromURLRequest(NSURLRequest *request) {
    return [[request URL] absoluteString];
}

@implementation AFImageCache

- (UIImage *)cachedImageForRequest:(NSURLRequest *)request {
    switch ([request cachePolicy]) {
        case NSURLRequestReloadIgnoringCacheData:
        case NSURLRequestReloadIgnoringLocalAndRemoteCacheData:
            return nil;
        default:
            break;
    }

	return [self objectForKey:AFImageCacheKeyFromURLRequest(request)];
}

- (void)cacheImage:(UIImage *)image
        forRequest:(NSURLRequest *)request
{
    if (image && request) {
        [self setObject:image forKey:AFImageCacheKeyFromURLRequest(request)];
    }
}

@end

#endif
