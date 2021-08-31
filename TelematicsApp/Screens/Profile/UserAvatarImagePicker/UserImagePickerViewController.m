//
//  UserImagePickerViewController.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 25.12.21.
//  Copyright © 2020-2021 DATA MOTION PTE. LTD. All rights reserved.
//

@import Photos;
#import "UserImagePickerViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import "Helpers.h"
#import "Color.h"
#import "TelematicsAppCameraAccessor.h"

#define imagePickerHeight 280.0f
#define imagePickerHeightX 330.0f

@interface UserImagePickerViewController ()  <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (readwrite) bool isVisible;
@property (readwrite) bool haveCamera;
@property (nonatomic) NSTimeInterval animationTime;
@property (nonatomic) UIImagePickerController *pickerNew;

@property (nonatomic, strong) UIViewController *targetController;
@property (nonatomic, strong) UIWindow *window;

@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UIView *imagePickerView;

@property (nonatomic) CGRect imagePickerFrame;
@property (nonatomic) CGRect hiddenFrame;

@property (nonatomic) TransitionDelegate *transitionController;

@property (nonatomic, strong) NSMutableArray *assets;

@end


@implementation UserImagePickerViewController

@synthesize delegate;
@synthesize transitionController;

- (id)init {
    self = [super init];
    if (self) {
        self.assets = [[NSMutableArray alloc] init];
        [self setupView];
    }
    return self;
}

- (void)setupView {
    self.view.backgroundColor = [UIColor clearColor];
    self.window = [UIApplication sharedApplication].keyWindow;
  
    self.haveCamera = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    CGFloat localImagePickerHeight = imagePickerHeight;
    if (IS_IPHONE_11 || IS_IPHONE_12_PRO || IS_IPHONE_11_PROMAX || IS_IPHONE_12_PROMAX) {
        localImagePickerHeight = imagePickerHeightX;
    }
    
    if (!self.haveCamera) {
        localImagePickerHeight -= 47.0f;
    }
    
    self.imagePickerFrame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height-localImagePickerHeight, [UIScreen mainScreen].bounds.size.width, localImagePickerHeight);
    self.hiddenFrame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, localImagePickerHeight);
    self.imagePickerView = [[UIView alloc] initWithFrame:self.hiddenFrame];
    self.imagePickerView.backgroundColor = [Color officialWhiteColor];
  
    self.backgroundView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.backgroundView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
    self.backgroundView.alpha = 0.7;
    UITapGestureRecognizer *dismissTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
    self.backgroundView.userInteractionEnabled = YES;
    [self.backgroundView addGestureRecognizer:dismissTap];

    self.animationTime = 0.2;
  
    [self.window addSubview:self.backgroundView];
    [self.window addSubview:self.imagePickerView];
  
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.imagePickerView.frame.size.width, 50)];
    [btn setTitle:@"Welcome" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(setDefaults) forControlEvents:UIControlEventTouchUpInside];
  
    [self.imagePickerView addSubview:btn];
  
    [self imagePickerViewSetup];
    [self getCameraRollImages];
}

- (void)imagePickerViewSetup {
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
  
    const CGRect collectionViewFrame = CGRectMake(7, 8, screenWidth-7-7, 122);
    const CGRect libraryBtnFrame = CGRectMake(0, 149, screenWidth, 30);
    const CGRect cameraBtnFrame = CGRectMake(0, self.haveCamera ? 196 : 0, screenWidth, 30);
    const CGRect cancelBtnFrame = CGRectMake(0, self.haveCamera ? 242 : 196, screenWidth, 30);
  
    UICollectionViewFlowLayout *aFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    [aFlowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    self.collectionView = [[UICollectionView alloc] initWithFrame:collectionViewFrame collectionViewLayout:aFlowLayout];
    [self.collectionView setBackgroundColor:[Color officialWhiteColor]];
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.collectionView registerClass:[UserPhotoCell class] forCellWithReuseIdentifier:@"Cell"];
  
    UIFont *btnFont = [Font regular19];
  
    self.photoLibraryBtn = [[UIButton alloc] initWithFrame:libraryBtnFrame];
    [self.photoLibraryBtn setTitle:localizeString(@"Photo Library") forState:UIControlStateNormal];
    self.photoLibraryBtn.titleLabel.font = btnFont;
    [self.photoLibraryBtn addTarget:self action:@selector(selectFromLibraryWasPressed) forControlEvents:UIControlEventTouchUpInside];
  
    self.cameraBtn = [[UIButton alloc] initWithFrame:cameraBtnFrame];
    [self.cameraBtn setTitle:localizeString(@"Take Photo") forState:UIControlStateNormal];
    self.cameraBtn.titleLabel.font = btnFont;
    [self.cameraBtn addTarget:self action:@selector(takePhotoWasPressed) forControlEvents:UIControlEventTouchUpInside];
    self.cameraBtn.hidden = !self.haveCamera;
  
    self.cancelBtn = [[UIButton alloc] initWithFrame:cancelBtnFrame];
    [self.cancelBtn setTitle:localizeString(@"Cancel") forState:UIControlStateNormal];
    self.cancelBtn.titleLabel.font = btnFont;
    [self.cancelBtn addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
  
    for (UIButton *btn in @[self.photoLibraryBtn, self.cameraBtn, self.cancelBtn]) {
        [btn setTitleColor:[Color officialMainAppColor] forState:UIControlStateNormal];
        [btn setTitleColor:[Color officialMainAppColor] forState:UIControlStateHighlighted];
    }
  
    UIView *separator1 = [[UIView alloc] initWithFrame:CGRectMake(0, 140, screenWidth, 1)];
    separator1.backgroundColor = UIColorFromRGBWithValue(0xDDDDDD);
    [self.imagePickerView addSubview:separator1];
  
    UIView *separator2 = [[UIView alloc] initWithFrame:CGRectMake(0, 187, screenWidth, 1)];
    separator2.backgroundColor = UIColorFromRGBWithValue(0xDDDDDD);
    [self.imagePickerView addSubview:separator2];
    
    UIView *separator3 = [[UIView alloc] initWithFrame:CGRectMake(0, 234, screenWidth, 1)];
    separator3.backgroundColor = UIColorFromRGBWithValue(0xDDDDDD);
    [self.imagePickerView addSubview:separator3];
  
    [self.imagePickerView addSubview:self.collectionView];
    [self.imagePickerView addSubview:self.photoLibraryBtn];
    [self.imagePickerView addSubview:self.cameraBtn];
    [self.imagePickerView addSubview:self.cancelBtn];
}


#pragma mark - Collection view

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return MIN(20, self.assets.count);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UserPhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    
    ALAsset *asset = self.assets[self.assets.count-1 - indexPath.row];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageWithCGImage:[asset thumbnail]]];
    
    imageView.clipsToBounds = YES;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    [cell addSubview:imageView];
  
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
  
    ALAsset *asset = self.assets[self.assets.count-1 - indexPath.row];
    ALAssetRepresentation* representation = [asset defaultRepresentation];
    UIImageOrientation orientation = UIImageOrientationUp;
    NSNumber* orientationValue = [asset valueForProperty:@"ALAssetPropertyOrientation"];
    if (orientationValue != nil) {
        orientation = [orientationValue intValue];
    }
  
    CGFloat scale  = 1;
    UIImage* image = [UIImage imageWithCGImage:[representation fullResolutionImage]
                                       scale:scale orientation:orientation];
  
    if ([delegate respondsToSelector:@selector(imagePicker:didSelectImage:)]) {
        [delegate imagePicker:self didSelectImage:image];
    }
    
    [self dismissAnimated:YES];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(120, 114);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 10.0f;
}


#pragma mark - Image library

- (void)getCameraRollImages {
    _assets = [@[] mutableCopy];
    __block NSMutableArray *tmpAssets = [@[] mutableCopy];
    ALAssetsLibrary *assetsLibrary = [UserImagePickerViewController defaultAssetsLibrary];
    [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
            if (result)
            {
                [tmpAssets addObject:result];
                
            }
            
        }];
    
        ALAssetsGroupEnumerationResultsBlock assetsEnumerationBlock = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
            if (result) {
                [self.assets addObject:result];
            }
        };
        
        ALAssetsFilter *onlyPhotosFilter = [ALAssetsFilter allPhotos];
        [group setAssetsFilter:onlyPhotosFilter];
        [group enumerateAssetsUsingBlock:assetsEnumerationBlock];
    
        [self.collectionView reloadData];
  } failureBlock:^(NSError *error) {
      NSLog(@"Error loading images %@", error);
  }];
}

+ (ALAssetsLibrary *)defaultAssetsLibrary
{
    static dispatch_once_t pred = 0;
    static ALAssetsLibrary *library = nil;
    dispatch_once(&pred, ^{
        library = [[ALAssetsLibrary alloc] init];
        
    });
    return library;
}


#pragma mark - Image picker

- (void)takePhotoWasPressed {
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"No Camera!"
                                                                       message:@"Sorry, this device does not have a camera."
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:localizeString(@"Ok") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        }];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    
    } else {
        AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (status != AVAuthorizationStatusNotDetermined) {
            if (status == AVAuthorizationStatusAuthorized) {
                
                self.pickerNew = [[UIImagePickerController alloc] init];
                self.pickerNew.delegate = self;
                self.pickerNew.sourceType = UIImagePickerControllerSourceTypeCamera;
                self.pickerNew.cameraDevice = UIImagePickerControllerCameraDeviceFront;
                self.pickerNew.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeImage, nil];
                
                [self mirrorFrontCamera];
                
                [self presentViewController:self.pickerNew animated:YES completion:nil];
                
            } else {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:localizeString(@"Need access to Camera")
                                                                               message:localizeString(@"To take photos, you must give access to the Camera. Turn on it?")
                                                                        preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *yesAction = [UIAlertAction actionWithTitle:localizeString(@"Yes") style:UIAlertActionStyleCancel
                                                                  handler:^(UIAlertAction *action) {
                                                                      NSURL *settingsUrl = [[NSURL alloc] initWithString:UIApplicationOpenSettingsURLString];
                                                                      [[UIApplication sharedApplication] openURL:settingsUrl options:@{} completionHandler:nil];
                                                                  }];
                UIAlertAction *noAction = [UIAlertAction actionWithTitle:localizeString(@"No") style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction *action) {
                                                                 }];
                [alert addAction:yesAction];
                [alert addAction:noAction];
                [self presentViewController:alert animated:NO completion:nil];
            }
        } else {
            self.pickerNew = [[UIImagePickerController alloc] init];
            self.pickerNew.delegate = self;
            self.pickerNew.sourceType = UIImagePickerControllerSourceTypeCamera;
            self.pickerNew.cameraDevice = UIImagePickerControllerCameraDeviceFront;
            self.pickerNew.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeImage, nil];
            
            [self mirrorFrontCamera];
            
            [self presentViewController:self.pickerNew animated:YES completion:nil];
        }
    }
}

- (void)selectFromLibraryWasPressed {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeImage, nil];
  
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *chosenImage = info[UIImagePickerControllerOriginalImage];
    [picker dismissViewControllerAnimated:YES completion:^{
        if ([self->delegate respondsToSelector:@selector(imagePicker:didSelectImage:)]) {
            [self->delegate imagePicker:self didSelectImage:chosenImage];
            
        }
        [self dismissAnimated:YES];
    }];
}

- (void)mirrorFrontCamera
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(cameraChanged:)
                                                 name:@"AVCaptureDeviceDidStartRunningNotification"
                                               object:nil];
    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AVCaptureDeviceDidStartRunningNotification" object:nil];
}


#pragma mark - Private methods

- (void)cameraChanged:(NSNotification *)notification
{
    if (self.pickerNew.cameraDevice == UIImagePickerControllerCameraDeviceFront)
    {
        self.pickerNew.cameraViewTransform = CGAffineTransformIdentity;
        self.pickerNew.cameraViewTransform = CGAffineTransformScale(self.pickerNew.cameraViewTransform, -1, 1);
    } else {
        self.pickerNew.cameraViewTransform = CGAffineTransformIdentity;
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Show Picker

- (void)showImagePickerInController:(UIViewController *)controller {
    [self showImagePickerInController:controller animated:YES];
}

- (void)showImagePickerInController:(UIViewController *)controller animated:(BOOL)animated {
    if (self.isVisible != YES) {
        if ([delegate respondsToSelector:@selector(imagePickerWillOpen)]) {
            [delegate imagePickerWillOpen];
            
        }
        self.isVisible = YES;
    
        [self setTransitioningDelegate:transitionController];
        if ([[[UIDevice currentDevice] systemVersion] floatValue]>=8.0) {
            self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        } else {
            self.modalPresentationStyle = UIModalPresentationCustom;
            
        }
        [controller presentViewController:self animated:NO completion:nil];
    
        if (animated) {
            [UIView animateWithDuration:self.animationTime
                                  delay:0
                                options:UIViewAnimationOptionCurveLinear
                             animations:^{
                                 [self.imagePickerView setFrame:self.imagePickerFrame];
                                 [self.backgroundView setAlpha:1];
                             }
                             completion:^(BOOL finished) {
                                 if ([self->delegate respondsToSelector:@selector(imagePickerDidOpen)]) {
                                     [self->delegate imagePickerDidOpen];
                                 }
                             }];
        } else {
            [self.imagePickerView setFrame:self.imagePickerFrame];
            [self.backgroundView setAlpha:0];
        }
    }
}


#pragma mark - Dismiss Picker

- (void)dismiss {
    [self dismissAnimated:YES];
}

- (void)dismissAnimated:(BOOL)animated {
    if (self.isVisible == YES) {
        if ([delegate respondsToSelector:@selector(imagePickerWillClose)]) {
            [delegate imagePickerWillClose];
        }
        if (animated) {
            [UIView animateWithDuration:self.animationTime
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseIn
                             animations:^{
                                 [self.imagePickerView setFrame:self.hiddenFrame];
                                 [self.backgroundView setAlpha:0];
                             }
                             completion:^(BOOL finished) {
                                 [self.imagePickerView removeFromSuperview];
                                 [self.backgroundView removeFromSuperview];
                                 [self dismissViewControllerAnimated:NO completion:nil];
                                 if ([self->delegate respondsToSelector:@selector(imagePickerDidClose)]) {
                                     [self->delegate imagePickerDidClose];
                                 }
                             }];
        } else {
            [self.imagePickerView setFrame:self.imagePickerFrame];
            [self.backgroundView setAlpha:0];
        }
    }
}

@end


#pragma mark - TransitionDelegate

@implementation TransitionDelegate

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    AnimatedTransitioning *controller = [[AnimatedTransitioning alloc] init];
    controller.isPresenting = YES;
    return controller;
}

@end


#pragma mark - AnimatedTransitioning

@implementation AnimatedTransitioning

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return 0.25f;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    UIView *inView = [transitionContext containerView];
    UIViewController *toVC = (UIViewController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController *fromVC = (UIViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    [inView addSubview:toVC.view];
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    [toVC.view setFrame:CGRectMake(0, screenRect.size.height, fromVC.view.frame.size.width, fromVC.view.frame.size.height)];
  
    [UIView animateWithDuration:0.25f
                     animations:^{
                         [toVC.view setFrame:CGRectMake(0, 0, fromVC.view.frame.size.width, fromVC.view.frame.size.height)];
                     }
                     completion:^(BOOL finished) {
                         [transitionContext completeTransition:YES];
                     }];
}

@end


#pragma mark - UserPhotoCell

@interface UserPhotoCell ()

@end

@implementation UserPhotoCell

@end
