//
//  StepPhotoViewController.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 01.04.21.
//  Copyright © 2019-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "StepPhotoViewController.h"
#import "ClaimReviewViewCtrl.h"
#import "Color.h"
#import "Helpers.h"
#import "UIViewController+Preloader.h"
#import "UITextField+Form.h"
#import "CarPhotoCell.h"


@interface StepPhotoViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UILabel                *mainLbl;

@property (weak, nonatomic) IBOutlet UICollectionView       *collectionViewPhotos;
@property (weak, nonatomic) IBOutlet UIPageControl          *pageCtrlPhotos;
@property (strong, nonatomic) NSMutableArray                *collectionViewTitlesArr;
@property (strong, nonatomic) NSMutableArray                *collectionViewTitlesPhotos;
@property (weak, nonatomic) IBOutlet UIButton               *backBtn;
@property (weak, nonatomic) IBOutlet UIButton               *sendBtn;
@property (weak, nonatomic) IBOutlet UIImageView            *mainCarPhotoImg;

@end

@implementation StepPhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //[self setupView]; //OLD
    [self checkVehicleImageStatus];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkVehicleImageStatus) name:@"checkVehicleImageStatus" object:nil];
    
    [self.sendBtn addTarget:self action:@selector(reviewFinalClaimBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self.backBtn addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.sendBtn setTintColor:[Color officialWhiteColor]];
    [self.sendBtn setBackgroundColor:[Color officialMainAppColor]];
    [self.sendBtn.layer setMasksToBounds:YES];
    [self.sendBtn.layer setCornerRadius:15.0f];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:true];
}


#pragma mark - Camera Wizard Start

- (IBAction)shutPhotoAction_LEFT:(id)sender {
    defaults_set_object(@"claimSelectedPhotoBlock", @1);
    defaults_set_object(@"claimSelectedPhotoShot", @0);
    
    CameraCarViewController* camVc = [[UIStoryboard storyboardWithName:@"CameraCar" bundle:nil] instantiateInitialViewController];
    camVc.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self presentViewController:camVc animated:true completion:nil];
}

- (IBAction)shutPhotoAction_REAR:(id)sender {
    defaults_set_object(@"claimSelectedPhotoBlock", @2);
    defaults_set_object(@"claimSelectedPhotoShot", @10);
    
    CameraCarViewController* camVc = [[UIStoryboard storyboardWithName:@"CameraCar" bundle:nil] instantiateInitialViewController];
    camVc.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self presentViewController:camVc animated:true completion:nil];
}

- (IBAction)shutPhotoAction_RIGHT:(id)sender {
    defaults_set_object(@"claimSelectedPhotoBlock", @3);
    defaults_set_object(@"claimSelectedPhotoShot", @5);
    
    CameraCarViewController* camVc = [[UIStoryboard storyboardWithName:@"CameraCar" bundle:nil] instantiateInitialViewController];
    camVc.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self presentViewController:camVc animated:true completion:nil];
}

- (IBAction)shutPhotoAction_FRONT:(id)sender {
    defaults_set_object(@"claimSelectedPhotoBlock", @4);
    defaults_set_object(@"claimSelectedPhotoShot", @13);
    
    CameraCarViewController* camVc = [[UIStoryboard storyboardWithName:@"CameraCar" bundle:nil] instantiateInitialViewController];
    camVc.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self presentViewController:camVc animated:true completion:nil];
}


#pragma mark - Navigation

- (IBAction)dismissAction:(id)sender {
    [[[[[[[[self presentingViewController] presentingViewController] presentingViewController] presentingViewController] presentingViewController] presentingViewController] presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)backAction:(id)sender {
    CATransition *transition = [[CATransition alloc] init];
    transition.duration = 0.3;
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromLeft;
    [transition setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
    [self.view.window.layer addAnimation:transition forKey:kCATransition];
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)reviewFinalClaimBtnAction {
    ClaimReviewViewCtrl* review = [self.storyboard instantiateViewControllerWithIdentifier:@"ClaimReviewViewCtrl"];
    review.hideBottomButtons = NO;
    review.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self presentViewController:review animated:NO completion:nil];
}

- (NSMutableAttributedString*)createInfoImage:(NSString*)text {
    NSTextAttachment *imageAttachment = [[NSTextAttachment alloc] init];
    imageAttachment.image = [UIImage imageNamed:@"info"];
    imageAttachment.bounds = CGRectMake(10, -4, imageAttachment.image.size.width/1.5, imageAttachment.image.size.height/1.5);
    NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:imageAttachment];
    NSMutableAttributedString *completeText = [[NSMutableAttributedString alloc] initWithString:text];
    [completeText appendAttributedString:attachmentString];
    return completeText;
}

- (void)lowFontsForOldDevices {
    if (IS_IPHONE_5 || IS_IPHONE_4)
        self.mainLbl.font = [Font semibold15];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - CollectionView Method

- (void)setupView {
    self.collectionViewTitlesArr = [NSMutableArray arrayWithObjects:@"Left Front Wing", @"Left Front Door", @"Left Rear Door", @"Left Rear Wing", @"Right Front Wing", @"Right Front Door", @"Right Rear Door", @"Right Rear Wing", @"Windshield", @"Dashboard", nil];
    self.collectionViewTitlesPhotos = [NSMutableArray arrayWithObjects:@"claimsPhotoLeft1", @"claimsPhotoLeft2", @"claimsPhotoLeft3", @"claimsPhotoLeft4", @"claimsPhotoRight1", @"claimsPhotoRight2", @"claimsPhotoRight3", @"claimsPhotoRight4", @"sideCar9", @"sideCar10", nil];
    [self.collectionViewPhotos reloadData];
    
    [self.sendBtn addTarget:self action:@selector(reviewFinalClaimBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self.backBtn addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    NSInteger count = self.collectionViewTitlesArr.count;
    _pageCtrlPhotos.numberOfPages = count;
    return count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 1;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionReusableView *reusableview = nil;
    
    if (kind == UICollectionElementKindSectionHeader) {
        UIView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];
        NSString *title = [self.collectionViewTitlesArr objectAtIndex:indexPath.section];
        UILabel *titleLbl =  [headerView viewWithTag:5];
        titleLbl.text = title;
        reusableview = headerView;
    }
    return reusableview;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CarPhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([CarPhotoCell class]) forIndexPath:indexPath];
    
    //NSInteger numSection = indexPath.section;
    NSString *side = [self.collectionViewTitlesArr objectAtIndex:indexPath.section];
    cell.sideLbl.attributedText = [self createInfoImage:side];
    cell.mainPhoto.image = [UIImage imageNamed:[self.collectionViewTitlesPhotos objectAtIndex:indexPath.section]];
    
    [cell.cameraBtn addTarget:self action:@selector(shutPhotoAction_LEFT:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    int index = scrollView.contentOffset.x / scrollView.frame.size.width;
    if (scrollView == _collectionViewPhotos) {
        _pageCtrlPhotos.currentPage = index;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(collectionView.frame.size.width/1.0f, ceilf(collectionView.frame.size.height/1.0f) );
}


#pragma mark - Enumerator Sides

- (void)checkVehicleImageStatus {

    if ([ClaimsService sharedService].Photo_Left_Wide != nil) {
        [self.mainCarPhotoImg setImage:[UIImage imageNamed:@"LGR_RGE_RGE_FGE"]];
        
        if ([ClaimsService sharedService].Photo_Rear_Left_Diagonal != nil) {
            [self.mainCarPhotoImg setImage:[UIImage imageNamed:@"LGR_RGR_RGE_FGE"]];
        }
        if ([ClaimsService sharedService].Photo_Rear_Wide != nil) {
            [self.mainCarPhotoImg setImage:[UIImage imageNamed:@"LGR_RGR_RGE_FGE"]];
        }
        if ([ClaimsService sharedService].Photo_Rear_Right_Diagonal != nil) {
            [self.mainCarPhotoImg setImage:[UIImage imageNamed:@"LGR_RGR_RGE_FGE"]];
        }
        if ([ClaimsService sharedService].Photo_Right_Wide != nil) {
            [self.mainCarPhotoImg setImage:[UIImage imageNamed:@"LGR_RGE_RGR_FGE"]];
        }
        if ([ClaimsService sharedService].Photo_Right_Wide != nil && [ClaimsService sharedService].Photo_Rear_Right_Diagonal != nil) {
            [self.mainCarPhotoImg setImage:[UIImage imageNamed:@"LGR_RGE_RGR_FGE"]];
        }
        if ([ClaimsService sharedService].Photo_Right_Wide != nil && [ClaimsService sharedService].Photo_Right_Wide != nil) {
            [self.mainCarPhotoImg setImage:[UIImage imageNamed:@"LGR_RGR_RGR_FGE"]];
        }
        if ([ClaimsService sharedService].Photo_Right_Wide != nil && [ClaimsService sharedService].Photo_Front_Right_Diagonal == nil && [ClaimsService sharedService].Photo_Rear_Left_Diagonal == nil) {
            [self.mainCarPhotoImg setImage:[UIImage imageNamed:@"LGR_RGE_RGR_FGE"]];
        }
        
        if ([ClaimsService sharedService].Photo_Front_Right_Diagonal != nil) {
            [self.mainCarPhotoImg setImage:[UIImage imageNamed:@"LGR_RGE_RGE_FGR"]];
        }
        if ([ClaimsService sharedService].Photo_Front_Right_Diagonal != nil && [ClaimsService sharedService].Photo_Left_Wide != nil && [ClaimsService sharedService].Photo_Rear_Left_Diagonal != nil) {
            [self.mainCarPhotoImg setImage:[UIImage imageNamed:@"LGR_RGR_RGE_FGR"]];
        }
        if ([ClaimsService sharedService].Photo_Front_Right_Diagonal != nil && [ClaimsService sharedService].Photo_Rear_Right_Diagonal != nil) {
            [self.mainCarPhotoImg setImage:[UIImage imageNamed:@"LGR_RGR_RGE_FGR"]];
        }
        if ([ClaimsService sharedService].Photo_Front_Wide != nil) {
            [self.mainCarPhotoImg setImage:[UIImage imageNamed:@"LGR_RGE_RGE_FGR"]];
        }
        if ([ClaimsService sharedService].Photo_Front_Left_Diagonal != nil) {
            [self.mainCarPhotoImg setImage:[UIImage imageNamed:@"LGR_RGE_RGE_FGR"]];
        }
        
        if ([ClaimsService sharedService].Photo_Rear_Left_Diagonal != nil && [ClaimsService sharedService].Photo_Rear_Wide != nil) {
            [self.mainCarPhotoImg setImage:[UIImage imageNamed:@"LGR_RGR_RGE_FGE"]];
        }
        if ([ClaimsService sharedService].Photo_Rear_Left_Diagonal != nil && [ClaimsService sharedService].Photo_Rear_Wide != nil && [ClaimsService sharedService].Photo_Front_Right_Diagonal != nil) {
            [self.mainCarPhotoImg setImage:[UIImage imageNamed:@"LGR_RGR_RGE_FGE"]]; ////
        }
        if ([ClaimsService sharedService].Photo_Rear_Wide != nil && [ClaimsService sharedService].Photo_Right_Wide != nil) {
            [self.mainCarPhotoImg setImage:[UIImage imageNamed:@"LGR_RGR_RGR_FGE"]];
        }
        if ([ClaimsService sharedService].Photo_Rear_Right_Diagonal != nil && [ClaimsService sharedService].Photo_Rear_Left_Diagonal != nil) {
            [self.mainCarPhotoImg setImage:[UIImage imageNamed:@"LGR_RGR_RGE_FGE"]];
        }
        
        if ([ClaimsService sharedService].Photo_Right_Wide != nil && [ClaimsService sharedService].Photo_Front_Right_Diagonal != nil) {
            [self.mainCarPhotoImg setImage:[UIImage imageNamed:@"LGR_RGE_RGR_FGR"]];
        }
        if ([ClaimsService sharedService].Photo_Right_Wide != nil && [ClaimsService sharedService].Photo_Front_Wide != nil) {
            [self.mainCarPhotoImg setImage:[UIImage imageNamed:@"LGR_RGE_RGR_FGR"]];
        }
        if ([ClaimsService sharedService].Photo_Right_Wide != nil && [ClaimsService sharedService].Photo_Front_Left_Diagonal != nil) {
            [self.mainCarPhotoImg setImage:[UIImage imageNamed:@"LGR_RGE_RGR_FGR"]];
        }
        
        if ([ClaimsService sharedService].Photo_Rear_Wide != nil && [ClaimsService sharedService].Photo_Front_Right_Diagonal != nil) {
            [self.mainCarPhotoImg setImage:[UIImage imageNamed:@"LGR_RGR_RGE_FGR"]];
        }
        if ([ClaimsService sharedService].Photo_Rear_Wide != nil && [ClaimsService sharedService].Photo_Front_Wide != nil) {
            [self.mainCarPhotoImg setImage:[UIImage imageNamed:@"LGR_RGR_RGE_FGR"]];
        }
        if ([ClaimsService sharedService].Photo_Rear_Wide != nil && [ClaimsService sharedService].Photo_Front_Left_Diagonal != nil) {
            [self.mainCarPhotoImg setImage:[UIImage imageNamed:@"LGR_RGR_RGE_FGR"]];
        }
        
        if ([ClaimsService sharedService].Photo_Rear_Wide != nil && [ClaimsService sharedService].Photo_Right_Wide != nil && [ClaimsService sharedService].Photo_Front_Wide != nil) {
            [self.mainCarPhotoImg setImage:[UIImage imageNamed:@"LGR_RGR_RGR_FGR"]];
        }
        if ([ClaimsService sharedService].Photo_Rear_Right_Diagonal != nil && [ClaimsService sharedService].Photo_Right_Wide != nil && [ClaimsService sharedService].Photo_Front_Left_Diagonal != nil) {
            [self.mainCarPhotoImg setImage:[UIImage imageNamed:@"LGR_RGR_RGR_FGR"]];
        }
        if ([ClaimsService sharedService].Photo_Rear_Left_Diagonal != nil && [ClaimsService sharedService].Photo_Right_Wide != nil) {
            [self.mainCarPhotoImg setImage:[UIImage imageNamed:@"LGR_RGR_RGR_FGE"]];
        }
        if ([ClaimsService sharedService].Photo_Rear_Left_Diagonal != nil && [ClaimsService sharedService].Photo_Right_Wide != nil && [ClaimsService sharedService].Photo_Front_Right_Diagonal != nil) {
            [self.mainCarPhotoImg setImage:[UIImage imageNamed:@"LGR_RGR_RGR_FGR"]];
        }
        return;
    }
    
    if ([ClaimsService sharedService].Photo_Rear_Left_Diagonal != nil) {
        [self.mainCarPhotoImg setImage:[UIImage imageNamed:@"LGE_RGR_RGE_FGE"]];
        
        if ([ClaimsService sharedService].Photo_Left_Wide != nil) {
            [self.mainCarPhotoImg setImage:[UIImage imageNamed:@"LGR_RGR_RGE_FGE"]];
        }
        if ([ClaimsService sharedService].Photo_Right_Wide != nil) {
            [self.mainCarPhotoImg setImage:[UIImage imageNamed:@"LGE_RGR_RGR_FGE"]];
        }
        if ([ClaimsService sharedService].Photo_Front_Right_Diagonal != nil || [ClaimsService sharedService].Photo_Front_Wide != nil || [ClaimsService sharedService].Photo_Front_Left_Diagonal != nil) {
            [self.mainCarPhotoImg setImage:[UIImage imageNamed:@"LGE_RGR_RGE_FGR"]];
        }
        
        if ([ClaimsService sharedService].Photo_Left_Wide != nil && [ClaimsService sharedService].Photo_Right_Wide != nil) {
            [self.mainCarPhotoImg setImage:[UIImage imageNamed:@"LGR_RGR_RGR_FGE"]];
        }
        
        if ([ClaimsService sharedService].Photo_Left_Wide != nil && [ClaimsService sharedService].Photo_Front_Right_Diagonal != nil) {
            [self.mainCarPhotoImg setImage:[UIImage imageNamed:@"LGR_RGR_RGE_FGR"]];
        }
        if ([ClaimsService sharedService].Photo_Left_Wide != nil && [ClaimsService sharedService].Photo_Front_Wide != nil) {
            [self.mainCarPhotoImg setImage:[UIImage imageNamed:@"LGR_RGR_RGE_FGR"]];
        }
        if ([ClaimsService sharedService].Photo_Left_Wide != nil && [ClaimsService sharedService].Photo_Front_Left_Diagonal != nil) {
            [self.mainCarPhotoImg setImage:[UIImage imageNamed:@"LGR_RGR_RGE_FGR"]];
        }
        
        if ([ClaimsService sharedService].Photo_Right_Wide != nil && [ClaimsService sharedService].Photo_Front_Right_Diagonal != nil) {
            [self.mainCarPhotoImg setImage:[UIImage imageNamed:@"LGE_RGR_RGR_FGR"]];
        }
        if ([ClaimsService sharedService].Photo_Right_Wide != nil && [ClaimsService sharedService].Photo_Front_Wide != nil) {
            [self.mainCarPhotoImg setImage:[UIImage imageNamed:@"LGE_RGR_RGR_FGR"]];
        }
        if ([ClaimsService sharedService].Photo_Right_Wide != nil && [ClaimsService sharedService].Photo_Front_Left_Diagonal != nil) {
            [self.mainCarPhotoImg setImage:[UIImage imageNamed:@"LGE_RGR_RGR_FGR"]];
        }
        
        if ([ClaimsService sharedService].Photo_Left_Wide != nil && [ClaimsService sharedService].Photo_Right_Wide != nil && [ClaimsService sharedService].Photo_Front_Right_Diagonal != nil) {
            [self.mainCarPhotoImg setImage:[UIImage imageNamed:@"LGR_RGR_RGR_FGR"]];
        }
        if ([ClaimsService sharedService].Photo_Left_Wide != nil && [ClaimsService sharedService].Photo_Right_Wide != nil && [ClaimsService sharedService].Photo_Front_Wide != nil) {
            [self.mainCarPhotoImg setImage:[UIImage imageNamed:@"LGR_RGR_RGR_FGR"]];
        }
        if ([ClaimsService sharedService].Photo_Left_Wide != nil && [ClaimsService sharedService].Photo_Right_Wide != nil && [ClaimsService sharedService].Photo_Front_Left_Diagonal != nil) {
            [self.mainCarPhotoImg setImage:[UIImage imageNamed:@"LGR_RGR_RGR_FGR"]];
        }
        return;
    }
    
    if ([ClaimsService sharedService].Photo_Right_Wide != nil) {
        [self.mainCarPhotoImg setImage:[UIImage imageNamed:@"LGE_RGE_RGR_FGE"]];
        
        if ([ClaimsService sharedService].Photo_Left_Wide != nil) {
            [self.mainCarPhotoImg setImage:[UIImage imageNamed:@"LGR_RGE_RGR_FGE"]];
        }
        if ([ClaimsService sharedService].Photo_Rear_Left_Diagonal != nil || [ClaimsService sharedService].Photo_Rear_Wide != nil || [ClaimsService sharedService].Photo_Rear_Right_Diagonal != nil) {
            [self.mainCarPhotoImg setImage:[UIImage imageNamed:@"LGE_RGR_RGR_FGE"]];
        }
        if ([ClaimsService sharedService].Photo_Front_Right_Diagonal != nil || [ClaimsService sharedService].Photo_Front_Wide != nil || [ClaimsService sharedService].Photo_Front_Left_Diagonal != nil) {
            [self.mainCarPhotoImg setImage:[UIImage imageNamed:@"LGE_RGE_RGR_FGR"]];
        }
        if ([ClaimsService sharedService].Photo_Front_Right_Diagonal != nil && [ClaimsService sharedService].Photo_Right_Wide != nil) {
            [self.mainCarPhotoImg setImage:[UIImage imageNamed:@"LGE_RGE_RGR_FGR"]];
        }
        if ([ClaimsService sharedService].Photo_Front_Right_Diagonal != nil && [ClaimsService sharedService].Photo_Right_Wide != nil && [ClaimsService sharedService].Photo_Rear_Right_Diagonal != nil) {
            [self.mainCarPhotoImg setImage:[UIImage imageNamed:@"LGE_RGR_RGR_FGR"]];
        }
        if ([ClaimsService sharedService].Photo_Front_Right_Diagonal != nil && [ClaimsService sharedService].Photo_Right_Wide != nil && [ClaimsService sharedService].Photo_Rear_Left_Diagonal != nil) {
            [self.mainCarPhotoImg setImage:[UIImage imageNamed:@"LGE_RGR_RGR_FGR"]];
        }
        
        if ([ClaimsService sharedService].Photo_Left_Wide != nil && [ClaimsService sharedService].Photo_Rear_Left_Diagonal != nil) {
            [self.mainCarPhotoImg setImage:[UIImage imageNamed:@"LGR_RGR_RGR_FGE"]];
        }
        if ([ClaimsService sharedService].Photo_Left_Wide != nil && [ClaimsService sharedService].Photo_Rear_Wide != nil) {
            [self.mainCarPhotoImg setImage:[UIImage imageNamed:@"LGR_RGR_RGR_FGE"]];
        }
        if ([ClaimsService sharedService].Photo_Left_Wide != nil && [ClaimsService sharedService].Photo_Rear_Right_Diagonal != nil) {
            [self.mainCarPhotoImg setImage:[UIImage imageNamed:@"LGR_RGR_RGR_FGE"]];
        }
        
        if ([ClaimsService sharedService].Photo_Left_Wide != nil && [ClaimsService sharedService].Photo_Front_Right_Diagonal != nil) {
            [self.mainCarPhotoImg setImage:[UIImage imageNamed:@"LGR_RGE_RGR_FGR"]];
        }
        if ([ClaimsService sharedService].Photo_Left_Wide != nil && [ClaimsService sharedService].Photo_Front_Wide != nil) {
            [self.mainCarPhotoImg setImage:[UIImage imageNamed:@"LGR_RGE_RGR_FGR"]];
        }
        if ([ClaimsService sharedService].Photo_Left_Wide != nil && [ClaimsService sharedService].Photo_Front_Left_Diagonal != nil) {
            [self.mainCarPhotoImg setImage:[UIImage imageNamed:@"LGR_RGE_RGR_FGR"]];
        }
        
        if ([ClaimsService sharedService].Photo_Left_Wide != nil && [ClaimsService sharedService].Photo_Rear_Wide != nil && [ClaimsService sharedService].Photo_Front_Wide != nil) {
            [self.mainCarPhotoImg setImage:[UIImage imageNamed:@"LGR_RGR_RGR_FGR"]];
        }
        if ([ClaimsService sharedService].Photo_Left_Wide != nil && [ClaimsService sharedService].Photo_Rear_Left_Diagonal != nil && [ClaimsService sharedService].Photo_Front_Wide != nil) {
            [self.mainCarPhotoImg setImage:[UIImage imageNamed:@"LGR_RGR_RGR_FGR"]];
        }
        if ([ClaimsService sharedService].Photo_Left_Wide != nil && [ClaimsService sharedService].Photo_Rear_Right_Diagonal != nil && [ClaimsService sharedService].Photo_Front_Wide != nil) {
            [self.mainCarPhotoImg setImage:[UIImage imageNamed:@"LGR_RGR_RGR_FGR"]];
        }
        if ([ClaimsService sharedService].Photo_Left_Wide != nil && [ClaimsService sharedService].Photo_Rear_Left_Diagonal != nil && [ClaimsService sharedService].Photo_Front_Right_Diagonal != nil) {
            [self.mainCarPhotoImg setImage:[UIImage imageNamed:@"LGR_RGR_RGR_FGR"]];
        }
        if ([ClaimsService sharedService].Photo_Left_Wide != nil && [ClaimsService sharedService].Photo_Rear_Right_Diagonal != nil && [ClaimsService sharedService].Photo_Front_Left_Diagonal != nil) {
            [self.mainCarPhotoImg setImage:[UIImage imageNamed:@"LGR_RGR_RGR_FGR"]];
        }
        return;
    }
    
    if ([ClaimsService sharedService].Photo_Front_Right_Diagonal != nil || [ClaimsService sharedService].Photo_Front_Wide != nil || [ClaimsService sharedService].Photo_Front_Left_Diagonal != nil) {
        [self.mainCarPhotoImg setImage:[UIImage imageNamed:@"LGE_RGE_RGE_FGR"]];
        
        if ([ClaimsService sharedService].Photo_Left_Wide != nil) {
            [self.mainCarPhotoImg setImage:[UIImage imageNamed:@"LGR_RGE_RGE_FGR"]];
        }
        if ([ClaimsService sharedService].Photo_Rear_Left_Diagonal != nil || [ClaimsService sharedService].Photo_Rear_Wide != nil || [ClaimsService sharedService].Photo_Rear_Right_Diagonal != nil) {
            [self.mainCarPhotoImg setImage:[UIImage imageNamed:@"LGE_RGR_RGE_FGR"]];
        }
        if ([ClaimsService sharedService].Photo_Right_Wide != nil) {
            [self.mainCarPhotoImg setImage:[UIImage imageNamed:@"LGE_RGE_RGR_FGR"]];
        }
        
        if ([ClaimsService sharedService].Photo_Left_Wide != nil && [ClaimsService sharedService].Photo_Rear_Left_Diagonal != nil) {
            [self.mainCarPhotoImg setImage:[UIImage imageNamed:@"LGR_RGR_RGE_FGR"]];
        }
        if ([ClaimsService sharedService].Photo_Left_Wide != nil && [ClaimsService sharedService].Photo_Rear_Wide != nil) {
            [self.mainCarPhotoImg setImage:[UIImage imageNamed:@"LGR_RGR_RGE_FGR"]];
        }
        if ([ClaimsService sharedService].Photo_Left_Wide != nil && [ClaimsService sharedService].Photo_Rear_Right_Diagonal != nil) {
            [self.mainCarPhotoImg setImage:[UIImage imageNamed:@"LGR_RGR_RGE_FGR"]];
        }
        
        if ([ClaimsService sharedService].Photo_Left_Wide != nil && [ClaimsService sharedService].Photo_Right_Wide != nil) {
            [self.mainCarPhotoImg setImage:[UIImage imageNamed:@"LGR_RGE_RGR_FGR"]];
        }
        if ([ClaimsService sharedService].Photo_Rear_Wide != nil && [ClaimsService sharedService].Photo_Right_Wide != nil) {
            [self.mainCarPhotoImg setImage:[UIImage imageNamed:@"LGE_RGR_RGR_FGR"]];
        }
        if ([ClaimsService sharedService].Photo_Left_Wide != nil && [ClaimsService sharedService].Photo_Rear_Wide != nil && [ClaimsService sharedService].Photo_Right_Wide != nil) {
            [self.mainCarPhotoImg setImage:[UIImage imageNamed:@"LGR_RGR_RGR_FGR"]];
        }
        return;
    }
}

@end
