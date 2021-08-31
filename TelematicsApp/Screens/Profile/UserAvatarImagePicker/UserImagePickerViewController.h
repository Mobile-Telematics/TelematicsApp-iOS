//
//  UserImagePickerViewController.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 25.12.21.
//  Copyright © 2020-2021 DATA MOTION PTE. LTD. All rights reserved.
//

@import UIKit;

@class UserImagePickerViewController ;
@protocol UserImagePickerViewControllerDelegate <NSObject>

- (void)imagePicker:(UserImagePickerViewController *)imagePicker didSelectImage:(UIImage *)image;

@optional
- (void)imagePickerDidOpen;
- (void)imagePickerWillOpen;

- (void)imagePickerWillClose;
- (void)imagePickerDidClose;

- (void)imagePickerDidCancel;

@end


@interface UserImagePickerViewController : UIViewController {
  __unsafe_unretained id<UserImagePickerViewControllerDelegate> delegate;
}

@property (nonatomic, assign) id<UserImagePickerViewControllerDelegate> delegate;

@property (readonly) bool isVisible;
- (void)setAnimationTime:(NSTimeInterval)animationTime;

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIButton *photoLibraryBtn;
@property (nonatomic, strong) UIButton *cameraBtn;
@property (nonatomic, strong) UIButton *cancelBtn;

- (void)showImagePickerInController:(UIViewController *)controller;
- (void)showImagePickerInController:(UIViewController *)controller animated:(BOOL)animated;
- (void)dismiss;
- (void)dismissAnimated:(BOOL)animated;

@end


@interface TransitionDelegate : NSObject <UIViewControllerTransitioningDelegate>
@end


@interface AnimatedTransitioning : NSObject <UIViewControllerAnimatedTransitioning>
@property (nonatomic, assign) BOOL isPresenting;
@end


@interface UserPhotoCell: UICollectionViewCell
@end



