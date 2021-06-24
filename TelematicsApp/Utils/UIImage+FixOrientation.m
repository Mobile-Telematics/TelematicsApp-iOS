//
//  UIImage+FixOrientation.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 09.01.18.
//  Copyright © 2019-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "UIImage+FixOrientation.h"

@implementation UIImage (FixOrientation)

- (UIImage *)fixOrientation
{
    if (self.imageOrientation == UIImageOrientationUp) return self;
    
    CGAffineTransform transform = CGAffineTransformIdentity;

    switch (self.imageOrientation)
    {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, self.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
            
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }

    switch (self.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    CGContextRef ctx = CGBitmapContextCreate(NULL, self.size.width, self.size.height,
                                             CGImageGetBitsPerComponent(self.CGImage), 0,
                                             CGImageGetColorSpace(self.CGImage),
                                             CGImageGetBitmapInfo(self.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (self.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.height,self.size.width), self.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.width,self.size.height), self.CGImage);
            break;
    }

    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}


#pragma mark - ImageConvert

+ (UIImage *)imageWithImageHelper:(UIImage *)image scale:(CGFloat)scale {
    CGSize newSize = CGSizeMake(image.size.width*scale, image.size.height*scale);
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}


#pragma mark - Scale Image 1 Mb

+ (NSData *)scaleImage:(UIImage*)image {
    NSData *imageData;
    if (image != nil) {
        
        float compressionVal = 1.0;
        float maxVal = 1.0; //MB
        UIImage *compressedImage = image;
        int iterations = 0;
        int totalIterations = 0;
        float initialCompressionVal = 0.00000000f;
        
        while (((((float)(UIImageJPEGRepresentation(compressedImage, compressionVal).length))/(1048576.000000000f)) > maxVal) && (totalIterations < 1024)) {
            
            NSLog(@"Image is %f MB", (float)(((float)(UIImageJPEGRepresentation(compressedImage, compressionVal)).length)/(1048576.000000f)));
            
            compressionVal = (((compressionVal)+((compressionVal)*((float)(((float)maxVal)/((float)(((float)(UIImageJPEGRepresentation(compressedImage, compressionVal).length))/(1048576.000000000f)))))))/(2));
            compressionVal *= 0.97;
            
            if (initialCompressionVal == 0.00000000f) {
                initialCompressionVal = compressionVal;
            }
            
            iterations ++;
            
            if ((iterations >= 3) || (compressionVal < 0.1)) {
                iterations = 0;
                NSLog(@"%f", compressionVal);
                
                compressionVal = 1.0f;
                compressedImage = [UIImage imageWithData:UIImageJPEGRepresentation(compressedImage, compressionVal)];
                
                float resizeAmount = 1.0f;
                resizeAmount = (resizeAmount+initialCompressionVal)/(2);
                resizeAmount *= 0.97;
                resizeAmount = 1/(resizeAmount);
                initialCompressionVal = 0.00000000f;
                
                UIView *imageHolder = [[UIView alloc] initWithFrame:CGRectMake(0,0,(int)floorf((float)(compressedImage.size.width/(resizeAmount))), (int)floorf((float)(compressedImage.size.height/(resizeAmount))))];
                
                UIImageView *theResizedImage = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,(int)ceilf((float)(compressedImage.size.width/(resizeAmount))), (int)ceilf((float)(compressedImage.size.height/(resizeAmount))))];
                theResizedImage.image = compressedImage;
                [imageHolder addSubview:theResizedImage];
                
                UIGraphicsBeginImageContextWithOptions(CGSizeMake(imageHolder.frame.size.width, imageHolder.frame.size.height), YES, 1.0f);
                CGContextRef resize_context = UIGraphicsGetCurrentContext();
                [imageHolder.layer renderInContext:resize_context];
                compressedImage = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
            }
            totalIterations ++;
        }
        
        if (totalIterations >= 1024) {
            NSLog(@"Image was too big");
        } else {
            imageData = UIImageJPEGRepresentation(compressedImage, compressionVal);
            NSLog(@"FINAL Image is %f MB iterations: %i", (float)(((float)imageData.length)/(1048576.000000f)), totalIterations);
        }
    }
    return imageData;
}


#pragma mark - Scale Image 0.4 Mb

+ (NSData *)scaleImageForAvatar:(UIImage*)image {
    
    NSData *imageData;
    if (image != nil) {
        
        float compressionVal = 1.0;
        float maxVal = 0.3; //MB
        UIImage *compressedImage = image;
        int iterations = 0;
        int totalIterations = 0;
        float initialCompressionVal = 0.00000000f;
        
        while (((((float)(UIImageJPEGRepresentation(compressedImage, compressionVal).length))/(1048576.000000000f)) > maxVal) && (totalIterations < 1024)) {
            
            NSLog(@"Image is %f MB", (float)(((float)(UIImageJPEGRepresentation(compressedImage, compressionVal)).length)/(1048576.000000f)));
            
            compressionVal = (((compressionVal)+((compressionVal)*((float)(((float)maxVal)/((float)(((float)(UIImageJPEGRepresentation(compressedImage, compressionVal).length))/(1048576.000000000f)))))))/(2));
            compressionVal *= 0.97;
            
            if (initialCompressionVal == 0.00000000f) {
                initialCompressionVal = compressionVal;
            }
            
            iterations ++;
            
            if ((iterations >= 3) || (compressionVal < 0.1)) {
                iterations = 0;
                NSLog(@"%f", compressionVal);
                
                compressionVal = 1.0f;
                compressedImage = [UIImage imageWithData:UIImageJPEGRepresentation(compressedImage, compressionVal)];
                
                float resizeAmount = 1.0f;
                resizeAmount = (resizeAmount+initialCompressionVal)/(2);
                resizeAmount *= 0.97;
                resizeAmount = 1/(resizeAmount);
                initialCompressionVal = 0.00000000f;
                
                UIView *imageHolder = [[UIView alloc] initWithFrame:CGRectMake(0,0,(int)floorf((float)(compressedImage.size.width/(resizeAmount))), (int)floorf((float)(compressedImage.size.height/(resizeAmount))))];
                
                UIImageView *theResizedImage = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,(int)ceilf((float)(compressedImage.size.width/(resizeAmount))), (int)ceilf((float)(compressedImage.size.height/(resizeAmount))))];
                theResizedImage.image = compressedImage;
                [imageHolder addSubview:theResizedImage];
                
                UIGraphicsBeginImageContextWithOptions(CGSizeMake(imageHolder.frame.size.width, imageHolder.frame.size.height), YES, 1.0f);
                CGContextRef resize_context = UIGraphicsGetCurrentContext();
                [imageHolder.layer renderInContext:resize_context];
                compressedImage = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                NSLog(@"resize");
            }
            totalIterations ++;
        }
        
        if (totalIterations >= 1024) {
            NSLog(@"Image was too big, gave up on trying to re-size");
        } else {
            imageData = UIImageJPEGRepresentation(compressedImage, compressionVal);
            NSLog(@"FINAL Image is %f MB... iterations: %i", (float)(((float)imageData.length)/(1048576.000000f)), totalIterations);
        }
    }
    return imageData;
}


@end
