//
//  GeneralService.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 20.01.18.
//  Copyright © 2019-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "GeneralService.h"
#import "AppDelegate.h"
#import "SDImageCache.h"
#import "SDWebImageManager.h"
#import "UIImageView+WebCache.h"
#import "ProfileResponse.h"
#import "RefreshTokenRequestData.h"
#import "VehicleResponse.h"


@interface GeneralService ()

@property (strong, nonatomic) ZenAppModel                   *appModel;
@property (nonatomic, assign) BOOL                          isLoggedOn;

@property (nonatomic, strong) VehicleResultResponse         *vehicles;

@end

@implementation GeneralService

+ (instancetype)sharedInstance {
    static GeneralService *_sharedService = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedService = [[GeneralService alloc] init];
        [_sharedService loadCredentials];
    });
    return _sharedService;
}

- (void)saveCredentials {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];

    NSString *fileTokenKey = [NSString stringWithFormat:@"%@/authBearerTokenKey.txt", documentsDirectory];
    NSString *contentTK = self.jwt_token_number;
    [contentTK writeToFile:fileTokenKey atomically:NO encoding:NSStringEncodingConversionAllowLossy error:nil];

    NSString *fileRefreshKey = [NSString stringWithFormat:@"%@/authBearerRefreshTokenKey.txt", documentsDirectory];
    NSString *contentRT = self.refresh_token_number;
    [contentRT writeToFile:fileRefreshKey atomically:NO encoding:NSStringEncodingConversionAllowLossy error:nil];

    defaults_set_object(@"authUserDeviceToken", self.device_token_number);
    defaults_set_object(@"authUserFirebaseId", self.firebase_user_id);
    
    defaults_set_object(@"authUserEmail", self.stored_userEmail);
    defaults_set_object(@"authUserPhone", self.stored_userPhone);
    defaults_set_object(@"authUserFirstName", self.stored_firstName);
    defaults_set_object(@"authUserLastName", self.stored_lastName);
    defaults_set_object(@"authUserBirthday", self.stored_birthday);
    defaults_set_object(@"authUserAddress", self.stored_address);
    defaults_set_object(@"autUserClientId", self.stored_clientId);
    defaults_set_object(@"authUserAvatarLink", self.stored_avatarLink);
}

- (void)loadCredentials {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];

    NSString *fileTokenKey = [NSString stringWithFormat:@"%@/authBearerTokenKey.txt", documentsDirectory];
    NSString *tokenJWT = [[NSString alloc] initWithContentsOfFile:fileTokenKey usedEncoding:nil error:nil];
    self.jwt_token_number = tokenJWT;

    NSString *fileRefreshKey = [NSString stringWithFormat:@"%@/authBearerRefreshTokenKey.txt", documentsDirectory];
    NSString *tokenRefresh = [[NSString alloc] initWithContentsOfFile:fileRefreshKey usedEncoding:nil error:nil];
    self.refresh_token_number = tokenRefresh;

    self.device_token_number = [[NSUserDefaults standardUserDefaults] valueForKey:@"authUserDeviceToken"];
    self.firebase_user_id = [[NSUserDefaults standardUserDefaults] valueForKey:@"authUserFirebaseId"];
    
    self.stored_userEmail =  [[NSUserDefaults standardUserDefaults] valueForKey:@"authUserEmail"];
    self.stored_userPhone = [[NSUserDefaults standardUserDefaults] valueForKey:@"authUserPhone"];
    self.stored_firstName = [[NSUserDefaults standardUserDefaults] valueForKey:@"authUserFirstName"];
    self.stored_lastName = [[NSUserDefaults standardUserDefaults] valueForKey:@"authUserLastName"];
    self.stored_birthday = [[NSUserDefaults standardUserDefaults] valueForKey:@"authUserBirthday"];
    self.stored_address = [[NSUserDefaults standardUserDefaults] valueForKey:@"authUserAddress"];
    self.stored_clientId = [[NSUserDefaults standardUserDefaults] valueForKey:@"autUserClientId"];
    self.stored_avatarLink = [[NSUserDefaults standardUserDefaults] valueForKey:@"authUserAvatarLink"];
    
    if (self.device_token_number) {
        self.isLoggedOn = YES;
    }
}

- (void)loadProfile {
    
    self.appModel = [ZenAppModel MR_findFirstByAttribute:@"current_user" withValue:@1];
    
    NSLog(@"deviceToken %@", [GeneralService sharedInstance].device_token_number);
    NSLog(@"firebaseId %@", [GeneralService sharedInstance].firebase_user_id);
    NSLog(@"email %@", [GeneralService sharedInstance].stored_userEmail);
    NSLog(@"phone %@", [GeneralService sharedInstance].stored_userPhone);
    NSLog(@"firstName %@", [GeneralService sharedInstance].stored_firstName);
    NSLog(@"lastName %@", [GeneralService sharedInstance].stored_lastName);
    NSLog(@"birthday %@", [GeneralService sharedInstance].stored_birthday);
    NSLog(@"address %@", [GeneralService sharedInstance].stored_address);
    NSLog(@"clientId %@", [GeneralService sharedInstance].stored_clientId);
    NSLog(@"avatarLink %@", [GeneralService sharedInstance].stored_avatarLink);
    
    self.appModel.userFirebaseId = [GeneralService sharedInstance].firebase_user_id;
    self.appModel.userEmail = [GeneralService sharedInstance].stored_userEmail;
    self.appModel.userPhone = [GeneralService sharedInstance].stored_userPhone;
    self.appModel.userFirstName = [GeneralService sharedInstance].stored_firstName;
    self.appModel.userLastName = [GeneralService sharedInstance].stored_lastName;
    self.appModel.userBirthday = [GeneralService sharedInstance].stored_birthday;
    self.appModel.userAddress = [GeneralService sharedInstance].stored_address;
    self.appModel.userClientId = [GeneralService sharedInstance].stored_clientId;
    self.appModel.userAvatarLink = [GeneralService sharedInstance].stored_avatarLink;
    self.appModel.userFullName = [NSString stringWithFormat:@"%@ %@", [GeneralService sharedInstance].stored_firstName, [GeneralService sharedInstance].stored_lastName];
    
    if (self.isLoggedOn) {
        [self saveCredentials];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateProfileTableDataNow" object:self];
    
    dispatch_async(dispatch_get_global_queue(0,0), ^{
        NSData * data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:self.appModel.userAvatarLink]];
        if (data != nil) {
            self.appModel.userPhotoData = data;
        }
        [CoreDataCoordinator saveCoreDataCoordinatorContext];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"updateUserInfo" object:self];
    });
    
    [self loadUserVehicles]; //IF YOU USE CARSERVICE LOAD USER VEHICLES AND STORE IT'S
}


#pragma mark CarService

- (void)loadUserVehicles {
    
    [[MainApiRequest requestWithCompletion:^(id response, NSError *error) {
        if (!error && [response isSuccesful]) {
            self.vehicles = ((VehicleResponse *)response).Result;
            NSArray *reversedCars = [[self.vehicles.Cars reverseObjectEnumerator] allObjects];
            self.appModel.vehicleShortData = [reversedCars mutableCopy];
            [CoreDataCoordinator saveCoreDataCoordinatorContext];
            
//            self.vehicles = [((VehicleResponse *)response).Result valueForKey:@"Cars"];
//            NSMutableArray *carsArray = [self.vehicles mutableCopy];
            
//            NSArray *reversedCars = [[carsArray reverseObjectEnumerator] allObjects];
//            self.appModel.vehicleShortData = [reversedCars mutableCopy];
//            [CoreDataCoordinator saveCoreDataCoordinatorContext];
        } else {
            self.vehicles = ((VehicleResponse *)response).Result;
        }
    }] getUserAllVehicles];
}


#pragma mark Login/Logout

- (void)enterUserInAppWith:(NSString*)deviceToken jwToken:(NSString*)jwToken refreshToken:(NSString*)refreshToken {
    self.isLoggedOn = YES;
    [self saveCredentials];
    
    [[AppDelegate appDelegate] updateRootController];
    [self loadProfile];
}

- (void)refreshJWToken:(RegResponse*)login {
    self.jwt_token_number = login.Result.AccessToken.Token;
    self.refresh_token_number = login.Result.RefreshToken;
    self.device_token_number = defaults_object(@"authUserDeviceToken");
    [self saveCredentials];
}

- (void)logout {
    self.appModel.notFirstRunApp = NO;
    
    [ZenAppModel MR_deleteAllMatchingPredicate:[NSPredicate predicateWithFormat:@"current_user == 1"]];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *fileTokenKey = [NSString stringWithFormat:@"%@/authBearerTokenKey.txt", documentsDirectory];
    [[NSFileManager defaultManager] removeItemAtPath:fileTokenKey error:nil];

    NSString *fileRefreshKey = [NSString stringWithFormat:@"%@/authBearerRefreshTokenKey.txt", documentsDirectory];
    [[NSFileManager defaultManager] removeItemAtPath:fileRefreshKey error:nil];
    
    NSUserDefaults* defs = [NSUserDefaults standardUserDefaults];
    [defs removeObjectForKey:@"authBearerTokenKey"];
    [defs removeObjectForKey:@"authBearerRefreshTokenKey"];
    [defs removeObjectForKey:@"authUserDeviceToken"];
    [defs removeObjectForKey:@"counterRefreshKey"];
    [defs removeObjectForKey:@"counterMainReset"];
    
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [defs removePersistentDomainForName:appDomain];
    [defs synchronize];
    
    [[RPEntry instance] removeVirtualDeviceToken];
    
    self.isLoggedOn = NO;
    self.jwt_token_number = nil;
    self.refresh_token_number = nil;
    self.device_token_number = nil;
    defaults_set_object(@"userLogOuted", @(YES));
    NSLog(@"%@", [[NSUserDefaults standardUserDefaults] dictionaryRepresentation]);
    
    [[FIRAuth auth] signOut:nil];
    
    NSError *signOutError;
    BOOL status = [[FIRAuth auth] signOut:&signOutError];
    if (!status) {
        NSLog(@"Firebase error signing out: %@", signOutError);
    }
    
    [[AppDelegate appDelegate] updateRootController];
}

+ (void)alert:(NSString *)getmessage title:(NSString *)getTitle
{
    AppDelegate * appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:getTitle message:getmessage preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:ok];
    
    [appDelegate.window.rootViewController presentViewController:alertController animated:YES completion:nil];
}

@end
