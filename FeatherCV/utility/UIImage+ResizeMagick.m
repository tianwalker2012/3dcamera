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

//Mean don't change anything. just change the orienation flag. 
- (UIImage*) orientationAdjust:(UIImageOrientation)orientation
{
    return [[UIImage alloc] initWithCGImage:self.CGImage scale:self.scale orientation:orientation];
}

static inline CGSize swapWidthAndHeight(CGSize size)
{
    CGFloat  swap = size.width;
    
    size.width  = size.height;
    size.height = swap;
    
    return size;
}


- (UIImage*) vImageScaledImage:(UIImage*) sourceImage withSize:(CGSize) destSize;
{
    UIImage *destImage = nil;
    
    if (sourceImage)
    {
        // First, convert the UIImage to an array of bytes, in the format expected by vImage.
        // Thanks: http://stackoverflow.com/a/1262893/1318452
        CGImageRef sourceRef = [sourceImage CGImage];
        NSUInteger sourceWidth = CGImageGetWidth(sourceRef);
        NSUInteger sourceHeight = CGImageGetHeight(sourceRef);
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        unsigned char *sourceData = (unsigned char*) calloc(sourceHeight * sourceWidth * 4, sizeof(unsigned char));
        NSUInteger bytesPerPixel = 4;
        NSUInteger sourceBytesPerRow = bytesPerPixel * sourceWidth;
        NSUInteger bitsPerComponent = 8;
        CGContextRef context = CGBitmapContextCreate(sourceData, sourceWidth, sourceHeight,
                                                     bitsPerComponent, sourceBytesPerRow, colorSpace,
                                                     kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Big);
        CGContextDrawImage(context, CGRectMake(0, 0, sourceWidth, sourceHeight), sourceRef);
        CGContextRelease(context);
        
        // We now have the source data.  Construct a pixel array
        NSUInteger destWidth = (NSUInteger) destSize.width;
        NSUInteger destHeight = (NSUInteger) destSize.height;
        NSUInteger destBytesPerRow = bytesPerPixel * destWidth;
        unsigned char *destData = (unsigned char*) calloc(destHeight * destWidth * 4, sizeof(unsigned char));
        
        // Now create vImage structures for the two pixel arrays.
        // Thanks: https://github.com/dhoerl/PhotoScrollerNetwork
        vImage_Buffer src = {
            .data = sourceData,
            .height = sourceHeight,
            .width = sourceWidth,
            .rowBytes = sourceBytesPerRow
        };
        
        vImage_Buffer dest = {
            .data = destData,
            .height = destHeight,
            .width = destWidth,
            .rowBytes = destBytesPerRow
        };
        
        // Carry out the scaling.
        vImage_Error err = vImageScale_ARGB8888 (
                                                 &src,
                                                 &dest,
                                                 NULL,
                                                 kvImageHighQualityResampling
                                                 );
        
        // The source bytes are no longer needed.
        free(sourceData);
        
        // Convert the destination bytes to a UIImage.
        CGContextRef destContext = CGBitmapContextCreate(destData, destWidth, destHeight,
                                                         bitsPerComponent, destBytesPerRow, colorSpace,
                                                         kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Big);
        CGImageRef destRef = CGBitmapContextCreateImage(destContext);
        
        // Store the result.
        destImage = [UIImage imageWithCGImage:destRef];
        
        // Free up the remaining memory.
        CGImageRelease(destRef);
        
        CGColorSpaceRelease(colorSpace);
        CGContextRelease(destContext);
        
        // The destination bytes are no longer needed.
        free(destData);
        
        if (err != kvImageNoError)
        {
            NSString *errorReason = [NSString stringWithFormat:@"vImageScale returned error code %d", err];
            NSDictionary *errorInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                       sourceImage, @"sourceImage",
                                       [NSValue valueWithCGSize:destSize], @"destSize",
                                       nil];
            
            NSException *exception = [NSException exceptionWithName:@"HighQualityImageScalingFailureException" reason:errorReason userInfo:errorInfo];
            
            @throw exception;
        }
    }
    return destImage;
}

- (UIImage *)imageWithTint:(UIColor *)tintColor
{
    // Begin drawing
    CGRect aRect = CGRectMake(0.f, 0.f, self.size.width, self.size.height);
    CGImageRef alphaMask;
    
    //
    // Compute mask flipping image
    //
    {
        UIGraphicsBeginImageContext(aRect.size);
        CGContextRef c = UIGraphicsGetCurrentContext();
        
        // draw image
        CGContextTranslateCTM(c, 0, aRect.size.height);
        CGContextScaleCTM(c, 1.0, -1.0);
        [self drawInRect: aRect];
        
        alphaMask = CGBitmapContextCreateImage(c);
        
        UIGraphicsEndImageContext();
    }
    
    //
    UIGraphicsBeginImageContext(aRect.size);
    
    // Get the graphic context
    CGContextRef c = UIGraphicsGetCurrentContext();
    
    // Draw the image
    [self drawInRect:aRect];
    
    // Mask
    CGContextClipToMask(c, aRect, alphaMask);
    
    // Set the fill color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextSetFillColorSpace(c, colorSpace);
    
    // Set the fill color
    CGContextSetFillColorWithColor(c, tintColor.CGColor);
    
    UIRectFillUsingBlendMode(aRect, kCGBlendModeNormal);
    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // Release memory
    CGColorSpaceRelease(colorSpace);
    CGImageRelease(alphaMask);
    
    return img;
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
    UIImage* flippedImage = [self rotateByOrientation:flippingOrientation];
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

+ (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0, 0, 1, 1);
    
    // create a 1 by 1 pixel context
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    [color setFill];
    UIRectFill(rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (UIImage *) resizedImageWithMinimumSize: (CGSize) size
{
    return [self resizedImageWithMinimumSize:size antialias:YES];
}

- (UIImage *) resizedImageWithMinimumSize: (CGSize) size antialias:(BOOL)antialias
{
    CGImageRef imgRef = [self CGImageWithCorrectOrientation];
    CGFloat original_width  = CGImageGetWidth(imgRef);
    CGFloat original_height = CGImageGetHeight(imgRef);
    CGFloat width_ratio = size.width / original_width;
    CGFloat height_ratio = size.height / original_height;
    CGFloat scale_ratio = width_ratio > height_ratio ? width_ratio : height_ratio;
    CGImageRelease(imgRef);
    return [self drawImageInBounds: CGRectMake(0, 0, round(original_width * scale_ratio), round(original_height * scale_ratio)) antialias:antialias];
}

- (UIImage *) resizedImageWithMaximumSize: (CGSize) size
{
    return [self resizedImageWithMaximumSize:size antialias:YES];
}

- (UIImage *) resizedImageWithMaximumSize: (CGSize) size antialias:(BOOL)antialias
{
    CGImageRef imgRef = [self CGImageWithCorrectOrientation];
    CGFloat original_width  = CGImageGetWidth(imgRef);
    CGFloat original_height = CGImageGetHeight(imgRef);
    CGFloat width_ratio = size.width / original_width;
    CGFloat height_ratio = size.height / original_height;
    CGFloat scale_ratio = width_ratio < height_ratio ? width_ratio : height_ratio;
    CGImageRelease(imgRef);
    return [self drawImageInBounds: CGRectMake(0, 0, round(original_width * scale_ratio), round(original_height * scale_ratio)) antialias:antialias];
}

- (UIImage *) drawImageInBounds: (CGRect) bounds
{
    return [self drawImageInBounds:bounds antialias:YES];
}

- (UIImage *) drawImageInBounds: (CGRect) bounds antialias:(BOOL)antialias
{
    UIGraphicsBeginImageContext(bounds.size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(ctx, kCGInterpolationHigh);
    CGContextSetShouldAntialias(ctx, antialias); //<< default varies by context type
    [self drawInRect: bounds];
    //UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIImage *resizedImage = [UIImage imageWithCGImage:UIGraphicsGetImageFromCurrentImageContext().CGImage scale:self.scale orientation:self.imageOrientation];
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

- (UIImage *)imageCroppedWithRect:(CGRect)rect
{
    if (self.scale > 1.0f) {    // this is for Retina display capability
        rect = CGRectMake(rect.origin.x * self.scale,
                          rect.origin.y * self.scale,
                          rect.size.width * self.scale,
                          rect.size.height * self.scale);
    }
    
    CGImageRef imageRef = CGImageCreateWithImageInRect(self.CGImage, rect);
    UIImage *result = [UIImage imageWithCGImage:imageRef scale:self.scale orientation:self.imageOrientation];
    CGImageRelease(imageRef);
    return result;
}


- (UIImage *) changeOrientionNew:(UIImageOrientation)orientation
{
    CGImageRef imgRef = [self CGImageWithCorrectOrientation];
    UIImage *result = [UIImage imageWithCGImage:imgRef scale:self.scale orientation:orientation];
    CGImageRelease(imgRef);
    return result;
}

- (UIImage *) changeOriention:(UIImageOrientation)orientation
{
    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.width);
    if (self.scale > 1.0f) {    // this is for Retina display capability
        rect = CGRectMake(rect.origin.x * self.scale,
                          rect.origin.y * self.scale,
                          rect.size.width * self.scale,
                          rect.size.height * self.scale);
    }
    
    CGImageRef imageRef = CGImageCreateWithImageInRect(self.CGImage, rect);
    UIImage *result = [UIImage imageWithCGImage:imageRef scale:self.scale orientation:orientation];
    CGImageRelease(imageRef);
    return result;
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




@end
