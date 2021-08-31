//
//  Configurator.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 03.03.21.
//  Copyright © 2020-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Helpers.h"
#import "VisibleBuildConfig.h"

#define TelematicsApp_CONFIG @"TelematicsApp_Configuration"

@interface Configurator : VisibleBuildConfig

//YOUR PERSONAL DATA
@property(nonatomic, strong) NSString       *instanceId;
@property(nonatomic, strong) NSString       *instanceKey;

//URL
@property(nonatomic, strong) NSString       *userServiceRootURL;

@property(nonatomic, strong) NSString       *indicatorsServiceURL;
@property(nonatomic, strong) NSString       *leaderboardServiceURL;
@property(nonatomic, strong) NSString       *carServiceURL;
@property(nonatomic, strong) NSString       *claimsServiceURL;
@property(nonatomic, strong) NSString       *driveCoinsServiceURL;

//HERE MAPS KEYS - YOU NEED YOUR OWN HEREMAPS KEYS FOR TRIPS - REGISTER AT HTTP://DEVELOPER.HERE.COM
@property(nonatomic, strong) NSString       *mapsAppIdKey;
@property(nonatomic, strong) NSString       *mapsAppCode;
@property(nonatomic, strong) NSString       *mapsLicenseKey;
@property(nonatomic, strong) NSString       *mapsRestApiKey;

//GOOGLE KEY IF NEEDED
@property(nonatomic, strong) NSString       *googleApiKey;

//LINKS FOR YPUR APP
@property(nonatomic, strong) NSString       *linkPrivacyPolicy;
@property(nonatomic, strong) NSString       *linkTermsOfUse;
@property(nonatomic, strong) NSString       *linkHowItWorks;
@property(nonatomic, strong) NSString       *telematicsSettingsOS12;
@property(nonatomic, strong) NSString       *telematicsSettingsOS13;
@property(nonatomic, strong) NSString       *linkSupportEmail;

//IMAGES FOR APP BACKGROUND SEE ASSETS FOLDER
@property(nonatomic, strong) NSString       *mainBackgroundImg;
@property(nonatomic, strong) NSString       *additionalBackgroundImg;

//APP LOGO FOR LOGIN SCREENS
@property(nonatomic, strong) NSString       *mainLogoColor;
@property(nonatomic, strong) NSString       *mainLogoClear;

//ENABLE HIGH-FREQUENCY LOCATION POSITION - DEFAULT YES
@property(nonatomic, assign) BOOL           sdkEnableHF;
@property(nonatomic, strong) NSString       *appStoreAppId;

//MAIN TAB BAR NUMBER IN APP - IT FIRST FOR APP RUNNING. CONFIG THIS IN Configuration.plist
@property(nonatomic, strong) NSNumber       *mainTabBarNumber;

//YOU CAN SETUP TABS HOW YOU WANT IN Configuration.plist
@property(nonatomic, strong) NSNumber       *dashboardTabBarNumber; //0
@property(nonatomic, strong) NSNumber       *feedTabBarNumber; //1
@property(nonatomic, strong) NSNumber       *rewardsTabBarNumber; // 2
@property(nonatomic, strong) NSNumber       *profileTabBarNumber; // 3

//DISTANSE FOR OUR SERVICES FOR FIRS SCORING & STATISTIC - BY DEFAULT 10 km
@property(nonatomic, strong) NSNumber       *needDistanceForScoringKm;

//FEED SCREEN - SHOW DRIVING SIGNATURE BUTTON. ORIGINAL DRIVER/PASSENGER/BUS/MOTORCYCLE/TRAIN/BICYCLE/TAXI/OTHER
@property(nonatomic, assign) BOOL           showTrackSignatureCustomButton;

//FEED SCREEN - SHOW ONLY TAGS 2 CHOICES BUTTON (EXAMPLE PERSONAL/BUSINESS)
@property(nonatomic, assign) BOOL           showTrackTagCustomButton;

//FEED SCREEN - NEED SWIPE AND SHOW DELETING BUTTON
@property(nonatomic, assign) BOOL           needTripsDeleting;

//BOOL 0/1 IF YOU NEED BY DEFAULT ALL IN MILES (NOT KILOMETERS) - BY DEFAULT 0
@property(nonatomic, assign) BOOL           needDistanceInMiles;

//BOOL 0/1 IF YOU NEED BY DEFAULT ALL IN AM/PM TIME FORMAT - BY DEFAULT 0
@property(nonatomic, assign) BOOL           needAmPmTime;

//TRIP DETAILS SCREEN ON MAP EVENTS - REVIEW BUTTON FOR STATISTIC EVENTS ACCELERATION/BRAKING/CORNERING
@property(nonatomic, assign) BOOL           needEventsReviewButton;

//SERVICES SETTING NOT NEED TO CHANGE
+ (void)setMainAppConfigurationFromPlist;

@end
