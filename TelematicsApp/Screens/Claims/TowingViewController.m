//
//  TowingViewController.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 01.04.21.
//  Copyright © 2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "TowingViewController.h"
#import "Step1ViewController.h"
#import "Color.h"
#import "Helpers.h"
#import "UIViewController+Preloader.h"


@interface TowingViewController ()

@property (weak, nonatomic) IBOutlet UIButton   *backBtn;
@property (weak, nonatomic) IBOutlet UIButton   *nextBtn;

@end

@implementation TowingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.nextBtn setTintColor:[Color officialWhiteColor]];
    [self.nextBtn setBackgroundColor:[Color officialMainAppColor]];
    [self.nextBtn.layer setMasksToBounds:YES];
    [self.nextBtn.layer setCornerRadius:15.0f];
    
    [self setupButtons];
    [self setupCachedData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:true];
}

- (void)setupButtons
{
    NSInteger margin = 70;
    
    self.drivableSwitcher = [[TagsSwitch alloc] initWithStringsArray:@[@"YES", @"NO"]];
    self.drivableSwitcher.frame = CGRectMake(margin, margin * 3, self.view.frame.size.width - margin * 2, 40);
    self.drivableSwitcher.font = [Font medium15Helvetica];
    self.drivableSwitcher.labelTextColorOutsideSlider = [UIColor darkGrayColor];
    self.drivableSwitcher.labelTextColorInsideSlider = [UIColor darkGrayColor];
    self.drivableSwitcher.backgroundColor = [Color grayColor];
    self.drivableSwitcher.sliderColor = [Color officialWhiteColor];
    self.drivableSwitcher.sliderOffset = 1.0;
    self.drivableSwitcher.cornerRadius = 20;
    [self.view addSubview:self.drivableSwitcher];
    [self.drivableSwitcher setPressedHandler:^(NSUInteger index) {
        if (index == 1) {
            [ClaimsService sharedService].CarDrivable = @"false";
        } else {
            [ClaimsService sharedService].CarDrivable = @"true";
        }
    }];
    
    self.towingSwitcher = [[TagsSwitch alloc] initWithStringsArray:@[@"YES", @"NO"]];
    self.towingSwitcher.frame = CGRectMake(margin, margin * 6, self.view.frame.size.width - margin * 2, 40);
    self.towingSwitcher.font = [Font medium15Helvetica];
    self.towingSwitcher.labelTextColorOutsideSlider = [UIColor darkGrayColor];
    self.towingSwitcher.labelTextColorInsideSlider = [UIColor darkGrayColor];
    self.towingSwitcher.backgroundColor = [Color grayColor];
    self.towingSwitcher.sliderColor = [Color officialWhiteColor];
    self.towingSwitcher.sliderOffset = 1.0;
    self.towingSwitcher.cornerRadius = 20;
    [self.view addSubview:self.towingSwitcher];
    [self.towingSwitcher forceSelectedIndex:1 animated:NO];
    [self.towingSwitcher setPressedHandler:^(NSUInteger index) {
        if (index == 1) {
            [ClaimsService sharedService].CarTowing = @"false";
        } else {
            [ClaimsService sharedService].CarTowing = @"true";
        }
    }];
    
    [self.nextBtn addTarget:self action:@selector(nextBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self.backBtn addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setupCachedData {
    if ([ClaimsService sharedService].CarDrivable != nil) {
        if ([[ClaimsService sharedService].CarDrivable isEqualToString:@"true"]) {
            [ClaimsService sharedService].CarDrivable = @"true";
            [self.drivableSwitcher selectIndex:0 animated:NO];
        } else {
            [ClaimsService sharedService].CarDrivable = @"false";
            [self.drivableSwitcher selectIndex:1 animated:NO];
        }
    } else {
        [ClaimsService sharedService].CarDrivable = @"true";
        [self.drivableSwitcher selectIndex:0 animated:NO];
    }
    
    if ([ClaimsService sharedService].CarTowing != nil) {
        if ([[ClaimsService sharedService].CarTowing isEqualToString:@"true"]) {
            [ClaimsService sharedService].CarTowing = @"true";
            [self.towingSwitcher selectIndex:0 animated:NO];
        } else {
            [ClaimsService sharedService].CarTowing = @"false";
            [self.towingSwitcher selectIndex:1 animated:NO];
        }
    } else {
        [ClaimsService sharedService].CarTowing = @"false";
        [self.towingSwitcher selectIndex:1 animated:NO];
    }
}


#pragma mark - Navigation

- (IBAction)dismissAction:(id)sender {
    [[[self presentingViewController] presentingViewController] dismissViewControllerAnimated:YES completion:nil];
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

- (void)nextBtnAction {
    Step1ViewController* step1 = [self.storyboard instantiateViewControllerWithIdentifier:@"Step1ViewController"];
    step1.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self presentViewController:step1 animated:NO completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
