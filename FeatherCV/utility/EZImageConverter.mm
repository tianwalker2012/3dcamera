//
//  EZImageConverter.m
//  OpenCVTinkering
//
//  Created by xietian on 13-11-18.
//  Copyright (c) 2013年 tiange. All rights reserved.
//

#import "EZImageConverter.h"
#import <opencv2/imgproc/imgproc.hpp>

@implementation EZImageConverter


/**
 enum
 {
 GC_BGD    = 0,  //!< background
 GC_FGD    = 1,  //!< foreground
 GC_PR_BGD = 2,  //!< most probably background
 GC_PR_FGD = 3   //!< most probably foreground
 };

 **/

+ (UIImage*) matMaskToImage:(cv::Mat&)mat
{
    cv::Mat fullMat(mat.rows,mat.cols, CV_8UC4);
    for(int i = 0; i < mat.rows; i ++){
        for(int j = 0; j < mat.cols; j ++){
            uchar maskType = mat.at<uchar>(i, j);
            
            if(maskType == cv::GC_BGD){
                fullMat.at<cv::Vec4b>(i, j) = BackSureColorCV;
            }else if(maskType == cv::GC_PR_BGD){
                fullMat.at<cv::Vec4b>(i, j) = BackProbableColorCV;
            }else if(maskType == cv::GC_FGD){
                fullMat.at<cv::Vec4b>(i, j) = FrontSureColorCV;
            }else if(maskType == cv::GC_PR_FGD){
                fullMat.at<cv::Vec4b>(i, j) = FrontProbableColorCV;
            }
        }
    }
    CGColorSpaceRef colorSpace;
    //cv::Mat fullMat;
    //cv::cvtColor(cvMat, fullMat, CV_BGR2BGRA);
    NSData *data = [NSData dataWithBytes:fullMat.data length:fullMat.elemSize()*fullMat.total()];
    colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData( (__bridge CFDataRef)data );
    CGImageRef imageRef = CGImageCreate(fullMat.cols, fullMat.rows, 8, 8 * fullMat.elemSize(), fullMat.step[0], colorSpace, kCGImageAlphaNone|kCGBitmapByteOrderDefault, provider, NULL, false, kCGRenderingIntentDefault );
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease( imageRef );
    CGDataProviderRelease( provider );
    CGColorSpaceRelease( colorSpace );
    return finalImage;
}

+ (void) imageMaskToMat:(cv::Mat&)outMat image:(UIImage*)image
{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace( image.CGImage );
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    cv::Mat cvMat( rows, cols, CV_8UC4);
    CGContextRef contextRef = CGBitmapContextCreate( cvMat.data, cols, rows, 8, cvMat.step[0], colorSpace, kCGImageAlphaLast | kCGBitmapByteOrderDefault );
    CGContextDrawImage( contextRef, CGRectMake(0, 0, cols, rows), image.CGImage );
    CGContextRelease( contextRef );
    CGColorSpaceRelease( colorSpace );
    
    //cv::Mat outMat(rows, cols, CV_8UC1);
    //cv::cvtColor(cvMat, outMat, CV_BGRA2BGR);
    for(int i = 0; i < cvMat.rows; i ++){
        for(int j = 0; j < cvMat.cols; j ++){
            cv::Vec4b fullColor = cvMat.at<cv::Vec4b>(i, j);
            if(EqualMatColor(fullColor, BackSureColorCV)){
                //fullMat.at<cv::Vec3b>(i, j) = BackSureColorCV;
                outMat.at<uchar>(i, j) = cv::GC_BGD;
            }else if(EqualMatColor(fullColor, BackProbableColorCV)){
                outMat.at<uchar>(i, j) = cv::GC_PR_BGD;
            }else if(EqualMatColor(fullColor, FrontSureColorCV)){
                outMat.at<uchar>(i, j) = cv::GC_FGD;
            }else if(EqualMatColor(fullColor, FrontProbableColorCV)){
                outMat.at<uchar>(i, j) = cv::GC_PR_FGD;
            }
        }
    }
}



+ (UIImage *)matToImage2:(cv::Mat)cvMat withUIImage:(UIImage*)image;
{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace( image.CGImage );
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    CGFloat widthStep = image.size.width;
    CGContextRef contextRef = CGBitmapContextCreate( NULL, cols, rows, 8, widthStep*4, colorSpace, kCGImageAlphaNoneSkipLast | kCGBitmapByteOrderDefault );
    CGContextDrawImage( contextRef, CGRectMake(0, 0, cols, rows), image.CGImage );
    CGContextSetRGBStrokeColor( contextRef, 1, 0, 0, 1 );
    CGImageRef cgImage = CGBitmapContextCreateImage( contextRef );
    UIImage* result = [UIImage imageWithCGImage:cgImage];
    CGImageRelease( cgImage );
    CGContextRelease( contextRef );
    CGColorSpaceRelease( colorSpace );
    return result;
}

+(UIImage *)matToImage:(cv::Mat)cvMat
{
    CGColorSpaceRef colorSpace;
    //cv::Mat fullMat;
    //cv::cvtColor(cvMat, fullMat, CV_BGR2BGRA);
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize()*cvMat.total()];
    colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData( (__bridge CFDataRef)data );
    CGImageRef imageRef = CGImageCreate(cvMat.cols, cvMat.rows, 8, 8 * cvMat.elemSize(), cvMat.step[0], colorSpace, kCGImageAlphaLast|kCGBitmapByteOrderDefault, provider, NULL, false, kCGRenderingIntentDefault );
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease( imageRef );
    CGDataProviderRelease( provider );
    CGColorSpaceRelease( colorSpace );
    return finalImage;
}


+(UIImage *)matToImageEx:(cv::Mat)image
{
    NSData *data = [NSData dataWithBytes:image.data
                                  length:image.elemSize()*image.total()];
    
    CGColorSpaceRef colorSpace;
    
    if (image.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    
    CGDataProviderRef provider =
    CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    // Creating CGImage from cv::Mat
    CGImageRef imageRef = CGImageCreate(image.cols,
                                        image.rows,
                                        8,
                                        8 * image.elemSize(),
                                        image.step.p[0],
                                        colorSpace,
                                        kCGImageAlphaLast|
                                        kCGBitmapByteOrderDefault,
                                        provider,
                                        NULL,
                                        false,
                                        kCGRenderingIntentDefault
                                        );
    
    
    // Getting UIImage from CGImage
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return finalImage;
}

+ (cv::Mat)cvMatFromUIImage:(UIImage *)image
{
    return [self cvMatFromUIImage:image type:CV_8UC4];
}

+ (cv::Mat)cvMatFromUIImage:(UIImage *)image type:(int)type
{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace( image.CGImage );
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    cv::Mat cvMat( rows, cols, type);
    CGContextRef contextRef = CGBitmapContextCreate( cvMat.data, cols, rows, 8, cvMat.step[0], colorSpace, kCGImageAlphaNoneSkipLast | kCGBitmapByteOrderDefault );
    CGContextDrawImage( contextRef, CGRectMake(0, 0, cols, rows), image.CGImage );
    CGContextRelease( contextRef );
    CGColorSpaceRelease( colorSpace );
    
    cv::Mat outMat(rows, cols, CV_8UC3);
    cv::cvtColor(cvMat, outMat, CV_BGRA2BGR);
    return outMat;
}

+ (cv::Mat)cvMatGrayFromUIImage:(UIImage *)image
{
    cv::Mat cvMat = [EZImageConverter cvMatFromUIImage:image];
    cv::Mat grayMat;
    if ( cvMat.channels() == 1 ) {
        grayMat = cvMat;
    }
    else {
        grayMat = cv :: Mat( cvMat.rows,cvMat.cols, CV_8UC1 );
        cv::cvtColor( cvMat, grayMat, CV_BGR2GRAY );
    }
    return grayMat;
}

+ (UIImage *)scaleAndRotateImageBackCamera:(UIImage *)image
{
    static int kMaxResolution = 640;
    CGImageRef imgRef = image.CGImage;
    CGFloat width = CGImageGetWidth( imgRef );
    CGFloat height = CGImageGetHeight( imgRef );
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake( 0, 0, width, height );
    if ( width > kMaxResolution || height > kMaxResolution ) {
        CGFloat ratio = width/height;
        if ( ratio > 1 ) {
            bounds.size.width = kMaxResolution;
            bounds.size.height = bounds.size.width / ratio;
        }
        else {
            bounds.size.height = kMaxResolution;
            bounds.size.width = bounds.size.height * ratio;
        }
    }
    CGFloat scaleRatio = bounds.size.width / width;
    CGSize imageSize = CGSizeMake( CGImageGetWidth(imgRef), CGImageGetHeight(imgRef) );
    CGFloat boundHeight;
    UIImageOrientation orient = image.imageOrientation;
    switch( orient ) {
        case UIImageOrientationUp:
            transform = CGAffineTransformIdentity;
            break;
        case UIImageOrientationUpMirrored:
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
        case UIImageOrientationDown:
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
        case UIImageOrientationLeftMirrored:
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
        case UIImageOrientationLeft:
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
        case UIImageOrientationRightMirrored:
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
        case UIImageOrientationRight:
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
    }
    UIGraphicsBeginImageContext( bounds.size );
    CGContextRef context = UIGraphicsGetCurrentContext();
    if ( orient == UIImageOrientationRight || orient == UIImageOrientationLeft ) {
        CGContextScaleCTM( context, -scaleRatio, scaleRatio );
        CGContextTranslateCTM( context, -height, 0 );
    }
    else {
        CGContextScaleCTM( context, scaleRatio, -scaleRatio );
        CGContextTranslateCTM( context, 0, -height );
    }
    CGContextConcatCTM( context, transform );
    CGContextDrawImage( UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef );
    UIImage *returnImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return returnImage;
}

+ (UIImage *)scaleAndRotateImageFrontCamera:(UIImage *)image
{
    static int kMaxResolution = 640;
    CGImageRef imgRef = image.CGImage;
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake( 0, 0, width, height);
    if (width > kMaxResolution || height > kMaxResolution) {
        CGFloat ratio = width/height;
        if (ratio > 1) {
            bounds.size.width = kMaxResolution;
            bounds.size.height = bounds.size.width / ratio;
        } else {
            bounds.size.height = kMaxResolution;
            bounds.size.width = bounds.size.height * ratio;
        }
    }
    
    CGFloat scaleRatio = bounds.size.width / width;
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
    CGFloat boundHeight;
    UIImageOrientation orient = image.imageOrientation;
    switch(orient) {
        case UIImageOrientationUp:
            transform = CGAffineTransformIdentity;
            break;
        case UIImageOrientationUpMirrored:
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
        case UIImageOrientationDown:
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
        case UIImageOrientationLeftMirrored:
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
        case UIImageOrientationLeft:
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
    }
    UIGraphicsBeginImageContext( bounds.size );
    CGContextRef context = UIGraphicsGetCurrentContext();
    if ( orient == UIImageOrientationRight || orient == UIImageOrientationLeft ) {
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(context, -height, 0);
    }
    else {
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0, -height);
    }
    CGContextConcatCTM( context, transform );
    CGContextDrawImage( UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef );
    UIImage *returnImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return returnImage;
}

@end