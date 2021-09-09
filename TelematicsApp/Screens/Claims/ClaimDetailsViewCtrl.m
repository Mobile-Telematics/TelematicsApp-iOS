//
//  ClaimDetailsViewCtrl.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 01.04.21.
//  Copyright © 2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "ClaimDetailsViewCtrl.h"
#import "ClaimReviewViewCtrl.h"
#import "Color.h"
#import "NSDate+ISO8601.h"
#import "NSDate+UI.h"
#import "UIViewController+Preloader.h"

@interface ClaimDetailsViewCtrl () <UIScrollViewDelegate>

@property (strong, nonatomic) TelematicsAppModel                   *appModel;
@property (weak, nonatomic) IBOutlet UILabel                *mainLbl;
@property (weak, nonatomic) IBOutlet UIButton               *processingBtn;
@property (weak, nonatomic) IBOutlet UILabel                *dateLbl;
@property (weak, nonatomic) IBOutlet UILabel                *caseNumberLbl;
@property (weak, nonatomic) IBOutlet UILabel                *supportLbl;

@property (weak, nonatomic) IBOutlet UIButton               *supportClaimBtn;
@property (weak, nonatomic) IBOutlet UIButton               *viewDetailsClaimBtn;
@property (weak, nonatomic) IBOutlet UIButton               *deleteClaimBtn;

@end

@implementation ClaimDetailsViewCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //INITIALIZE USER APP MODEL
    self.appModel = [TelematicsAppModel MR_findFirstByAttribute:@"current_user" withValue:@1];
    
    [self.processingBtn setTintColor:[Color officialOrangeColor]];
    [self.processingBtn setTitleColor:[Color officialOrangeColor] forState:UIControlStateNormal];
    [self.processingBtn.layer setBorderColor:[Color officialOrangeColor].CGColor];
    [self.processingBtn.layer setBorderWidth:1.5];
    [self.processingBtn.layer setMasksToBounds:YES];
    [self.processingBtn.layer setCornerRadius:22.0f];
    
    [self setupSelectedClaimView];
    
    if (IS_IPHONE_5 || IS_IPHONE_4) {
        [self.supportClaimBtn addConstraint:[NSLayoutConstraint constraintWithItem:self.supportClaimBtn
                                                                         attribute:NSLayoutAttributeHeight
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:nil
                                                                         attribute:NSLayoutAttributeNotAnAttribute
                                                                        multiplier:1
                                                                          constant:53]];
        
        [self.viewDetailsClaimBtn addConstraint:[NSLayoutConstraint constraintWithItem:self.viewDetailsClaimBtn
                                                                             attribute:NSLayoutAttributeHeight
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:nil
                                                                             attribute:NSLayoutAttributeNotAnAttribute
                                                                            multiplier:1
                                                                              constant:53]];
        
        [self.deleteClaimBtn addConstraint:[NSLayoutConstraint constraintWithItem:self.deleteClaimBtn
                                                                        attribute:NSLayoutAttributeHeight
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:nil
                                                                        attribute:NSLayoutAttributeNotAnAttribute
                                                                       multiplier:1
                                                                         constant:53]];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:true];
}

- (void)setupSelectedClaimView {
    
    NSString *dateClaimFormat = localizeString(@"Not specified");
    NSString *claimDateTime = [self.selectedClaim valueForKey:@"ClaimDateTime"] ? [self.selectedClaim valueForKey:@"ClaimDateTime"] :localizeString(@"Not specified");
    if (![claimDateTime isEqual:[NSNull null]]) {
        NSDate *date = [NSDate dateWithISO8601String:claimDateTime];
        dateClaimFormat = [date dateString];
    } else {
        dateClaimFormat = localizeString(@"Not specified");
    }
    
    NSString *detectAccident = [self.selectedClaim valueForKey:@"AccidentType"];
    NSString *accName = @"Other";
    if (detectAccident != nil) {
        if ([detectAccident isEqualToString:@"road_accident"]) {
            accName = @"Road Accident";
        } else if ([detectAccident isEqualToString:@"fire_damage"]) {
            accName = @"Fire Damage";
        } else if ([detectAccident isEqualToString:@"cataclysm"]) {
            accName = @"Cataclysm";
        } else if ([detectAccident isEqualToString:@"hijacking"]) {
            accName = @"Hijacking";
        } else if ([detectAccident isEqualToString:@"vandalism"]) {
            accName = @"Vandalism";
        } else if ([detectAccident isEqualToString:@"vandalism"]) {
            accName = @"Vandalism";
        } else if ([detectAccident isEqualToString:@"glass_damage"]) {
            accName = @"Glass Damage";
        } else if ([detectAccident isEqualToString:@"animals"]) {
            accName = @"Animals";
        } else {
            accName = @"Other";
        }
    }
    
    _mainLbl.text = accName;
    _dateLbl.text = dateClaimFormat;
    _caseNumberLbl.text = [[self.selectedClaim valueForKey:@"Id"] stringValue];
    
    _supportLbl.text = @"Is pending";
    
    NSString *stateNow = [self.selectedClaim valueForKey:@"State"];
    if ([stateNow isEqualToString:@"draft"]) {
        [self.processingBtn setTitle:@"DRAFT" forState:UIControlStateNormal];
    } else if ([stateNow isEqualToString:@"processing"]) {
        [self.processingBtn setTitle:@"SENT" forState:UIControlStateNormal];
    } else if ([stateNow isEqualToString:@"pending"]) {
        [self.processingBtn setTitle:@"PENDING" forState:UIControlStateNormal];
    } else if ([stateNow isEqualToString:@"hold"]) {
        [self.processingBtn setTitle:@"HOLD" forState:UIControlStateNormal];
    } else if ([stateNow isEqualToString:@"rejected"]) {
        [self.processingBtn setTitle:@"REJECTED" forState:UIControlStateNormal];
    } else if ([stateNow isEqualToString:@"approved"]) {
        [self.processingBtn setTitle:@"PROCESSING" forState:UIControlStateNormal];
    } else if ([stateNow isEqualToString:@"quote"]) {
        [self.processingBtn setTitle:@"PROCESSING" forState:UIControlStateNormal];
    } else if ([stateNow isEqualToString:@"executed"]) {
        [self.processingBtn setTitle:@"PROCESSING" forState:UIControlStateNormal];
    } else {
        [self.processingBtn setTitle:@"DRAFT" forState:UIControlStateNormal];
    }
}


#pragma mark - Navigation

- (IBAction)contactSupportBtnClick:(id)sender {
    //TODO
}

- (IBAction)viewDetailsBtnClick:(id)sender {
    ClaimReviewViewCtrl* reviewClaim = [self.storyboard instantiateViewControllerWithIdentifier:@"ClaimReviewViewCtrl"];
    reviewClaim.selectedClaim = self.selectedClaim;
    reviewClaim.hideBottomButtons = YES;
    reviewClaim.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self presentViewController:reviewClaim animated:YES completion:nil];
}

- (IBAction)deleteThisClaim:(id)sender {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:localizeString(@"Deleting")
                                                                   message:localizeString(@"Are you sure you want to delete this Claim?")
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:localizeString(@"Yes") style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        [self removeThisClaimNow];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:localizeString(@"Cancel") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
    }];
    [alert addAction:yesAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)removeThisClaimNow {
    [self showPreloader];
    
    NSString *cId = [self.selectedClaim valueForKey:@"Id"];
    [[MainApiRequest requestWithCompletion:^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self hidePreloader];
            [self dismissViewControllerAnimated:YES completion:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"claimsNeedUpdateNow" object:self];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"claimsNeedUpdateNow" object:self];
            });
        });
    }] deleteUserClaim:cId];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self hidePreloader];
    });
}


- (IBAction)dismissAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
