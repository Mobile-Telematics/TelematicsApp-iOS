//
//  KSWebImage.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 28.06.21.
//  Copyright © 2019-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "KSYYImageManager.h"

#if __has_include(<YYWebImage/YYWebImage.h>)
#import <YYWebImage/YYWebImage.h>
#else
#import "YYWebImage.h"
#endif

@implementation KSYYImageManager

+ (Class)imageViewClass {
    return YYAnimatedImageView.class;
}

+ (void)setImageForImageView:(UIImageView *)imageView
                     withURL:(NSURL *)imageURL
                 placeholder:(UIImage *)placeholder
                    progress:(KSImageManagerProgressBlock)progress
                  completion:(KSImageManagerCompletionBlock)completion
{
    YYWebImageProgressBlock progressBlock = ^(NSInteger receivedSize, NSInteger expectedSize) {
        if (progress) {
            progress(receivedSize, expectedSize);
        }
    };
    YYWebImageCompletionBlock completionBlock = ^(UIImage *image,  NSURL *url, YYWebImageFromType from, YYWebImageStage stage, NSError *error) {
        if (completion) {
            BOOL success = (stage == YYWebImageStageFinished) && !error;
            completion(image, url, success, error);
        }
    };
    [imageView yy_setImageWithURL:imageURL placeholder:placeholder options:kNilOptions progress:progressBlock transform:nil completion:completionBlock];
}

+ (void)cancelImageRequestForImageView:(UIImageView *)imageView {
    [imageView yy_cancelCurrentImageRequest];
}

+ (UIImage *)imageFromMemoryForURL:(NSURL *)url {
    YYWebImageManager *manager = [YYWebImageManager sharedManager];
    NSString *key = [manager cacheKeyForURL:url];
    return [manager.cache getImageForKey:key withType:YYImageCacheTypeMemory];
}

+ (UIImage *)imageForURL:(NSURL *)url {
    YYWebImageManager *manager = [YYWebImageManager sharedManager];
    NSString *key = [manager cacheKeyForURL:url];
    return [manager.cache getImageForKey:key];
}

@end
