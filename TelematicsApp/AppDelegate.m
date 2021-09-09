//
//  AppDelegate.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 09.06.21.
//  Copyright © 2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "AppDelegate.h"
#import "Configurator.h"
#import "CoreDataCoordinator.h"
#import <MagicalRecord/MagicalRecord.h>
#import "Helpers.h"
#import "MainPhoneViewCtrl.h"
#import "FeedViewController.h"
#import "WiFiGPSChecker.h"
#import <NMAKit/NMAKit.h>
#import <AdSupport/AdSupport.h>
#import <GoogleMaps/GoogleMaps.h>
@import GooglePlaces;

static NSString * const kRecipesStoreName = @"Model.sqlite";

@interface AppDelegate () <RPAccuracyAuthorizationDelegate, RPLowPowerModeDelegate>
@end


@implementation AppDelegate
    
+ (void)initialize {
    if ([self class] == [AppDelegate class]) {
        //
    }
}

+ (AppDelegate*)appDelegate {
    return (AppDelegate*)[UIApplication sharedApplication].delegate;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
    //SETUP FIREBASE FOR AUTH & DATABASE
    [FIRApp configure];
    
    [FIRDatabase database].persistenceEnabled = YES;
    FIRDatabaseReference *usersDatabase = [[FIRDatabase database] referenceWithPath:@"users"];
    [usersDatabase keepSynced:YES];
    
    //SETUP APP GENERAL CONFIGURATOR.PLIST
    [Configurator setMainAppConfigurationFromPlist];
    
    //CREATE COREDATA MODEL
    [MagicalRecord setupCoreDataStackWithStoreNamed:kRecipesStoreName];
    if (![defaults_object(@"TelematicsAppShouldMigrateCoreDataV10") boolValue]) {
        [TelematicsAppModel MR_deleteAllMatchingPredicate:[NSPredicate predicateWithFormat:@"current_user == 1"]];
        
        [MagicalRecord setupCoreDataStackWithAutoMigratingSqliteStoreNamed:kRecipesStoreName];
        defaults_set_object(@"TelematicsAppShouldMigrateCoreDataV10", @(YES));
    }
    
    //TELEMATICS SDK INITIALIZATION
    [RPEntry initializeWithRequestingPermissions:NO];
    [RPEntry instance].lowPowerModeDelegate = self;
    [RPEntry instance].accuracyAuthorizationDelegate = self;
    
    //WE NEED START SDK PERMISSION WIZARD LOCSTION ALWAYS FOR USER AFTER LOGIN! - TEMPORARY STOP BY USER DEFAULTS IN CACHE
    //
    if ([defaults_object(@"needTrackingOnRequired") boolValue]) {
        
        NSLog(@"%@", [GeneralService sharedService].device_token_number);
        [RPEntry instance].virtualDeviceToken = [GeneralService sharedService].device_token_number; //REQUIRED
        
        if ([Configurator sharedInstance].sdkEnableHF) {
            [RPEntry enableHF:YES];
        } else {
            [RPEntry enableHF:NO];
        }

        if ([RPEntry instance].virtualDeviceToken.length > 0) {
            [RPEntry initializeWithRequestingPermissions:YES];
        }
        
        [RPEntry application:application didFinishLaunchingWithOptions:launchOptions];
        [RPEntry instance].apiLanguage = RPApiLanguageEnglish;
        
        if ([ASIdentifierManager sharedManager].isAdvertisingTrackingEnabled) {
            [RPEntry instance].advertisingIdentifier = [ASIdentifierManager sharedManager].advertisingIdentifier;
        }
    } else {
        
        //FIRST RUN
        NSLog(@"%@", [GeneralService sharedService].device_token_number);
        [RPEntry instance].virtualDeviceToken = [GeneralService sharedService].device_token_number; //REQUIRED
        
        if ([Configurator sharedInstance].sdkEnableHF) {
            [RPEntry enableHF:YES];
        } else {
            [RPEntry enableHF:NO];
        }

        if ([RPEntry instance].virtualDeviceToken.length > 0) {
            [RPEntry initializeWithRequestingPermissions:YES];
        }
    }
    
    //HERE MAPS KEYS
    [NMAApplicationContext setAppId:[Configurator sharedInstance].mapsAppIdKey
                            appCode:[Configurator sharedInstance].mapsAppCode
                         licenseKey:[Configurator sharedInstance].mapsLicenseKey];
    
    //YOUR OWN GOOGLE MAPS KEYS FOR CLAIMS SECTION REQUIRED FOR MAPS
    [GMSServices provideAPIKey:[Configurator sharedInstance].googleApiKey];
    [GMSPlacesClient provideAPIKey:[Configurator sharedInstance].googleApiKey];
    
//    //LOG SETUP IF NEEDED
//    [DDLog addLogger:[DDOSLogger sharedInstance]];
//    DDFileLogger *fileLogger = [[DDFileLogger alloc] init];
//    fileLogger.rollingFrequency = 60 * 60 * 24;
//    fileLogger.logFileManager.maximumNumberOfLogFiles = 7;
//    [DDLog addLogger:fileLogger];
//    [DDLog addLogger:[DDTTYLogger sharedInstance]];
//    [DDLog addLogger:[DDASLLogger sharedInstance]];
//    [[DDTTYLogger sharedInstance] setColorsEnabled:YES];
//    [[DDTTYLogger sharedInstance] setForegroundColor:RGB3(0, 200, 0) backgroundColor:nil forFlag:DDLogFlagInfo];
//    [[DDTTYLogger sharedInstance] setForegroundColor:RGB3(0, 0, 200) backgroundColor:nil forFlag:DDLogFlagDebug];
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self.window makeKeyAndVisible];
    [self updateRootController];
    
    return YES;
}

- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)(void))completionHandler {
    if ([defaults_object(@"needTrackingOnRequired") boolValue]) {
        [RPEntry application:application handleEventsForBackgroundURLSession:identifier completionHandler:completionHandler];
    }
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    if ([defaults_object(@"needTrackingOnRequired") boolValue]) {
        [RPEntry applicationDidReceiveMemoryWarning:application];
    }
}
    
- (void)applicationDidBecomeActive:(UIApplication *)application {
    if ([defaults_object(@"needTrackingOnRequired") boolValue]) {
        [RPEntry applicationDidBecomeActive:application];
    }
    [WiFiGPSChecker sharedChecker].checkAccess = YES;
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    if ([defaults_object(@"needTrackingOnRequired") boolValue]) {
         [RPEntry applicationDidEnterBackground:application];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    if ([defaults_object(@"needTrackingOnRequired") boolValue]) {
        [RPEntry applicationWillTerminate:application];
    }
}

- (void)updateRootController {
    //RUN ROOT STORYBOARD
    UIViewController* rootVc = nil;
    BOOL loggedIn = [GeneralService sharedService].isLoggedOn;
    if (loggedIn) {
        
        [[GeneralService sharedService] loadProfile];
        
        NSLog(@"%@", [GeneralService sharedService].device_token_number);
        [RPEntry instance].virtualDeviceToken = [GeneralService sharedService].device_token_number;
        
        rootVc = [[UIStoryboard storyboardWithName:@"MainTabBar" bundle:nil] instantiateInitialViewController];
        
    } else {
        [RPEntry instance].virtualDeviceToken = nil;
        rootVc = [[UIStoryboard storyboardWithName:@"Auth" bundle:nil] instantiateInitialViewController];
    }
    
    [UIView transitionWithView:self.window duration:0 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        self.window.rootViewController = rootVc;
    } completion:nil];
}

- (void)logoutOn401 {
    //LOGOUT OR REFRESHTOKEN
    if ([GeneralService sharedService].isLoggedOn) {
        [[GeneralService sharedService] logout];
    }
}

- (void)logoutOn419 {
    //LOGOUT
    if ([GeneralService sharedService].isLoggedOn) {
        [[GeneralService sharedService] logout];
    }
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
            options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    
    //DEEP LINKS USE CASES
    UITabBarController *tabBar = (UITabBarController *)[AppDelegate appDelegate].window.rootViewController;
    if ([[url absoluteString] isEqual:@"telematicsapp://dashboard"]) {
        [tabBar setSelectedIndex:[[Configurator sharedInstance].dashboardTabBarNumber intValue]];
    } else if ([[url absoluteString] isEqual:@"telematicsapp://feed"]) {
        [tabBar setSelectedIndex:[[Configurator sharedInstance].feedTabBarNumber intValue]];
    } else if ([[url absoluteString] isEqual:@"telematicsapp://rewards"]) {
        [tabBar setSelectedIndex:[[Configurator sharedInstance].rewardsTabBarNumber intValue]];
    } else if ([[url absoluteString] isEqual:@"telematicsapp://profile"]) {
        [tabBar setSelectedIndex:[[Configurator sharedInstance].profileTabBarNumber intValue]];
    }
    
    return NO;
}


#pragma mark - Accuracy and Low power Telematics SDK

- (void)wrongAccuracyAuthorization {
    //SDK NEEDED LOCATION ALWAYS
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
    content.title = localizeString(@"Precise Location is off");
    content.body = [NSString stringWithFormat:@"%@", localizeString(@"Your trips may be not recorded. Please, follow to App Settings=>Location=>Precise Location")];
    UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:1 repeats:NO];
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"overspeed" content:content trigger:trigger];

    [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:nil];

}

- (void)lowPowerMode:(Boolean)state {
    //SDK NEEDED NOT LOWER POWER MODE ON IOS FOR BEST TRIPS
    if (state) {
        UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
        content.title = localizeString(@"Low Power Mode");
        content.body = [NSString stringWithFormat:@"%@", localizeString(@"Your trips may be not recorded. Please, follow to Settings=>Battery=>Low Power")];
        UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:1 repeats:NO];
        UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"overspeed" content:content trigger:trigger];

        [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:nil];
    }
}


#pragma mark - Push

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    //PUSH SECTION IMPLEMENTED MANUALLY
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(nonnull NSDictionary *)userInfo fetchCompletionHandler:(nonnull void (^)(UIBackgroundFetchResult))completionHandler {
    //PUSH RESPONSE SERVICE
    [self pushReceived:userInfo openImmediately:NO handled:^{
        BOOL state = [UIApplication sharedApplication].applicationState;
        BOOL openNow = (state == UIApplicationStateInactive);
        [self pushReceived:userInfo openImmediately:openNow handled:nil];
        completionHandler(UIBackgroundFetchResultNewData);
    }];
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center openSettingsForNotification:(UNNotification *)notification {
    NSLog(@"Open notification settings screen in app");
}

- (void)pushReceived:(NSDictionary*)userInfo openImmediately:(BOOL)open handled:(void(^)(void))handledBlock {
    //NSError* error = nil;
    //PUSH RECEIVED
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    NSDictionary *userInfo = notification.request.content.userInfo;
    NSLog(@"%@", userInfo);
    BOOL state = [UIApplication sharedApplication].applicationState;
    BOOL openNow = (state == UIApplicationStateInactive);
    [self pushReceived:userInfo openImmediately:openNow handled:nil];
    completionHandler(UNNotificationPresentationOptionNone);
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)(void))completionHandler {
    NSDictionary *userInfo = response.notification.request.content.userInfo;
    [self pushReceived:userInfo openImmediately:NO handled:nil];
    completionHandler();
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    //
}


#pragma mark - Deeplink Activity

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray<id<UIUserActivityRestoring>> *restorableObjects))restorationHandler {
    return YES;
}



@end
