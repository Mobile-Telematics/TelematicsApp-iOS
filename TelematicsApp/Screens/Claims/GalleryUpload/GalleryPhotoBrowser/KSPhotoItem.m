//
//  KSPhotoItem.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 28.06.21.
//  Copyright © 2020-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "KSPhotoItem.h"

@interface KSPhotoItem ()

@property (nonatomic, strong, readwrite) UIImage *thumbImage;
@property (nonatomic, strong, readwrite) UIImage *image;
@property (nonatomic, strong, readwrite) NSURL *imageUrl;

@end

@implementation KSPhotoItem

- (instancetype)initWithSourceView:(UIView *)view
                        thumbImage:(UIImage *)image
                          imageUrl:(NSURL *)url {
    self = [super init];
    if (self) {
        _sourceView = view;
        _thumbImage = image;
        _imageUrl = url;
    }
    return self;
}

- (instancetype)initWithSourceView:(UIImageView *)view
                          imageUrl:(NSURL *)url
{
    return [self initWithSourceView:view
                         thumbImage:view.image
                           imageUrl:url];
}

- (instancetype)initWithSourceView:(UIImageView *)view
                             image:(UIImage *)image {
    self = [super init];
    if (self) {
        _sourceView = view;
        _thumbImage = image;
        _imageUrl = nil;
        _image = image;
    }
    return self;
}

+ (instancetype)itemWithSourceView:(UIView *)view
                        thumbImage:(UIImage *)image
                          imageUrl:(NSURL *)url
{
    return [[KSPhotoItem alloc] initWithSourceView:view
                                    thumbImage:image
                                      imageUrl:url];
}

+ (instancetype)itemWithSourceView:(UIImageView *)view
                          imageUrl:(NSURL *)url
{
    return [[KSPhotoItem alloc] initWithSourceView:view
                                          imageUrl:url];
}

+ (instancetype)itemWithSourceView:(UIImageView *)view
                             image:(UIImage *)image
{
    return [[KSPhotoItem alloc] initWithSourceView:view
                                             image:image];
}

@end
