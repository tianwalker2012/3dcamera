//
//  UIImage+ResizeMagick.m
//
//
//  Created by Vlad Andersen on 1/5/13.
//
//

#import "UIImage+ResizeMagick.h"

@implementation UIImage (ResizeMagick)

// width	Width given, height automagically selected to preserve aspect ratio.
// xheight	Height given, width automagically selected to preserve aspect ratio.
// widthxheight	Maximum values of height and width given, aspect ratio preserved.
// widthxheight^	Minimum values of width and height given, aspect ratio preserved.
// widthxheight!	Exact dimensions, no aspect ratio preserved.
// widthxheight#	Crop to this exact dimensions.
static inline CGFloat degreesToRadians(CGFloat degrees)
{
    return M_PI * (degrees / 180.0);
}

static inline CGSize swapWidthAndHeight(CGSize size)
{
    CGFloat  swap = size.width;
    
    size.width  = size.height;
    size.height = swap;
    
    return size;
}



- (UIImage *) flipImage
{
    //UIImage* sourceImage = [UIImage imageNamed:@"whatever.png"];
   
    UIImageOrientation flippingOrientation;
    if(self.imageOrientation>=4){
        flippingOrientation = self.imageOrientation - 4;
    }else{
        flippingOrientation = self.imageOrientation + 4;
    }
    UIImage* flippedImage = [self rotate:flippingOrientation];
    EZDEBUG(@"Flip image as:%i, flippingOrientation:%i", self.imageOrientation, flippingOrientation);
    return flippedImage;
}

- (UIImage *) resizedImageByMagick: (NSString *) spec
{

    if([spec hasSuffix:@"!"]) {
        NSString *specWithoutSuffix = [spec substringToIndex: [spec length] - 1];
        NSArray *widthAndHeight = [specWithoutSuffix componentsSeparatedByString: @"x"];
        NSUInteger width = [[widthAndHeight objectAtIndex: 0] longLongValue];
        NSUInteger height = [[widthAndHeight objectAtIndex: 1] longLongValue];
        UIImage *newImage = [self resizedImageWithMinimumSize: CGSizeMake (width, height)];
        return [newImage drawImageInBounds: CGRectMake (0, 0, width, height)];
    }

    if([spec hasSuffix:@"#"]) {
        NSString *specWithoutSuffix = [spec substringToIndex: [spec length] - 1];
        NSArray *widthAndHeight = [specWithoutSuffix componentsSeparatedByString: @"x"];
        NSUInteger width = [[widthAndHeight objectAtIndex: 0] longLongValue];
        NSUInteger height = [[widthAndHeight objectAtIndex: 1] longLongValue];
        UIImage *newImage = [self resizedImageWithMinimumSize: CGSizeMake (width, height)];
        return [newImage croppedImageWithRect: CGRectMake ((newImage.size.width - width) / 2, (newImage.size.height - height) / 2, width, height)];
    }

    if([spec hasSuffix:@"^"]) {
        NSString *specWithoutSuffix = [spec substringToIndex: [spec length] - 1];
        NSArray *widthAndHeight = [specWithoutSuffix componentsSeparatedByString: @"x"];
        return [self resizedImageWithMinimumSize: CGSizeMake ([[widthAndHeight objectAtIndex: 0] longLongValue],
                                                              [[widthAndHeight objectAtIndex: 1] longLongValue])];
    }

    NSArray *widthAndHeight = [spec componentsSeparatedByString: @"x"];
    if ([widthAndHeight count] == 1) {
        return [self resizedImageByWidth: [spec longLongValue]];
    }
    if ([[widthAndHeight objectAtIndex: 0] isEqualToString: @""]) {
        return [self resizedImageByHeight: [[widthAndHeight objectAtIndex: 1] longLongValue]];
    }
    return [self resizedImageWithMaximumSize: CGSizeMake ([[widthAndHeight objectAtIndex: 0] longLongValue],
                                                          [[widthAndHeight objectAtIndex: 1] longLongValue])];
}

- (CGImageRef) CGImageWithCorrectOrientation
{
    if (self.imageOrientation == UIImageOrientationDown) {
        //retaining because caller expects to own the reference
        CGImageRetain([self CGImage]);
        return [self CGImage];
    }
    UIGraphicsBeginImageContext(self.size);

    CGContextRef context = UIGraphicsGetCurrentContext();

    if (self.imageOrientation == UIImageOrientationRight) {
        CGContextRotateCTM (context, 90 * M_PI/180);
    } else if (self.imageOrientation == UIImageOrientationLeft) {
        CGContextRotateCTM (context, -90 * M_PI/180);
    } else if (self.imageOrientation == UIImageOrientationUp) {
        CGContextRotateCTM (context, 180 * M_PI/180);
    }

    [self drawAtPoint:CGPointMake(0, 0)];

    CGImageRef cgImage = CGBitmapContextCreateImage(context);
    UIGraphicsEndImageContext();

    return cgImage;
}


- (UIImage *) resizedImageByWidth:  (NSUInteger) width
{
    CGImageRef imgRef = [self CGImageWithCorrectOrientation];
    CGFloat original_width  = CGImageGetWidth(imgRef);
    CGFloat original_height = CGImageGetHeight(imgRef);
    CGFloat ratio = width/original_width;
    CGImageRelease(imgRef);
    return [self drawImageInBounds: CGRectMake(0, 0, width, round(original_height * ratio))];
}

- (UIImage *) resizedImageByHeight:  (NSUInteger) height
{
    CGImageRef imgRef = [self CGImageWithCorrectOrientation];
    CGFloat original_width  = CGImageGetWidth(imgRef);
    CGFloat original_height = CGImageGetHeight(imgRef);
    CGFloat ratio = height/original_height;
    CGImageRelease(imgRef);
    return [self drawImageInBounds: CGRectMake(0, 0, round(original_width * ratio), height)];
}


- (UIImage *) resizedImageWithMinimumSize: (CGSize) size
{
    CGImageRef imgRef = [self CGImageWithCorrectOrientation];
    CGFloat original_width  = CGImageGetWidth(imgRef);
    CGFloat original_height = CGImageGetHeight(imgRef);
    CGFloat width_ratio = size.width / original_width;
    CGFloat height_ratio = size.height / original_height;
    CGFloat scale_ratio = width_ratio > height_ratio ? width_ratio : height_ratio;
    CGImageRelease(imgRef);
    return [self drawImageInBounds: CGRectMake(0, 0, round(original_width * scale_ratio), round(original_height * scale_ratio))];
}

- (UIImage *) resizedImageWithMaximumSize: (CGSize) size
{
    CGImageRef imgRef = [self CGImageWithCorrectOrientation];
    CGFloat original_width  = CGImageGetWidth(imgRef);
    CGFloat original_height = CGImageGetHeight(imgRef);
    CGFloat width_ratio = size.width / original_width;
    CGFloat height_ratio = size.height / original_height;
    CGFloat scale_ratio = width_ratio < height_ratio ? width_ratio : height_ratio;
    CGImageRelease(imgRef);
    return [self drawImageInBounds: CGRectMake(0, 0, round(original_width * scale_ratio), round(original_height * scale_ratio))];
}

- (UIImage *) drawImageInBounds: (CGRect) bounds
{
    UIGraphicsBeginImageContext(bounds.size);
    [self drawInRect: bounds];
    UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resizedImage;
}

- (UIImage*) croppedImageWithRect: (CGRect) rect {

    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect drawRect = CGRectMake(-rect.origin.x, -rect.origin.y, self.size.width, self.size.height);
    CGContextClipToRect(context, CGRectMake(0, 0, rect.size.width, rect.size.height));
    [self drawInRect:drawRect];
    UIImage* subImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return subImage;
}

-(UIImage*) rotateByOrientation:(UIImageOrientation)orientation
{
    CGImageRef imgRef = self.CGImage;
    
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
    CGFloat boundHeight;
    UIImageOrientation orient = orientation;
    switch(orient) {
            
        case UIImageOrientationUp: //EXIF = 1
            return self;
            break;
            
        case UIImageOrientationUpMirrored: //EXIF = 2
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
            
        case UIImageOrientationDown: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationDownMirrored: //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
            
        case UIImageOrientationLeftMirrored: //EXIF = 5
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationLeft: //EXIF = 6
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationRightMirrored: //EXIF = 7
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        case UIImageOrientationRight: //EXIF = 8
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
            
    }
    // Create the bitmap context
    CGContextRef    context = NULL;
    void *          bitmapData;
    int             bitmapByteCount;
    int             bitmapBytesPerRow;
    
    // Declare the number of bytes per row. Each pixel in the bitmap in this
    // example is represented by 4 bytes; 8 bits each of red, green, blue, and
    // alpha.
    bitmapBytesPerRow   = (bounds.size.width * 4);
    bitmapByteCount     = (bitmapBytesPerRow * bounds.size.height);
    bitmapData = malloc( bitmapByteCount );
    if (bitmapData == NULL)
    {
        return nil;
    }
    
    // Create the bitmap context. We want pre-multiplied ARGB, 8-bits
    // per component. Regardless of what the source image format is
    // (CMYK, Grayscale, and so on) it will be converted over to the format
    // specified here by CGBitmapContextCreate.
    CGColorSpaceRef colorspace = CGImageGetColorSpace(imgRef);
    context = CGBitmapContextCreate (bitmapData,bounds.size.width,bounds.size.height,8,bitmapBytesPerRow,
                                     colorspace, kCGBitmapAlphaInfoMask & kCGImageAlphaPremultipliedLast);
    CGColorSpaceRelease(colorspace);
    
    if (context == NULL)
        // error creating context
        return nil;
    
    CGContextScaleCTM(context, -1.0, -1.0);
    CGContextTranslateCTM(context, -bounds.size.width, -bounds.size.height);
    
    CGContextConcatCTM(context, transform);
    
    // Draw the image to the bitmap context. Once we draw, the memory
    // allocated for the context for rendering will then contain the
    // raw image data in the specified color space.
    CGContextDrawImage(context, CGRectMake(0,0,width, height), imgRef);
    
    CGImageRef imgRef2 = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    free(bitmapData);
    UIImage * image = [UIImage imageWithCGImage:imgRef2 scale:self.scale orientation:UIImageOrientationUp];
    CGImageRelease(imgRef2);
    return image;
}


-(UIImage*)rotate:(UIImageOrientation)orient
{
    CGRect             bnds = CGRectZero;
    UIImage*           copy = nil;
    CGContextRef       ctxt = nil;
    CGRect             rect = CGRectZero;
    CGAffineTransform  tran = CGAffineTransformIdentity;
    
    bnds.size = self.size;
    rect.size = self.size;
    
    
    switch (orient)
    {
        case UIImageOrientationUp:
            return self;
            
        case UIImageOrientationUpMirrored:
            tran = CGAffineTransformMakeTranslation(rect.size.width, 0.0);
            tran = CGAffineTransformScale(tran, -1.0, 1.0);
            break;
            
        case UIImageOrientationDown:
            tran = CGAffineTransformMakeTranslation(rect.size.width,
                                                    rect.size.height);
            tran = CGAffineTransformRotate(tran, degreesToRadians(180.0));
            break;
            
        case UIImageOrientationDownMirrored:
            tran = CGAffineTransformMakeTranslation(0.0, rect.size.height);
            tran = CGAffineTransformScale(tran, 1.0, -1.0);
            break;
            
        case UIImageOrientationLeft:
            bnds.size = swapWidthAndHeight(bnds.size);
            tran = CGAffineTransformMakeTranslation(0.0, rect.size.width);
            tran = CGAffineTransformRotate(tran, degreesToRadians(-90.0));
            break;
            
        case UIImageOrientationLeftMirrored:
            bnds.size = swapWidthAndHeight(bnds.size);
            tran = CGAffineTransformMakeTranslation(rect.size.height,
                                                    rect.size.width);
            tran = CGAffineTransformScale(tran, -1.0, 1.0);
            tran = CGAffineTransformRotate(tran, degreesToRadians(-90.0));
            break;
            
        case UIImageOrientationRight:
            bnds.size = swapWidthAndHeight(bnds.size);
            tran = CGAffineTransformMakeTranslation(rect.size.height, 0.0);
            tran = CGAffineTransformRotate(tran, degreesToRadians(90.0));
            break;
            
        case UIImageOrientationRightMirrored:
            bnds.size = swapWidthAndHeight(bnds.size);
            tran = CGAffineTransformMakeScale(-1.0, 1.0);
            tran = CGAffineTransformRotate(tran, degreesToRadians(90.0));
            break;
            
        default:
            // orientation value supplied is invalid
            assert(false);
            return nil;
    }
    
    EZDEBUG(@"orientation:%i, origin:%@, changed:%@", self.imageOrientation, NSStringFromCGSize(self.size), NSStringFromCGSize(bnds.size));
    
    UIGraphicsBeginImageContext(bnds.size);
    ctxt = UIGraphicsGetCurrentContext();
    
    switch (orient)
    {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            CGContextScaleCTM(ctxt, -1.0, 1.0);
            CGContextTranslateCTM(ctxt, -rect.size.height, 0.0);
            break;
            
        default:
            CGContextScaleCTM(ctxt, 1.0, -1.0);
            CGContextTranslateCTM(ctxt, 0.0, -rect.size.height);
            break;
    }
    
    CGContextConcatCTM(ctxt, tran);
    CGContextDrawImage(ctxt, bnds, self.CGImage);
    copy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return copy;
}


@end
