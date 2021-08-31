//
//  MainScoresViewCtrl.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 08.04.20.
//  Copyright © 2020-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "MainScoresViewCtrl.h"
#import "ScoreOverallVC.h"
#import "ScoreAccVC.h"
#import "ScoreDecVC.h"
#import "ScoreSpeedVC.h"
#import "ScorePhoneVC.h"
#import "ScoreCornerVC.h"
#import "ScoreTripsVC.h"
#import "ScoreMileageVC.h"
#import "ScoreTimeVC.h"

@interface MainScoresViewCtrl () <UIScrollViewDelegate>

@property (weak) IBOutlet UIScrollView              *containerScrollView;
@property (weak, nonatomic) IBOutlet UIImageView    *mainHeaderImg;
@property (weak, nonatomic) IBOutlet UILabel        *mainControllerTitle;
@property (nonatomic, assign) CGFloat               lastContentOffset;
@property BOOL                                      scrollDirectionDetermined;

- (void)addChildViewControllersOntoContainer:(NSArray *)controllersArr;

@end

@implementation MainScoresViewCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.mainHeaderImg.image = [UIImage imageNamed:[Configurator sharedInstance].mainBackgroundImg];
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Leaderboard" bundle:nil];
    
    ScoreOverallVC *overallVC = [storyBoard instantiateViewControllerWithIdentifier:@"ScoreOverallVC"];
    ScoreAccVC *accVC = [storyBoard instantiateViewControllerWithIdentifier:@"ScoreAccVC"];
    ScoreDecVC *decVC = [storyBoard instantiateViewControllerWithIdentifier:@"ScoreDecVC"];
    ScoreSpeedVC *speedVC = [storyBoard instantiateViewControllerWithIdentifier:@"ScoreSpeedVC"];
    ScorePhoneVC *phoneVC = [storyBoard instantiateViewControllerWithIdentifier:@"ScorePhoneVC"];
    ScoreCornerVC *cornerVC = [storyBoard instantiateViewControllerWithIdentifier:@"ScoreCornerVC"];
    ScoreTripsVC *tripsVC = [storyBoard instantiateViewControllerWithIdentifier:@"ScoreTripsVC"];
    ScoreMileageVC *mileageVC = [storyBoard instantiateViewControllerWithIdentifier:@"ScoreMileageVC"];
    ScoreTimeVC *timeVC = [storyBoard instantiateViewControllerWithIdentifier:@"ScoreTimeVC"];
    
    NSArray *leadersArray = @[overallVC, accVC, decVC, speedVC, phoneVC, cornerVC, tripsVC, mileageVC, timeVC];
    
    [self addChildViewControllersOntoContainer:leadersArray];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(nextPage:) name:@"leadersNextPage" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(prevPage:) name:@"leadersPrevPage" object:nil];
}


#pragma mark - Adding all related controllers in container

- (void)addChildViewControllersOntoContainer:(NSArray *)controllersArr
{
    for (int i = 0 ; i < controllersArr.count; i++)
    {
        UIViewController *vc = (UIViewController *)[controllersArr objectAtIndex:i];
        CGRect frame = CGRectMake(0, 0, self.containerScrollView.frame.size.width, self.containerScrollView.frame.size.height);
        frame.origin.x = SCREEN_WIDTH * i;
        vc.view.frame = frame;
        
        [self addChildViewController:vc];
        [self.containerScrollView addSubview:vc.view];
        [vc didMoveToParentViewController:self];
    }
    
    self.containerScrollView.contentSize = CGSizeMake(SCREEN_WIDTH * controllersArr.count + 1, self.containerScrollView.frame.size.height);
    self.containerScrollView.pagingEnabled = YES;
    //[self.containerScrollView setScrollEnabled:YES];
    self.containerScrollView.directionalLockEnabled = YES;
    self.containerScrollView.delegate = self;
    
    if (self.showPageNumber != 0)
        [self.containerScrollView setContentOffset:CGPointMake(self.containerScrollView.contentOffset.x + SCREEN_WIDTH*self.showPageNumber, 0) animated:NO];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    self.scrollDirectionDetermined = NO;
}


#pragma mark - Navigation

- (IBAction)nextPage:(id)sender {
    if (self.containerScrollView.contentOffset.x >= SCREEN_WIDTH*8) {
        [self.containerScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    } else {
        [self.containerScrollView setContentOffset:CGPointMake(self.containerScrollView.contentOffset.x + SCREEN_WIDTH, 0) animated:YES];
    }
}

- (IBAction)prevPage:(id)sender {
    if (self.containerScrollView.contentOffset.x <= 1) {
        [self.containerScrollView setContentOffset:CGPointMake(self.containerScrollView.contentOffset.x + SCREEN_WIDTH*8, 0) animated:YES];
    } else {
        [self.containerScrollView setContentOffset:CGPointMake(self.containerScrollView.contentOffset.x - SCREEN_WIDTH, 0) animated:YES];
    }
    
}

- (IBAction)backAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
