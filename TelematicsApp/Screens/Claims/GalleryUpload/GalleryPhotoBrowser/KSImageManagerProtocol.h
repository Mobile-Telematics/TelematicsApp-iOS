//
//  KSWebImageProtocol.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 28.06.21.
//  Copyright © 2019-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^KSImageManagerProgressBlock)(NSInteger receivedSize, NSInteger expectedSize);

typedef void (^KSImageManagerCompletionBlock)(UIImage * _Nullable image, NSURL * _Nullable url, BOOL success, NSError * _Nullable error);

@protocol KSImageManager

+ (Class _Nonnull)imageViewClass;

+ (void)setImageForImageView:(nullable UIImageView *)imageView
                     withURL:(nullable NSURL *)imageURL
                 placeholder:(nullable UIImage *)placeholder
                    progress:(nullable KSImageManagerProgressBlock)progress
                  completion:(nullable KSImageManagerCompletionBlock)completion;

+ (void)cancelImageRequestForImageView:(nullable UIImageView *)imageView;

+ (UIImage *_Nullable)imageFromMemoryForURL:(nullable NSURL *)url;

+ (UIImage *_Nullable)imageForURL:(nullable NSURL *)url;

@end
