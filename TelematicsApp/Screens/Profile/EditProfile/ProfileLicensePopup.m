//
//  ProfileLicensePopup.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 11.02.21.
//  Copyright © 2019-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "ProfileLicensePopup.h"
#import "ProfilePopupDelegate.h"

@interface ProfileLicensePopup ()

@end

@implementation ProfileLicensePopup

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [Color officialWhiteColor];
}

- (IBAction)dismissBtnEvent:(UIButton *)sender {
    [self dismissPopUpViewController];
}

- (IBAction)editBtnEvent:(UIButton *)sender {
    [self dismissPopUpViewController];
}

- (void)dealloc
{
    NSLog(@"dealloc");
}

@end
