# iOS Open-Source Telematics App with Firebase© integration

![](https://github.com/Mobile-Telematics/TelematicsAppFirebase-iOS/raw/master/img_readme/mainlogo.jpg)

![](https://img.shields.io/cocoapods/v/RaxelPulse) ![](https://img.shields.io/badge/release-blueviolet) ![](https://img.shields.io/badge/free-release) ![](https://img.shields.io/badge/AppStore-ready-important)

## Description

This Telematics App is developed by Damoov and is distributed free of charge. This app can be used to create your own telematics app for iOS in few steps.

## Ready Features
Telematics:
- [Telematics SDK — mobile telematics engine](#basic-concepts-and-credentials)
- [Setup Firebase© project](#setup-firebase-project)
- [Telematics SDK Setup](#telematics-sdk-setup)
- [LoginAuthFramework Authentication](#loginauthframework-authentication)
- [Dashboard](#dashboard)
- [Feed](#feed-trips-loading)
- [Trip Details](#trip-details)
- [Leaderboard](#leaderboard)
- [My Rewards](#my-rewards)
- [Profile & Settings](#settings)
- [Connect OBD device](#connect-obd-device)
- [Claims](#claims)
- [Join a Company](#join-a-company)
- [Advanced Settings & Links](#advanced-settings)

## Basic concepts and credentials

Create an account https://app.damoov.com/user/registration and get `InstanceId` and`InstanceKey` auth keys to work with the telematics SDK & APIs.
How to obtain InsanceId & InstanceKey => https://docs.telematicssdk.com/docs/datahub#user-group-credentials

Additionally, to authenticate users in your app and store users data, you need to create a firebase account: https://firebase.google.com
All user data will be stored in the Firebase© Realtime Database, which will allow you to create an app users database without programming skills.

## Setup Firebase© Project

In the next few simple steps, we'll show you how easy it is to create and configure an app in the Firebase© console.

Step 1: After creating your Firebase© account, open your console: https://console.firebase.google.com

Click "Create a project" button.

![](https://github.com/Mobile-Telematics/TelematicsAppFirebase-iOS/raw/master/img_readme/f01.png)

Step 2: Enter the name of your future Project. Click "Continue" button.

![](https://github.com/Mobile-Telematics/TelematicsAppFirebase-iOS/raw/master/img_readme/f02.png)

Step 3: For ease of integration, at the next step, we recommend deactivating the "Enable Google Analytics" checkbox.

![](https://github.com/Mobile-Telematics/TelematicsAppFirebase-iOS/raw/master/img_readme/f03.png)

Click "Create project".

Step 4: Now you need to create a configuration for your iOS app. Click on the "iOS icon" as it us shown on the picture below:

![](https://github.com/Mobile-Telematics/TelematicsAppFirebase-iOS/raw/master/img_readme/f04.png)

Step 5: Enter your unique iOS Bundle ID. This identifier must be used in your application in xCode. Enter App Nickname. Click "Register app" next.

![](https://github.com/Mobile-Telematics/TelematicsAppFirebase-iOS/raw/master/img_readme/f05.png)

Step 6: On this step, download the provided  `GoogleService-Info.plist`  file. You need to put it in our Telematics App source code, as it is shown on the picture below:

![](https://github.com/Mobile-Telematics/TelematicsAppFirebase-iOS/raw/master/img_readme/f06.png)

Step 7: You can skip the "Add Firebase SDK" & "Add initialization code" steps below, because we already did it for you in our Telematics App:) Finish the setup and click on "Continue to console".

![](https://github.com/Mobile-Telematics/TelematicsAppFirebase-iOS/raw/master/img_readme/f07.png)

Step 8: Important. In order for your users to create accounts to log into your app, you need to go to "Authentication" section on the left side of the menu.

![](https://github.com/Mobile-Telematics/TelematicsAppFirebase-iOS/raw/master/img_readme/f08.png)

Step 9: In the "Sign-in method" tab, click on the Provider's "Email/Password" on the right "pencil" (Edit configuration hint) as in the picture below. If you need to perform authorization using the "Phone" Provider - select the setting of this item.

![](https://github.com/Mobile-Telematics/TelematicsAppFirebase-iOS/raw/master/img_readme/f09.png)

In order for phone auth to work in your xCode project, you need to register Firebase URL Schemes in the Info section of your application.

![](https://github.com/Mobile-Telematics/TelematicsAppFirebase-iOS/raw/master/img_readme/f09u.png)

Step 10: Switch to "Enable" and click "Save" button. Now your users can login to the app.

![](https://github.com/Mobile-Telematics/TelematicsAppFirebase-iOS/raw/master/img_readme/f10.png)

Step 11: We need to activate Firebase© Realtime Database. This will allow you to store the data of all your users in this simple web interface. Go to the Realtime Database section on the left side of the menu and click on the "Create Database" button.

![](https://github.com/Mobile-Telematics/TelematicsAppFirebase-iOS/raw/master/img_readme/f11.png)

Step 12: Choose any Realtime Database location value.

![](https://github.com/Mobile-Telematics/TelematicsAppFirebase-iOS/raw/master/img_readme/f12.png)

Step 13: Select "Start a locked mode" and click the "Enable" button.

![](https://github.com/Mobile-Telematics/TelematicsAppFirebase-iOS/raw/master/img_readme/f13.png)

Step 14: Now you need to change rules for your Realtime Database. You need to go to “Realtime Database” section on the left side of the menu. In the “Rules” tab change read and write fields to ".read": "auth.uid != null" & ".write": "auth.uid != null".

{
  "rules": {
    ".read": "auth.uid != null",
    ".write": "auth.uid != null"
  }
}

![](https://github.com/Mobile-Telematics/TelematicsAppFirebase-iOS/raw/master/img_readme/f14.png)

Important! After creating a user, his data will be entered into the database with the following field names. The structure is identical for iOS and Android and cannot be changed to sync user data across mobile platforms. 

![](https://github.com/Mobile-Telematics/TelematicsAppFirebase-iOS/raw/master/img_readme/f16.png)

Step 15: Open our TelematicsApp.xcworkspace in xCode, make sure to transfer the `GoogleService-Info.plist` file to your project (See Step 5 above), instanceId & instanceKey in `Configurator.plist` and Enjoy! 

Build & Run!

## Setup Telematics App Configuration.plist file

For your convenience, we have created a standard iOS file with parameters named `Configuration.plist`, where you can specify the basic settings for your future app.
Using this file, you can configure the basic parameters of your application by specifying server addresses, basic settings and links, as well as specifying several images for an individual design. Carefully study the parameters provided below for further work.
                    
Settings Key  | Value
------------- | -------------
configName | Default Your app configuration name. Not need to change, you can use any of your choice. By default `TelematicsApp_Configuration`
instanceId | Unique ID code for the application to work. `Required!`
instanceKey | Unique KEY code for the application to work. `Required!`
indicatorsServiceURL | Basic https address to work with `Indicators` APIs. By default, we provide you https-address of our `TEST` servers for debugging. Before the release your app, you can get the addresses to enter `PRODUCTION` environment
driveCoinsServiceURL | Basic https address to work with `DriveCoins` API. 
leaderboardServiceRootURL | Basic https address to work with the user leaderboard and `Leaderboard API`.
carServiceURL | Basic https address to work with `CarService` API. 
claimsServiceURL | Basic https address to work with `ClaimsService` API. 
mapsAppIdKey | App Id for `HEREmaps API`
mapsAppCode | App Code for `HEREmaps API`
mapsLicenseKey | License key for `HEREmaps API`
mapsRestApiKey | Rest API key for `HEREmaps API`
sdkEnableHighFrequency | BOOL parameter, that activates High Frequency data in Telematics SDK. By defaults `true`
sdkEnableELM | BOOL parameter, that activates connection to ELM OBD Bluetooth devices in Telematics SDK. By defaults `true`
linkPrivacyPolicy | Link for Privacy Policy
linkTermsOfUse | Link for Terms Of Use
linkHowItWorks | Link for How It Works
telematicsSettingsOS12 | Link for Telematics Settings before iOS13
telematicsSettingsOS13 | Link for Telematics Settings for iOS13/iOS14
linkSupportEmail | Link for support email address
appStoreAppId | Your unique APPID for the AppStore
mainLogoColor | App logo in colors style for display in app. Specifies the file name, you need to use.
mainLogoClear | App logo is transparent style for display in the app. Specifies the file name, you need to use.
mainBackgroundImg | String name of the Asset image used in the Feed or Profile screen
additionalBackgroundImg | String name of the Asset image used in the Dashboard screen
mainTabBarNumber | TabBar number, which will open first when the application starts. `By default 0`
dashboardTabBarNumber | TabBar number, where Dashboard will open. `By default 0`
feedTabBarNumber | TabBar number, defining what the Feed screen will be in turn in the application. `By default 1`
profileTabBarNumber | TabBar number, defining what the Profile screen will be in turn in the application. `By default 2`
needUserDriveDistanceForScoringKm  | The minimum distance required to display Indicators statistics and user scores. `By default 10 km`
needTripsDeleting | BOOL parameter, determining if user can delete their trips
needDistanceInMiles | BOOL parameter, determining use the default distance traveled in the entire application in km/miles
needAmPmTime | BOOL parameter, determining use AM/PM time format in the entire application
needEventsReviewButton | BOOL parameter, allowing to mark events on the map

## Telematics SDK Setup

We use CocoaPods dependency libraries.
The Telematics SDK is installed by default in the Telematics app using the `pod 'RaxelPulse'` command in the application Podfile.
For your convenience, enable fast access to macOS PathBar (screenshot), copy the path to the application folder (right click), enter the command 'cd (ctrl + v paste path address see screenshot)' -> Enter in the terminal.

![](https://github.com/Mobile-Telematics/TelematicsAppFirebase-iOS/raw/master/img_readme/f15.png)
Next you need enter the command  `pod install` in the macOS Terminal. This will install the required dependency libraries for the app to work correctly.

Run Your new application by opening the `TelematicsApp.xcworkspace` file in the source code folder after.
Below we present the basic methods for AppDelegate that allow you to initialize the Telematics SDK in a few steps.

    - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
        [RPEntry initializeWithRequestingPermissions:NO];
        [RPEntry instance].lowPowerModeDelegate = self;
        [RPEntry instance].accuracyAuthorizationDelegate = self;
        [RPEntry sdkEnableHighFrequency:YES];

        [RPEntry instance].virtualDeviceToken = `VIRTUAL_DEVICE_TOKEN`; // Unique user device token
        if ([RPEntry instance].virtualDeviceToken.length > 0) {
            [RPEntry initializeWithRequestingPermissions:YES];
        }
    
        [RPEntry application:application didFinishLaunchingWithOptions:launchOptions];
        [RPEntry instance].apiLanguage = RPApiLanguageEnglish;
    
        if ([ASIdentifierManager sharedManager].isAdvertisingTrackingEnabled) {
            [RPEntry instance].advertisingIdentifier = [ASIdentifierManager sharedManager].advertisingIdentifier;
        };
        return YES;
    }

You must add the necessary Background Tasks to the Info.plist file for the Telematics SDK to work.
`<key>BGTaskSchedulerPermittedIdentifiers</key>`
        `<array>`
        `<string>sdk.damoov.apprefreshtaskid</string>`
        `<string>sdk.damoov.appprocessingtaskid</string>`
        `</array>`

You can always find out all about the new changes with the release of xCode13 in our Telematics SDK documentation https://docs.damoov.com/docs/-download-the-sdk-and-install-it-in-your-environment
In the new version of the Telematics App, these tasks are added.

## Telematics SDK | Permission Wizard

An important part to record user's trips is to properly request permissions to use the user's Location and Motion & Fitness activity. Telematics SDK includes a specially designed `Wizard` that helps the user explain why the application needs it and make the right choice.
Note: this wizard is fully cutomizable, you can find the documentation here: https://docs.telematicssdk.com/docs/ios-sdk-asset-customisation

Below is an example of initialization with the launch of the step-by-step`Wizard`

    [[RPCSettings returnInstance] setWizardNextButtonBgColor:[UIColor blackColor]];
    [[RPCSettings returnInstance] setAppName:@"TelematicsApp"];
            
    [[RPCPermissionsWizard returnInstance] launchWithFinish:^(BOOL showWizzard) {
        [RPEntry initializeWithRequestingPermissions:YES];
        [RPEntry instance].disableTracking = NO;
        [RPEntry instance].virtualDeviceToken = `VIRTUAL_DEVICE_TOKEN`; // Unique user device token
    }];

    [[RPCPermissionsWizard returnInstance] setupHandlersWithUserNotificationResponce:^(BOOL granted, NSError * _Nullable error) {
        NSLog(@"PUSH_NOTIFICATIONS INIT SUCCESS");
    } motionManagerResponce:^(BOOL granted, NSError * _Nullable error) {
        NSLog(@"MOTION INIT SUCCESS");
    } locationManagerResponce:^(CLAuthorizationStatus status) {
        NSLog(@"LOCATION INIT SUCCESS");
    }];

## LoginAuthFramework Authentication

We have created a special Framework that allows you to receive `deviceToken`, `jwToken` & `refreshToken` for full integration with our services. These keys are required to make calls to our APIs.

`LoginAuth Framework` is already integrated into this Telematics App.

You can find complete information about LoginAuth Framework in our repository https://github.com/Mobile-Telematics/LoginAuthFramework-iOS

# Screens

## Dashboard

Our goal is to provide your users with a user-friendly interface to get the best user experience.
To get the first data, user usually needs to drive a short distance. We set this parameter in the configuration file with the `needUserDriveDistanceForScoringKm` key.

Until the user overcomes the minimum required distance, he will see a special `DemoDashboard`, which we created in order to show user the main features of the application at an early stage. After overcoming the required minimum distance, the `MainDashboard` will be automatically available.

## Feed Trips

The Trips screen displays the trips users have made.
To get rides, we use the method in the Telematics SDK library methods:

    NSUInteger limit = 10;
    __weak typeof(self) _weakSelf = self;
    [self.dataSource setNextPageBlock:^(NSUInteger offset, PageLoadedBlock pageLoaded) {
        [[RPEntry instance].api getTracksWithOffset:offset limit:limit startDate:nil endDate:nil completion:^(id response, NSError *error) {
        RPFeed* feedScreen = (RPFeed*)response;
        if (feedScreen.tracks.count) {
            pageLoaded(feed.tracks); // Success
        } else {
            pageLoaded(@[]); // No user tracks
        }
        }];
    }];

Using the example of the Telematics App, you can see how you can implement a page with trips, as well as use swiping with pagination and alternate loading.

## Feed Type of Transport

The Telematics SDK allows users to change their Driver Signature role for any trip.

    [[RPEntry instance].api changeTrackOrigin:'USER_DRIVER_SIGNATURE_ROLE' forTrackToken:'SELECTED_TRACK_TOKEN' completion:^(id response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            // Success
        });
    }];

`USER_DRIVER_SIGNATURE_ROLE` can only take the following string values below!
                    
- OriginalDriver
- Passenger
- Bus
- Motorcycle
- Train
- Taxi
- Bicycle
- Other


## Feed Tags
Depending on your product use cases, you can also use our Tags feature. You can learn more about it here: https://docs.telematicssdk.com/docs/tags
We also offer you a convenient interface for switching certain tags for each trip. Feed screen will allow to quickly switch between tags for each trip.

The Telematics SDK allows users to add specific unique`tags` to any ride for ease of use.
For example, by adding tag options to any trip, you will be able to mark specific trips for Business/Personal or other options:

    RPTag *tag = [[RPTag alloc] init];
    tag.tag = @"Business"; // Your custom tag
    tag.source = @"TelematicsApp"; // Your AppStore app name

    [[RPEntry instance].api addTrackTags:[[NSArray alloc] initWithObjects:tag, nil] to:`SELECTED_TRACK_TOKEN` completion:^(id response, NSArray *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            // Tag success installed. Reload Feed screen trips now
        });
    }];

You can also remove back any tag previously set:

    [[RPEntry instance].api removeTrackTags:[[NSArray alloc] initWithObjects:tag, nil] from:<SELECTED_TRACK_TOKEN> completion:^(id response, NSArray *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            // Tag deleted. Reload Feed screen trips now
        });
    }];

NOTE: you can use `DEL` tag and hide the trips marked by it in the app. These trips will be shown in DataHub on List of Trips page with a special mark that these trips were hidden in the app.

## Trip Details

>Telematics App for iOS uses HERE Maps to display the user's trips on a map. Before you use this screen for `PRODUCTION` environment, you need to get access API keys to the HERE Maps to view the details of user trips. In the app we provide you with a key for `TEST` environment. If you would like to use `PRODUCTION` environment with your app Bunble Identifier for `HEREMaps API`, visit https://developer.here.com

Having received a list of the user's trips, you can refer to your array of trips and get even more detailed information, as well as a set of waypoints to be displayed on the HEREmaps API.

    [[RPEntry instance].api getTrackWithTrackToken:`SELECTED_TRACK_TOKEN` completion:^(id response, NSError *error) {
        RPTrackProcessed * track = response; // Detailed track information with points
    }];

Our Telematics App provides you with its own version of displaying and drawing trips.
Study this view's' carefully and figure out what functionality you want to leave in your future application.

## Trip Details events

We allow users to see the events that happened to them during the trip.
We detect major events:`Acceleration`,`Braking`,`Speeding`,`Cornering`,`PhoneUsage`.
In the Telematics App, we offer you a clear interface that allows the user to change any event on the map if it's not correct or delete this event.
Also this feature allows us to make our AI-models much clever.

## Leaderboard

You can learn more about these services by following to our docs:
https://docs.telematicssdk.com/docs/leaderboards

All 9 types of Leaderboard are presented in the Telematics App and you can figure out which of these options you actually need.

>Note! Only users who have trips during latest 14 days participate in Leaderboard. Use placeholders for new and lost users.

## My Rewards

Our telematics app allows you to work with DriveCoins and Streaks for each user:

You can learn more about these services by following to our docs:
DriveCoins - https://docs.telematicssdk.com/docs/drivecoins
Streaks - https://docs.telematicssdk.com/docs/streaks-1

In detail, you can see the work with methods for rewards in the Telematics App source code in the DriveCoins section.

## Settings

Settings screen gives you the opportunity to make specific settings for the entire application, provide links to any guides, as well as addresses of technical support etc.
>Use the values in the Configuration.plist file for easy linking for Privacy Policy, Email address or Rate you app links. This will help you easily customize the Settings screen.

## On-Demand Tracking Mode

In the new version of the app, we have provided the ability to select Tracking Mode in Settings. There may be 3 options - `Automatic Tracking`, `On-Demand Tracking`, `Tracking disabled`.

The`On-Demand Tracking` provides an updated `Dashboard` by applying and programmatically increasing Constraints in InterfaceBuilder and a special method for increasing the vertical dimensions of the DashboardController.m file. In this Mode, the user can create a Job for himself.

`JobName` is a specific tag identifier that will be added for 1 or any number of trips made by the user. The user must necessarily start a certain job or order, and complete it accordingly. In the future, when the trip is enriched on our backend-side, the app will receive statistics for this `JobName` tag. The user will see the number of trips made for this task, the rating of maneuverability, risk score, etc. All this is available in a new section on our `Dashboard`.

`On-Demand Tracking` is great for any business like delivery service, taxi and many others. Currently, this Mode will be an integral part of the Telematics App and provide you with a new experience of integrations and work options.

## User Log Out

In the Telematics App source code, we show you an option to clear user data after logging out. Do not forget - to stop tracking and record user trips, you need to explicitly delete `VIRTUAL_DEVICE_TOKEN`.
This can be done using Telematics SDK method:

    [[RPEntry instance] removeVirtualDeviceToken];
    [[FIRAuth auth] signOut:nil];
    
You can also disable SDK with the trips uploading to prevent already recorded and stored on the device trips been not uploaded to Damoov platform.
Learn more about available SDK methods here: https://docs.telematicssdk.com/docs/methods-for-ios-app

## Connect OBD device

Telematics App provides you with the optional functionality to connect the app with an OBD vehicle adapter using Bluetooth® technology.
OBD adapter is a small device that plugs into the CAN-port of your car.

Telematics App created by Damoov, has a full range of functionality that allows you to read almost any information and indicators from your vehicle, and add it to trips recorded by the Telematics App on iOS/Android.
Connecting and disconnecting to your iOS device happens automatically. OBD adapter can detect accidents.

Detailed documentation and the basic principles of operation can be found in the development portal https://docs.telematicssdk.com/docs/bluetooth-obd
To fully work with this functionality, you need additional equipment, which we can provide upon your request.

## Claims

You can create Inspections, report road accidents, any damage to your vehicle, attach photos and fill out all the basic information directly from your mobile device.
Machine learning technology from photos taken with a smartphone can determine the degree of damage, the honesty of the client, and rigged accidents.
The created Inspection can be considered on your side, which gives you the most modern approach for the insurance business and many other areas of activity.

## Join a Company

If you have a Company invitation code, enter it in the Join a Company section in Settings of our Telematics App. 
We have made an additional possibility that now your users can join any company upon request, if required.


# Other features

We have tried to make for you convenient settings and easy entry for any part of the application. Having studied in more detail, you will see that you can customize any part of the Telematics App or Telematics SDK for your purposes, including fonts, official colors used in the application, and much more.

For example, in the source code folder you can find:
`Color.m` - a file containing all the colors used in Telematics app.
`Font.m` - a file containing all the fonts used in Telematics app.
In the`UI` project folder you can find all sorts of improvements for labels, buttons or other styles used in the Telematics App.

## Advanced Settings

To fully understand how the Telematics SDK and all our services work, use our detailed docs and guides https://docs.telematicssdk.com/ to make all the process as easy as possible.

All detailed information on using Firebase© can be found in the documentation https://firebase.google.com/docs/auth/ios/start

Telematics App for iOS works together with HERE maps to display the user's trips on a map. To receive a key for the `PRODUCTION` environment, you need to create your own account https://developer.here.com 

Happy coding!


## Links

[Official product Web-page](https://app.damoov.com/)

[Official API services web-page](https://www.damoov.com/telematics-api/)

[Official API references](https://docs.telematicssdk.com/reference)

[Official ZenRoad web-page](https://www.damoov.com/telematics-app/)

[Official ZenRoad app for iOS](https://apps.apple.com/jo/app/zenroad/id1563218393)

[Official ZenRoad app for Android](https://play.google.com/store/apps/details?id=com.telematicssdk.zenroad&hl=en&gl=US)

[Official ZenRoad app for Huawei](https://appgallery.huawei.com/#/app/C104163115)

###### Copyright © 2020-2021 DATA MOTION PTE. LTD. All rights reserved.



