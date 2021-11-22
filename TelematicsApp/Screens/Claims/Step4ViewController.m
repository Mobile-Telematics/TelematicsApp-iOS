//
//  Step4ViewController.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 01.04.21.
//  Copyright © 2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "Step4ViewController.h"
#import "ClaimReviewViewCtrl.h"
#import "Color.h"
#import "Helpers.h"
#import "UIViewController+Preloader.h"
#import "CarPhotoCell.h"


@interface Step4ViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UILabel                *mainLbl;

@property (weak, nonatomic) IBOutlet UICollectionView       *collectionViewPhotos;
@property (weak, nonatomic) IBOutlet UIPageControl          *pageCtrlPhotos;
@property (strong, nonatomic) NSMutableArray                *collectionViewTitlesArr;
@property (strong, nonatomic) NSMutableArray                *collectionViewTitlesPhotos;
@property (weak, nonatomic) IBOutlet UIButton               *backBtn;
@property (weak, nonatomic) IBOutlet UIButton               *sendBtn;

@end

@implementation Step4ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
    
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

- (void)setupView {
//    self.collectionViewTitlesArr = [NSMutableArray arrayWithObjects:@"Left Side", @"Back Left Diagonal", @"Back Side", @"Back Right Diagonal", @"Right Side", @"Front Right Diagonal", @"Front Side", @"Front Left Diagonal", @"Windshield", @"Dashboard", nil];
//    self.collectionViewTitlesPhotos = [NSMutableArray arrayWithObjects:@"sideCar1", @"sideCar2", @"sideCar3", @"sideCar4", @"sideCar5", @"sideCar6", @"sideCar7", @"sideCar8", @"sideCar9", @"sideCar10", nil];
    
    self.collectionViewTitlesArr = [NSMutableArray arrayWithObjects:@"Left Front Wing", @"Left Front Door", @"Left Rear Door", @"Left Rear Wing", @"Right Front Wing", @"Right Front Door", @"Right Rear Door", @"Right Rear Wing", @"Windshield", @"Dashboard", nil];
    self.collectionViewTitlesPhotos = [NSMutableArray arrayWithObjects:@"claimsPhotoLeft1", @"claimsPhotoLeft2", @"claimsPhotoLeft3", @"claimsPhotoLeft4", @"claimsPhotoRight1", @"claimsPhotoRight2", @"claimsPhotoRight3", @"claimsPhotoRight4", @"sideCar9", @"sideCar10", nil];
    [self.collectionViewPhotos reloadData];
    
    [self.sendBtn addTarget:self action:@selector(reviewFinalClaimBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self.backBtn addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
}


#pragma mark - CollectionView Method

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
    NSString *side = [self.collectionViewTitlesArr objectAtIndex:indexPath.section];
    cell.sideLbl.attributedText = [self createInfoImage:side];
    cell.mainPhoto.image = [UIImage imageNamed:[self.collectionViewTitlesPhotos objectAtIndex:indexPath.section]];
    [cell.cameraBtn addTarget:self action:@selector(shutPhotoAction:) forControlEvents:UIControlEventTouchUpInside];
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

- (void)shutPhotoAction:(id)sender {
    CGPoint position = [sender convertPoint:CGPointZero toView:self.collectionViewPhotos];
    NSIndexPath *tappedIndexPath = [self.collectionViewPhotos indexPathForItemAtPoint:position];
    NSNumber *selectedShot = @((long)tappedIndexPath.section);
    defaults_set_object(@"claimSelectedPhotoShot", selectedShot);
    
    CameraCarViewController* camVc = [[UIStoryboard storyboardWithName:@"CameraCar" bundle:nil] instantiateInitialViewController];
    camVc.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self presentViewController:camVc animated:true completion:nil];
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


#pragma mark - Navigation

- (IBAction)dismissAction:(id)sender {
    [[[[[[[self presentingViewController] presentingViewController] presentingViewController] presentingViewController] presentingViewController] presentingViewController] dismissViewControllerAnimated:YES completion:nil];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
