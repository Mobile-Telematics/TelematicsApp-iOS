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

+ (instancetype)sharedService {
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
    defaults_set_object(@"autUserGender", self.stored_gender);
    defaults_set_object(@"autUserMaritalStatus", self.stored_maritalStatus);
    defaults_set_object(@"autUserChildrenCount", self.stored_childrenCount);
    defaults_set_object(@"autUserClientId", self.stored_clientId);
    defaults_set_object(@"authUserProfilePictureLink", self.stored_profilePictureLink);
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
    self.stored_gender = [[NSUserDefaults standardUserDefaults] valueForKey:@"autUserGender"];
    self.stored_maritalStatus = [[NSUserDefaults standardUserDefaults] valueForKey:@"autUserMaritalStatus"];
    self.stored_childrenCount = [[NSUserDefaults standardUserDefaults] valueForKey:@"autUserChildrenCount"];
    self.stored_clientId = [[NSUserDefaults standardUserDefaults] valueForKey:@"autUserClientId"];
    self.stored_profilePictureLink = [[NSUserDefaults standardUserDefaults] valueForKey:@"authUserProfilePictureLink"];
    
    if (self.device_token_number) {
        self.isLoggedOn = YES;
    }
}

- (void)loadProfile {
    if (self.isLoggedOn) {
        
        //FETCH USER PROFILE UPDATES FROM FIREBASE EVERY TIME IF NEEDED
        self.realtimeDatabase = [[FIRDatabase database] reference];
        
        FIRDatabaseQuery *allUserData = [[self.realtimeDatabase child:@"users"] child:[GeneralService sharedService].firebase_user_id];
        [allUserData observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {

            if (snapshot.value == [NSNull null]) {
                NSLog(@"No user data!");
            } else {
                
                //GET SNAPSHOT USER DATA FROM FIREBASE DATABASE
                NSDictionary *allUsersData = (NSDictionary*)snapshot.value;
                
                [GeneralService sharedService].device_token_number = allUsersData[@"deviceToken"];
                [GeneralService sharedService].firebase_user_id = allUsersData[@"userId"];
                
                [GeneralService sharedService].stored_userEmail = allUsersData[@"email"];
                [GeneralService sharedService].stored_userPhone = allUsersData[@"phone"];
                [GeneralService sharedService].stored_firstName = allUsersData[@"firstName"];
                [GeneralService sharedService].stored_lastName = allUsersData[@"lastName"];
                [GeneralService sharedService].stored_birthday = allUsersData[@"birthday"];
                [GeneralService sharedService].stored_address = allUsersData[@"address"];
                [GeneralService sharedService].stored_gender = allUsersData[@"gender"];
                [GeneralService sharedService].stored_maritalStatus = allUsersData[@"maritalStatus"];
                [GeneralService sharedService].stored_childrenCount = allUsersData[@"childrenCount"];
                [GeneralService sharedService].stored_clientId = allUsersData[@"clientId"];
                [GeneralService sharedService].stored_profilePictureLink = allUsersData[@"profilePictureLink"];
                
                NSLog(@"deviceToken %@", [GeneralService sharedService].device_token_number);
                NSLog(@"firebaseId %@", [GeneralService sharedService].firebase_user_id);
                NSLog(@"email %@", [GeneralService sharedService].stored_userEmail);
                NSLog(@"phone %@", [GeneralService sharedService].stored_userPhone);
                NSLog(@"firstName %@", [GeneralService sharedService].stored_firstName);
                NSLog(@"lastName %@", [GeneralService sharedService].stored_lastName);
                NSLog(@"birthday %@", [GeneralService sharedService].stored_birthday);
                NSLog(@"address %@", [GeneralService sharedService].stored_address);
                NSLog(@"gender %@", [GeneralService sharedService].stored_gender);
                NSLog(@"maritalStatus %@", [GeneralService sharedService].stored_maritalStatus);
                NSLog(@"childrenCount %@", [GeneralService sharedService].stored_childrenCount);
                NSLog(@"clientId %@", [GeneralService sharedService].stored_clientId);
                NSLog(@"profilePictureLink %@", [GeneralService sharedService].stored_profilePictureLink);
                
                [self applyProfileInformationInCore];
            }
        }];
    }
}

- (void)applyProfileInformationInCore {
    
    self.appModel = [ZenAppModel MR_findFirstByAttribute:@"current_user" withValue:@1];
    
    self.appModel.userFirebaseId = [GeneralService sharedService].firebase_user_id;
    self.appModel.userEmail = [GeneralService sharedService].stored_userEmail;
    self.appModel.userPhone = [GeneralService sharedService].stored_userPhone;
    self.appModel.userFirstName = [GeneralService sharedService].stored_firstName;
    self.appModel.userLastName = [GeneralService sharedService].stored_lastName;
    self.appModel.userBirthday = [GeneralService sharedService].stored_birthday;
    self.appModel.userAddress = [GeneralService sharedService].stored_address;
    self.appModel.userGender = [GeneralService sharedService].stored_gender;
    self.appModel.userMaritalStatus = [GeneralService sharedService].stored_maritalStatus;
    self.appModel.userChildrenCount = [GeneralService sharedService].stored_childrenCount;
    self.appModel.userClientId = [GeneralService sharedService].stored_clientId;
    self.appModel.userProfilePictureLink = [GeneralService sharedService].stored_profilePictureLink;
    self.appModel.userFullName = [NSString stringWithFormat:@"%@ %@", [GeneralService sharedService].stored_firstName, [GeneralService sharedService].stored_lastName];
    
    if (self.isLoggedOn) {
        [self saveCredentials];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateProfileTableDataNow" object:self];
    
    dispatch_async(dispatch_get_global_queue(0,0), ^{
        NSData * data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:self.appModel.userProfilePictureLink]];
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
