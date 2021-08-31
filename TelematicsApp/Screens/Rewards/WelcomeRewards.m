//
//  WelcomeRewards.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 17.08.21.
//  Copyright © 2020-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "WelcomeRewards.h"

@interface WelcomeRewards () <UIScrollViewDelegate>

@property (strong, nonatomic) TelematicsAppModel *appModel;

@property (weak, nonatomic) IBOutlet UILabel            *mainLbl;
@property (weak, nonatomic) IBOutlet UIButton           *startBtn;
@property (weak, nonatomic) IBOutlet UIButton           *supportBtn;
@property (weak, nonatomic) IBOutlet UILabel            *additionalLbl;
@property (weak, nonatomic) IBOutlet UIImageView        *moneyImg;

@end

//WELCOME REWARDS SCREEN FOR DRIVECOINS SAMPLE FOR YOU
@implementation WelcomeRewards

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //INITIALIZE USER APP MODEL
    self.appModel = [TelematicsAppModel MR_findFirstByAttribute:@"current_user" withValue:@1];
    
    UIFont *supportFont = [Font semibold13];
    NSMutableAttributedString *supportText = [[NSMutableAttributedString alloc] initWithString:localizeString(@"Support")];
    [supportText addAttribute:NSFontAttributeName value:supportFont range:NSMakeRange(0, [supportText length])];
    [supportText addAttribute:NSForegroundColorAttributeName value:[Color lightGrayColor] range:NSMakeRange(0, [supportText length])];
    [supportText addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange(0, [supportText length])];
    [self.supportBtn setAttributedTitle:supportText forState:UIControlStateNormal];
    
    NSString *totalLbl1 = localizeString(@"You are about to earn some ");
    NSString *totalLbl2 = localizeString(@"DriveCoins!");
    NSString *totalMainLbl = [NSString stringWithFormat:@"%@%@", totalLbl1, totalLbl2];
    NSMutableAttributedString *completeText = [[NSMutableAttributedString alloc] initWithString:totalMainLbl];
    UIFont *moneyFont = [Font semibold22];
    NSRange range = [totalMainLbl rangeOfString:totalLbl2];
    [completeText addAttribute:NSFontAttributeName value:moneyFont range:range];
    self.mainLbl.attributedText = completeText;
    
    [self.startBtn setTintColor:[Color officialWhiteColor]];
    [self.startBtn.layer setMasksToBounds:YES];
    [self.startBtn.layer setCornerRadius:20.0f];
    [self.startBtn setBackgroundColor:[Color officialMainAppColor]];
    [self.startBtn setTitle:localizeString(@"START NOW") forState:UIControlStateNormal];
    
    self.moneyImg.image = [UIImage imageNamed:@"money_rewards_big"];
    
    self.additionalLbl.text = localizeString(@"Get rewarded for your good driving habits, save on fuel & maintenance costs.");
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (IBAction)dismissWelcome:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}


@end
