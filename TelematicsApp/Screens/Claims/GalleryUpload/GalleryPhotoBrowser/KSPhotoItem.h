//
//  KSPhotoItem.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 28.06.21.
//  Copyright © 2019-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KSPhotoItem : NSObject

@property (nonatomic, strong, nullable) UIView *sourceView;
@property (nonatomic, strong, readonly, nullable) UIImage *thumbImage;
@property (nonatomic, strong, readonly, nullable) UIImage *image;
@property (nonatomic, strong, readonly, nullable) NSURL *imageUrl;
@property (nonatomic, assign) BOOL finished;

- (nonnull instancetype)initWithSourceView:(nullable UIView *)view
                                thumbImage:(nullable UIImage *)image
                                  imageUrl:(nullable NSURL *)url;
- (nonnull instancetype)initWithSourceView:(nullable UIImageView * )view
                                  imageUrl:(nullable NSURL *)url;
- (nonnull instancetype)initWithSourceView:(nullable UIImageView *)view
                                     image:(nullable UIImage *)image;

+ (nonnull instancetype)itemWithSourceView:(nullable UIView *)view
                                thumbImage:(nullable UIImage *)image
                                  imageUrl:(nullable NSURL *)url;
+ (nonnull instancetype)itemWithSourceView:(nullable UIImageView *)view
                                  imageUrl:(nullable NSURL *)url;
+ (nonnull instancetype)itemWithSourceView:(nullable UIImageView *)view
                                     image:(nullable UIImage *)image;

@end
