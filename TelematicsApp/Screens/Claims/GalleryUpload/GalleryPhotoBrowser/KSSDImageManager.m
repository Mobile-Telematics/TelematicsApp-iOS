//
//  KSSDWebImage.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 28.06.21.
//  Copyright © 2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "KSSDImageManager.h"

#if __has_include(<SDWebImage/SDImageCache.h>)
#import <SDWebImage/UIImageView+WebCache.h>
#import <SDWebImage/UIView+WebCache.h>
#import <SDWebImage/SDWebImageDownloader.h>
#import <SDWebImage/SDImageCache.h>
#import <SDWebImage/SDAnimatedImageView.h>
#else
#import "UIImageView+WebCache.h"
#import "UIView+WebCache.h"
#import "SDWebImageDownloader.h"
#import "SDImageCache.h"
#import "SDAnimatedImageView.h"
#endif

@implementation KSSDImageManager

+ (Class)imageViewClass {
    return SDAnimatedImageView.class;
}

+ (void)setImageForImageView:(UIImageView *)imageView
                     withURL:(NSURL *)imageURL
                 placeholder:(UIImage *)placeholder
                    progress:(KSImageManagerProgressBlock)progress
                  completion:(KSImageManagerCompletionBlock)completion
{
    SDWebImageDownloaderProgressBlock progressBlock = ^(NSInteger receivedSize, NSInteger expectedSize, NSURL *targetURL) {
        if (progress) {
            progress(receivedSize, expectedSize);
        }
    };
    SDExternalCompletionBlock completionBlock = ^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (completion) {
            completion(image, imageURL, !error, error);
        }
    };
    [imageView sd_setImageWithURL:imageURL placeholderImage:placeholder options:SDWebImageRetryFailed progress:progressBlock completed:completionBlock];
}

+ (void)cancelImageRequestForImageView:(UIImageView *)imageView {
    [imageView sd_cancelCurrentImageLoad];
}

+ (UIImage *)imageFromMemoryForURL:(NSURL *)url {
    NSString *key = [SDWebImageManager.sharedManager cacheKeyForURL:url];
    return [SDImageCache.sharedImageCache imageFromMemoryCacheForKey:key];
}

+ (UIImage *)imageForURL:(NSURL *)url {
    NSString *key = [SDWebImageManager.sharedManager cacheKeyForURL:url];
    return [SDImageCache.sharedImageCache imageFromCacheForKey:key];
}


@end
