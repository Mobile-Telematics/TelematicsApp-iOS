//
//  ProfileViewController.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 26.11.21.
//  Copyright © 2019-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "ProfileViewController.h"
#import "UserImagePickerViewController.h"
#import "SettingsViewController.h"
#import "ProfilePopupDelegate.h"
#import "ProfileLicensePopup.h"
#import "LicenseCell.h"
#import "CarCell.h"
#import "VehicleObject.h"
#import "UIViewController+Preloader.h"
#import "UIImage+FixOrientation.h"
#import "HapticHelper.h"
#import "ProfileResultResponse.h"
#import "ProfileResponse.h"
#import "EditProfileCtrl.h"
#import "EditVehicleCtrl.h"
#import "Helpers.h"
#import "NSDate+UI.h"
#import "NSDate+ISO8601.h"
#import "KVNProgress.h"


@interface ProfileViewController () <UITableViewDelegate, UITableViewDataSource, UserImagePickerViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView        *tableView;
@property (weak, nonatomic) IBOutlet UIView             *mainView;
@property (weak, nonatomic) IBOutlet UIView             *verifiedProfileView;
@property (weak, nonatomic) IBOutlet UILabel            *verifiedGreenLabel;
@property (weak, nonatomic) IBOutlet UILabel            *userNameLbl;
@property (weak, nonatomic) IBOutlet UILabel            *userPhoneLbl;
@property (weak, nonatomic) IBOutlet UIImageView        *avatarImg;
@property (weak, nonatomic) IBOutlet UIButton           *backButton;
@property (weak, nonatomic) IBOutlet UIButton           *settingsButton;

@property (weak, nonatomic) NSString                    *vehicleTokenString;
@property (weak, nonatomic) NSString                    *plateString;
@property (weak, nonatomic) NSString                    *vinCodeStr;
@property (weak, nonatomic) NSString                    *manufacturerString;
@property (weak, nonatomic) NSString                    *modelString;
@property (weak, nonatomic) NSString                    *typeString;
@property (weak, nonatomic) NSString                    *nicknameString;
@property (weak, nonatomic) NSString                    *yearString;
@property (weak, nonatomic) NSString                    *mileageString;
@property (weak, nonatomic) NSString                    *paintingString;
@property (strong, nonatomic) NSArray                   *sectionsArr;

@property (strong, nonatomic) ZenAppModel               *appModel;
@property (nonatomic, strong) ProfileResultResponse     *profile;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //INITIALIZE USER APP MODEL
    self.appModel = [ZenAppModel MR_findFirstByAttribute:@"current_user" withValue:@1];
    
    UITabBarItem *tabBarItem4 = [self.tabBarController.tabBar.items objectAtIndex:[[Configurator sharedInstance].profileTabBarNumber intValue]];
    [tabBarItem4 setImage:[[UIImage imageNamed:@"profile_unselected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [tabBarItem4 setSelectedImage:[[UIImage imageNamed:@"profile_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [tabBarItem4 setTitle:localizeString(@"profile_title")];
    
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, self.view.opaque, 0.0);
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    [[UIImage imageNamed:[Configurator sharedInstance].mainBackgroundImg] drawInRect:self.view.bounds];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.view.backgroundColor = [UIColor colorWithPatternImage:img];
    
    self.mainView.layer.cornerRadius = 16;
    self.mainView.layer.masksToBounds = NO;
    self.mainView.layer.shadowOffset = CGSizeMake(0, 0);
    self.mainView.layer.shadowRadius = 2;
    self.mainView.layer.shadowOpacity = 0.1;
    
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.tableView.tableFooterView.bounds byRoundingCorners:(UIRectCornerBottomLeft | UIRectCornerBottomRight) cornerRadii:CGSizeMake(16.0, 16.0)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.view.bounds;
    maskLayer.path  = maskPath.CGPath;
    self.tableView.tableFooterView.layer.mask = maskLayer;
    
    if (self.hideBackButton == YES) {
        self.backButton.hidden = NO;
        self.settingsButton.hidden = YES;
    } else {
        self.backButton.hidden = YES;
        self.settingsButton.hidden = NO;
    }
    
    self.userNameLbl.text = self.appModel.userFullName ? self.appModel.userFullName : @"";
    
    self.avatarImg.layer.cornerRadius = self.avatarImg.frame.size.width / 2.0;
    self.avatarImg.layer.masksToBounds = YES;
    self.avatarImg.contentMode = UIViewContentModeScaleAspectFill;
    if (self.appModel.userPhotoData != nil) {
        self.avatarImg.image = [UIImage imageWithData:self.appModel.userPhotoData];
    }
    
    UITapGestureRecognizer* bigAvaTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showPickerBtnWasPressed:)];
    self.avatarImg.userInteractionEnabled = YES;
    [self.avatarImg addGestureRecognizer:bigAvaTap];
    
    self.verifiedGreenLabel.attributedText = [self createVerifedLabelImgBefore:localizeString(@"Verified Account")];
    self.verifiedGreenLabel.textColor = [Color officialGreenColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showCompletePopupNow) name:@"showCompletePopupNow" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateProfileTableDataWait) name:@"updateProfileTableDataWait" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateProfileTableDataNow) name:@"updateProfileTableDataNow" object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setMainUserAccount];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateProfileTableDataWait) name:@"updateProfileTableDataWait" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateProfileTableDataNow) name:@"updateProfileTableDataNow" object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Main UserInfo

- (void)setMainUserAccount {
    
    if (self.appModel.userPhotoData != nil) {
        self.avatarImg.image = [UIImage imageWithData:self.appModel.userPhotoData];
    }
    self.userNameLbl.text = self.appModel.userFullName ? self.appModel.userFullName : @"";
    self.userPhoneLbl.text = [NSString stringWithFormat:localizeString(@"Phone: %@"), self.appModel.userPhone];
    
    NSString *userEmail = self.appModel.userEmail;
    NSString *userPhone = self.appModel.userPhone;
    if ([userEmail isEqualToString:@""] || userEmail == nil) {
        if ([userPhone isEqualToString:@""] || userPhone == nil) {
            userPhone = localizeString(@"Not specified");
        }
        
        NSString *phSt = [NSString stringWithFormat:localizeString(@"Phone: %@"), userPhone];
        NSMutableAttributedString *phStAttString = [[NSMutableAttributedString alloc] initWithString:phSt];
        NSRange phRange = [phSt rangeOfString:localizeString(@"Phone:")];
        [phStAttString addAttribute:NSForegroundColorAttributeName value:[Color lightGrayColor] range:phRange];
        self.userPhoneLbl.attributedText = phStAttString;
        
    } else {
        NSString *emailSt = [NSString stringWithFormat:localizeString(@"Email: %@"), userEmail];
        NSMutableAttributedString *emailStAttString = [[NSMutableAttributedString alloc] initWithString:emailSt];
        NSRange emailRange = [emailSt rangeOfString:localizeString(@"Email:")];
        [emailStAttString addAttribute:NSForegroundColorAttributeName value:[Color lightGrayColor] range:emailRange];
        self.userPhoneLbl.attributedText = emailStAttString;
    }
    
    if (![userEmail isEqualToString:@""] && userEmail != nil && ![userPhone isEqualToString:@""] && userPhone != nil) {
        self.verifiedGreenLabel.attributedText = [self createVerifedLabelImgBefore:localizeString(@"Verified Account")];
        self.verifiedGreenLabel.textColor = [Color officialGreenColor];
    } else {
        self.verifiedGreenLabel.attributedText = [self createNotVerifedLabelImgBefore:localizeString(@"Verified Account")];
        self.verifiedGreenLabel.textColor = [Color lightGrayColor];
    }
    
    self.verifiedProfileView.hidden = NO;
}


#pragma mark - UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        LicenseCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LicenseCell"];
        
        if (!cell) {
            cell = [[LicenseCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"LicenseCell"];
        }
        
        cell.licPlaceholder.hidden = YES;
        cell.userNameLbl.hidden = NO;
        
        if (self.appModel.userBirthday == nil || [self.appModel.userBirthday isEqual:@""]) {
            cell.userNameLbl.text = localizeString(@"Date of Birth\nNot specified");
        } else {
            NSDate *date = [NSDate dateWithISO8601String:self.appModel.userBirthday];
            NSString *fDate = [date dateStringFullMonth];
            cell.userNameLbl.text = [NSString stringWithFormat:localizeString(@"Date of Birth\n%@"), fDate];
        }
        
        cell.userLicNumLbl.hidden = NO;
        if (self.appModel.userAddress == nil || [self.appModel.userAddress isEqual:@""]) {
            cell.userLicNumLbl.text = localizeString(@"Address\nNot specified");
        } else {
            cell.userLicNumLbl.text = [NSString stringWithFormat:localizeString(@"Address\n%@"), self.appModel.userAddress];
        }
        
        return cell;
    } else {
        CarCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CarCell"];
        if (!cell) {
            cell = [[CarCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CarCell"];
        }
        
        if (self.appModel.vehicleShortData.count == 0) {
            cell.vehiclePlaceholder.attributedText = [self createPlusStringVehicle:localizeString(@"Add New Vehicle")];
            cell.vehiclePlaceholder.hidden = NO;
        } else {
            VehicleObject *obj = [self.appModel.vehicleShortData objectAtIndex:indexPath.row];
            cell.vehiclePlaceholder.hidden = YES;
            
            NSString *carModel = obj.Manufacturer ? obj.Manufacturer : localizeString(@"Car make not specified");
            if (obj.Manufacturer == nil || ([obj.Manufacturer isEqual:@""])) {
                cell.vehicleNameLbl.text = carModel;
            } else {
                cell.vehicleNameLbl.text = carModel; //[self createVerifedLabelImgAfter:carModel];
            }

            NSString *vinCode = obj.Vin ? obj.Vin : localizeString(@"Not specified");
            cell.vehicleLicNumLbl.text = [NSString stringWithFormat:localizeString(@"VIN: %@"), vinCode];
        }
        
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    CGFloat height = cell.frame.size.height;
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0)
        return 44.0;
    else
        return 44.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSArray *names = @[localizeString(@"Profile Information"), localizeString(@"Your Vehicles")];
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 30)];
    [view setBackgroundColor:[UIColor clearColor]];
    
    UIButton *addButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width-70, 2, 50, 50)];
    UILabel *lblSection = [[UILabel alloc] initWithFrame:CGRectMake(35, 15, tableView.frame.size.width, 45)];
    
    if (section == 0) {
        
        UIView *viewS = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 58)];
        [viewS setBackgroundColor:[Color officialWhiteColor]];
        viewS.layer.cornerRadius = 16.0f;
        viewS.layer.masksToBounds = YES;
        [view addSubview:viewS];
        
    } else if (section == 1) {
        
        lblSection = [[UILabel alloc] initWithFrame:CGRectMake(35, 5, tableView.frame.size.width, 45)];
        
        UIView *viewS = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 45)];
        [viewS setBackgroundColor:[Color officialWhiteColor]];
        viewS.layer.masksToBounds = YES;
        [view addSubview:viewS];
    }
    
    [lblSection setFont:[Font bold14]];
    NSString *stName = [names objectAtIndex:section];
    [lblSection setText:stName];
    [lblSection setTextColor:[Color blackColor]];
    [view addSubview:lblSection];
    [view addSubview:addButton];
    
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        
        EditProfileCtrl* pEdit = [self.storyboard instantiateViewControllerWithIdentifier:@"EditProfileCtrlNoMarital"];
        if (self.navigationController.presentingViewController) {
            [self.navigationController pushViewController:pEdit animated:YES];
        } else {
            [self presentViewController:pEdit animated:YES completion:nil];
        }
        
    } else if (indexPath.section == 1) {
        
        if (self.appModel.vehicleShortData.count == 0) {
            
            EditVehicleCtrl* vEdit = [self.storyboard instantiateViewControllerWithIdentifier:@"EditVehicleCtrl"];
            vEdit.newVehicle = YES;
            if (self.navigationController.presentingViewController) {
                [self.navigationController pushViewController:vEdit animated:YES];
            } else {
                [self presentViewController:vEdit animated:YES completion:nil];
            }
            
        } else {
            
            [HapticHelper generateFeedback:FeedbackTypeImpactMedium];
            VehicleObject *obj = [self.appModel.vehicleShortData objectAtIndex:indexPath.row];
            EditVehicleCtrl* vEdit = [self.storyboard instantiateViewControllerWithIdentifier:@"EditVehicleCtrl"];
            vEdit.newVehicle = NO;
            vEdit.vehicleTokenString = obj.Token;
            vEdit.vinCodeStr = obj.Vin;
            vEdit.manufacturerString = obj.Manufacturer;
            vEdit.plateString = obj.PlateNumber;
            vEdit.modelString = obj.Model;
            vEdit.typeString = obj.BodyType;
            vEdit.nicknameString = obj.Name;
            vEdit.yearString = obj.CarYear;
            vEdit.mileageString = obj.InitialMilage;
            vEdit.paintingString = obj.ColorType;
            
            if (self.navigationController.presentingViewController) {
                [self.navigationController pushViewController:vEdit animated:YES];
            } else {
                [self presentViewController:vEdit animated:YES completion:nil];
            }
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.tableView) {
        CGFloat y =  - scrollView.contentOffset.y - scrollView.contentInset.top;
        if (scrollView.contentOffset.y < 20 && scrollView.contentOffset.y > -90) {
            self.avatarImg.frame = CGRectMake(SCREEN_WIDTH/2-AVATAR_RADIUS-y/2, AVATAR_ORIGIN_Y - y, AVATAR_RADIUS * 2 + y, AVATAR_RADIUS * 2 + y);
            self.avatarImg.layer.cornerRadius = self.avatarImg.frame.size.width/2;
        }
        
        if (scrollView.contentOffset.y >= 0) {
            float percent = (70.0 / scrollView.contentOffset.y);
            self.settingsButton.alpha = percent;
            if (percent < 0.4)
                self.settingsButton.userInteractionEnabled = NO;
            else
                self.settingsButton.userInteractionEnabled = YES;
        } else if (scrollView.contentOffset.y < 90.0) {
            self.settingsButton.alpha = 1;
            self.settingsButton.userInteractionEnabled = YES;
        }
    }
}


#pragma mark - UserPikcerViewControllerDelegate

- (IBAction)showPickerBtnWasPressed:(id)sender {
    UserImagePickerViewController *imagePicker = [[UserImagePickerViewController alloc] init];
    imagePicker.delegate = self;
    [imagePicker showImagePickerInController:self animated:YES];
}

- (void)imagePicker:(UserImagePickerViewController *)imagePicker didSelectImage:(UIImage *)image {
    [self showPreloader];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.avatarImg.image = image;
        
        //USER PROFILE PICTURE TO NSDATA
        NSData *imageData = [UIImage scaleImageForAvatar:self.avatarImg.image];
        self.appModel.userPhotoData = imageData;
        [CoreDataCoordinator saveCoreDataCoordinatorContext];
        
        
        // SETUP FIREBASE CLOUD STORAGE
        // Get a reference to the storage service using the default Firebase App
        FIRStorage *storage = [FIRStorage storage];

        // Create a storage reference from our storage service
        FIRStorageReference *storageRef = [storage reference];
        
        NSString *fileName = [NSString stringWithFormat:@"profile_images/%@.png", [GeneralService sharedService].firebase_user_id];

        // Create a reference to the file you want to upload
        FIRStorageReference *riversRef = [storageRef child:fileName];

        // Upload the file to the path "images/rivers.jpg"
        FIRStorageUploadTask *uploadTask = [riversRef putData:imageData
                                                     metadata:nil
                                                   completion:^(FIRStorageMetadata *metadata,
                                                                NSError *error) {
          if (error != nil) {
            // Uh-oh, an error occurred!
          } else {
              // You can also access to download URL after upload.
              [riversRef downloadURLWithCompletion:^(NSURL * _Nullable URL, NSError * _Nullable error) {
                  if (error != nil) {
                      NSLog(@"Error occuued");
                      [self hidePreloader];
                  } else {
                      NSURL *downloadURL = URL;
                      
                      NSLog(@"STORE FINAL PROFILE PICTURE URL%@", downloadURL.absoluteString);
                      
                      
                      NSString *email = [GeneralService sharedService].stored_userEmail ? [GeneralService sharedService].stored_userEmail : @"";
                      NSString *phone = [GeneralService sharedService].stored_userPhone ? [GeneralService sharedService].stored_userPhone : @"";
                      NSString *firstName = [GeneralService sharedService].stored_firstName ? [GeneralService sharedService].stored_firstName : @"";
                      NSString *lastName = [GeneralService sharedService].stored_lastName ? [GeneralService sharedService].stored_lastName : @"";
                      NSString *birthday = [GeneralService sharedService].stored_birthday ? [GeneralService sharedService].stored_birthday : @"";
                      NSString *address = [GeneralService sharedService].stored_address ? [GeneralService sharedService].stored_address : @"";
                      NSString *gender = [GeneralService sharedService].stored_gender ? [GeneralService sharedService].stored_gender : @"";
                      NSString *marital = [GeneralService sharedService].stored_maritalStatus ? [GeneralService sharedService].stored_maritalStatus : @"";
                      NSString *children = [GeneralService sharedService].stored_childrenCount ? [GeneralService sharedService].stored_childrenCount : @"";
                      NSString *clientId = [GeneralService sharedService].stored_clientId ? [GeneralService sharedService].stored_clientId : @"";
                      //NSString *profilePictureLink = [GeneralService sharedService].stored_profilePictureLink ? [GeneralService sharedService].stored_profilePictureLink : @"";
                      
                      [GeneralService sharedService].stored_profilePictureLink = downloadURL.absoluteString;
                      NSLog(@"profilePictureLink %@", [GeneralService sharedService].stored_profilePictureLink);
                      
                      [[[[GeneralService sharedService].realtimeDatabase child:@"users"]
                                                 child:[GeneralService sharedService].firebase_user_id] setValue:@{@"deviceToken": [GeneralService sharedService].device_token_number,
                                                                                                                    @"userId": [GeneralService sharedService].firebase_user_id,
                                                                                                                    @"email": email,
                                                                                                                    @"phone": phone,
                                                                                                                    @"firstName": firstName,
                                                                                                                    @"lastName": lastName,
                                                                                                                    @"birthday": birthday,
                                                                                                                    @"address": address,
                                                                                                                    @"gender": gender,
                                                                                                                    @"maritalStatus": marital,
                                                                                                                    @"childrenCount": children,
                                                                                                                    @"clientId": clientId,
                                                                                                                    @"profilePictureLink": downloadURL.absoluteString
                                                 }
                       ];
                      
                      [uploadTask cancel];
                      
                      [[GeneralService sharedService] loadProfile];
                      [self setMainUserAccount];
                      
                      [self hidePreloader];
                  }
              }];
            }
        }];
    });
}


#pragma mark - Action Methods

- (IBAction)backBtnClick:(id)sender {
    if (self.navigationController.presentingViewController) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        if (@available(iOS 13.0, *)) {
            [self dismissViewControllerAnimated:YES completion:nil];
        } else {
            [self dismissViewControllerAnimated:NO completion:nil];
        }
    }
}

- (IBAction)settingsBtnAction:(id)sender {
    SettingsViewController *settingsVC = [[UIStoryboard storyboardWithName:@"Settings" bundle:nil] instantiateInitialViewController];
    [self presentViewController:settingsVC animated:YES completion:nil];
}


#pragma mark - Verifed Labels

- (NSMutableAttributedString*)createPlusStringVehicle:(NSString*)text {
    NSTextAttachment *imageAttachment = [[NSTextAttachment alloc] init];
    imageAttachment.image = [UIImage imageNamed:@"profile_plus_green"];
    imageAttachment.bounds = CGRectMake(0, -16, imageAttachment.image.size.width/2, imageAttachment.image.size.height/2);
    NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:imageAttachment];
    NSMutableAttributedString *completeText = [[NSMutableAttributedString alloc] initWithString:@""];
    [completeText appendAttributedString:attachmentString];
    NSMutableAttributedString *textAfterIcon = [[NSMutableAttributedString alloc] initWithString:text];
    [completeText appendAttributedString:textAfterIcon];
    return completeText;
}

- (NSMutableAttributedString*)createVerifedLabelImgAfter:(NSString*)text {
    NSTextAttachment *imageAttachment = [[NSTextAttachment alloc] init];
    imageAttachment.image = [UIImage imageNamed:@"profile_verifed"];
    imageAttachment.bounds = CGRectMake(5, -1, imageAttachment.image.size.width/1.7, imageAttachment.image.size.height/1.7);
    NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:imageAttachment];
    NSMutableAttributedString *completeText = [[NSMutableAttributedString alloc] initWithString:text];
    [completeText appendAttributedString:attachmentString];
    return completeText;
}

- (NSMutableAttributedString*)createVerifedLabelImgBefore:(NSString*)text {
    NSTextAttachment *imageAttachment = [[NSTextAttachment alloc] init];
    imageAttachment.image = [UIImage imageNamed:@"profile_verifed"];
    imageAttachment.bounds = CGRectMake(-6, -2, imageAttachment.image.size.width/1.5, imageAttachment.image.size.height/1.5);
    NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:imageAttachment];
    NSMutableAttributedString *completeText = [[NSMutableAttributedString alloc] initWithString:@"   "];
    [completeText appendAttributedString:attachmentString];
    NSMutableAttributedString *textAfterIcon = [[NSMutableAttributedString alloc] initWithString:text];
    [completeText appendAttributedString:textAfterIcon];
    return completeText;
}

- (NSMutableAttributedString*)createNotVerifedLabelImgBefore:(NSString*)text {
    NSTextAttachment *imageAttachment = [[NSTextAttachment alloc] init];
    imageAttachment.image = [UIImage imageNamed:@"profile_verifednot"];
    imageAttachment.bounds = CGRectMake(-6, -2, imageAttachment.image.size.width/1.5, imageAttachment.image.size.height/1.5);
    NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:imageAttachment];
    NSMutableAttributedString *completeText = [[NSMutableAttributedString alloc] initWithString:@"   "];
    [completeText appendAttributedString:attachmentString];
    NSMutableAttributedString *textAfterIcon = [[NSMutableAttributedString alloc] initWithString:text];
    [completeText appendAttributedString:textAfterIcon];
    return completeText;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - WizardPopup Reloading

- (void)updateProfileTableDataNow {
    [self setMainUserAccount];
    [self.tableView reloadData];
}

- (void)updateProfileTableDataWait {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self setMainUserAccount];
        [self.tableView reloadData];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self setMainUserAccount];
        [self.tableView reloadData];
    });
}

- (void)showCompletePopupNow {
    [HapticHelper generateFeedback:FeedbackTypeNotificationWarning];
    
    [UIView animateWithDuration:0 animations:^{
        [self setMainUserAccount];
    } completion:^(BOOL finished) {
        [self.tableView reloadData];
    }];
}

@end
