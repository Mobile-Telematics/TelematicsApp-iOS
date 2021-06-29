# Telematics App with Firebase© integration

![](https://github.com/Mobile-Telematics/TelematicsAppFirebase-iOS/raw/master/img_readme/mainlogo.jpg)

![](https://img.shields.io/cocoapods/v/RaxelPulse) ![](https://img.shields.io/badge/release-blueviolet) ![](https://img.shields.io/badge/free-release) ![](https://img.shields.io/badge/AppStore-ready-important)

## Description

This Telematics App is created by DATA MOTION PTE. LTD. and is distributed free of charge to all customers & users and can be used to create your own app for iOS in few steps with the help of Firebase© services.

## Ready Features

- [Telematics SDK setup](#telematics-sdk-setup)
- [UserService Authentification](#app-authentication)
- [Dashboard screen](#dashboard-features)
- [Feed screen](#feed-screen-trips-loading)
- [Profile & Settings screens](#user-profile-screen)
- [Leaderboard screen](#leaderboard-screen)
- [Connect OBD device screen](#leaderboard-screen)
- [Advanced Settings & Links](#advanced-settings)

## Basic concepts & credentials

For commercial use, you need to create sandbox account https://userdatahub.com/user/registration and get `InstanceId` and`InstanceKey` auth keys to work with our API.

Additionally, to authenticate users in your app and store users data, you need to create a firebase account: https://firebase.google.com

All user data will be stored in the Firebase© Realtime Database, which will allow you to create an app users database without programming skills in a few minutes.

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

Step 10: Switch to "Enable" and click "Save" button. Now your users can login to the app.

![](https://github.com/Mobile-Telematics/TelematicsAppFirebase-iOS/raw/master/img_readme/f10.png)

Step 11: We need to activate Firebase© Realtime Database. This will allow you to store the data of all your users in this simple web interface. Go to the Realtime Database section on the left side of the menu and click on the "Create Database" button.

![](https://github.com/Mobile-Telematics/TelematicsAppFirebase-iOS/raw/master/img_readme/f11.png)

Step 12: Choose any Realtime Database location value.

![](https://github.com/Mobile-Telematics/TelematicsAppFirebase-iOS/raw/master/img_readme/f12.png)

Step 13: Select "Start a locked mode" and click the "Enable" button.

![](https://github.com/Mobile-Telematics/TelematicsAppFirebase-iOS/raw/master/img_readme/f13.png)

Step 14: Open our TelematicsApp in xCode, make sure to transfer the `GoogleService-Info.plist` file to your project (See Step 5 above) and Enjoy! 

Build & Run!

## Setup Telematics App Configuration.plist file

Open our Telematics App source code by tapping TelematicsApp.xcworkspace file. 

![](https://github.com/Mobile-Telematics/TelematicsAppFirebase-iOS/raw/master/img_readme/f14.png)

For your convenience, we have created a standard iOS file with parameters named `Configuration.plist`, where you can specify the basic settings for your future app.
Using this file, you can configure the basic parameters of your application by specifying server addresses, basic settings and links, as well as specifying several images for an individual design. Carefully study the parameters provided below for further work.
                    
Settings Key  | Value
------------- | -------------
configName | Default Your app configuration name. Not need to change, you can use any of your choice. By default `TelematicsApp_Configuration`
instanceId | Unique ID code for the application to work. `Required!`
instanceKey | Unique KEY code for the application to work. `Required!`
statisticServiceURL | Basic https address to work with `Statistics` and `Scorings` APIs. By default, we provide you https-address of our `TEST` servers for debugging. Before the release your app, you can get the addresses to enter `PRODUCTION` environment
leaderboardServiceRootURL | Basic https address to work with the user leaderboard and `Leaderboard API`.
mapsAppIdKey | App Id for `HEREmaps API`
mapsAppCode | App Code for `HEREmaps API`
mapsLicenseKey | License key for `HEREmaps API`
mapsRestApiKey | Rest API key for `HEREmaps API`
enableHF | BOOL parameter, that activates High Frequency data in Telematics SDK. By defaults `true`
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
needDistanceForScoringKm  | The minimum distance required to display statistics and user scores. `By default 10 km`
showTrackSignatureCustomButton | BOOL parameter, determines whether the Driver Signature button should be displayed on the Feed screen. `By default 1.` Cannot be used simultaneously with key `showTrackTagCustomButton` in 1 value!
showTrackTagCustomButton | BOOL parameter, determines whether the Tag Switcher should be displayed on the Feed screen. `By default 0.` Cannot be used simultaneously with key `showTrackSignatureCustomButton` in 1 value!
needTripsDeleting | BOOL parameter, determining if user can delete their trips
needDistanceInMiles | BOOL parameter, determining use the default distance traveled in the entire application in km/miles
needAmPmTime | BOOL parameter, determining use AM/PM time format in the entire application
needEventsReviewButton | BOOL parameter, allowing to mark events on the map

## Telematics SDK setup

We use CocoaPods dependency libraries in our applications.
The Telematics SDK is installed by default in the Telematics app using the `pod 'RaxelPulse'` command in the application Podfile.
Run your application by opening the `TelematicsApp.xcworkspace` file in the source code folder.
Below we present the basic methods for AppDelegate that allow you to initialize the Telematics SDK in a few steps.

    - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
        [RPEntry initializeWithRequestingPermissions:NO];
        [RPEntry instance].lowPowerModeDelegate = self;
        [RPEntry instance].accuracyAuthorizationDelegate = self;
        [RPEntry sdkEnableHF:YES];

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

## Telematics SDK Permission Wizard for Telematics App

An important part to record a user's trips is to properly request permissions to use the user's Location and Motion & Fitness activity. Telematics SDK includes a specially designed `Wizard` that helps the user explain why the application needs it and make the right choice. Below is an example of initialization with the launch of the step-by-step`Wizard`

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

## LoginAuth Framework authentication for Telematics App

We have created a special Framework that allows you to receive `deviceToken`, `jwToken` & `refreshToken` for full integration with our services. These keys are required for statistics and user scorings. `AuthLogin Framework` is integrated into this Telematics App.

You can find complete information about LoginAuth Framework in our repository https://github.com/Mobile-Telematics/LoginAuthFramework-iOS

#### Basic concepts of LoginAuth Framework

`deviceToken` - is the main individual SDK user identifier for your app. This identifier is used as a key across all our services.

`jwToken` - or JSON Web Token (JWT) is the main UserService API key, that allows you to get user individual statistics and user scorings by UserService APIs calls.

`refreshToken` - is a secret key that allows you to refresh the jwToken when it expires.

First of all, when you creating a new user, you need to get a ` deviceToken`  from our service. ` deviceToken`  cannot be recovered if lost! Remember this.

In this Telematics App, we specifically showed an example of use, so that the `deviceToken`  is stored on the Firebase© Realtime Database side, created by you.

If the user has deleted the app or wants to log in again - By owning ` deviceToken`  (stored at Firebase© Realtime Database side) ,  `instanceId`  &  `instanceKey` (received from us), you can always get a  `jwToken`  for further authorization of your user.

` jwToken`  will allow you to request a user statistics and scorings, as we discussed and explained earlier.

## Dashboard features

Our goal is to provide your users with a user-friendly interface to get the best user experience.
We suggest you use 2 (two) dashboards with Scoring and user Statistics data in your application. To get the first data, the user usually needs to drive a short distance. We set this parameter in the configuration file with the `needDistanceForScoringKm` key.

Until the user overcomes the minimum required distance, he will see a special `DemoDashboard`, which we created in order to show the user the main features of the application at an early stage. After overcoming the required minimum distance, the `MainDashboard` with its main statistics indicators and eco-scoring will be automatically available to the user.

## Feed screen trips loading

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

## Feed screen Driver Signature role

The Telematics SDK allows the user to change their role for any trip. Use this method below and passing the parameter of the user's role, you can go to the calculation of the user's rating, depending on each trip.
Remember that to display the button for switching Driving Signature, you must set the value `showTrackSignatureCustomButton` in Configuration file.

    [[RPEntry instance].api changeTrackOrigin:'USER_DRIVER_SIGNATURE_ROLE' forTrackToken:'SELECTED_TRACK_TOKEN' completion:^(id response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            // Success
        });
    }];

`USER_DRIVER_SIGNATURE_ROLE` can only take the following string values below!
By default, each trip has the very first role -`OriginalDriver`
                    
- OriginalDriver
- Passenger
- Bus
- Motorcycle
- Train
- Taxi
- Bicycle
- Other

In some situations, we also offer you a convenient interface and switching certain tags for each trip by switching the switcher on the trip screen. If you specify in the configuration file `true` for `showTrackTagCustomButton` key, you can see, that the Feed screen now allows you to quickly switch between tags for each trip.
>Remember! Keys `showTrackTagCustomButton` and `showTrackSignatureCustomButton` separately to display the interface correctly!

## Feed screen tags & trip deleting

The Telematics SDK allows users to add specific unique`tags` to any ride for ease of use.
For example, by adding tag options to any trip, you will be able to mark specific trips for Business/Personal & other options:

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

In RaxelPukse SDK, we prohibit use`DEL` tag, except when the user wants to delete trips.
If the any trip has a`DEL`tag, it should not be shown to the user on the Feed screen.

## Trip Details screen

>Telematics App for iOS uses HERE Maps to display the user's trips on a map. Before you use this screen for `PRODUCTION` environment, you need to get access API keys to the HERE Maps to view the details of user trips. In the app we provide you with a key for `TEST` environment. If you would like to use `PRODUCTION` environment with your app Bunble Identifier for `HEREMaps API`, visit https://developer.here.com

Having received a list of the user's trips, you can refer to your array of trips and get even more detailed information, as well as a set of points to be displayed on the HEREmaps API.

    [[RPEntry instance].api getTrackWithTrackToken:`SELECTED_TRACK_TOKEN` completion:^(id response, NSError *error) {
        RPTrackProcessed * track = response; // Detailed track information with points
    }];

Our Telematics App provides you with its own version of displaying and drawing trips.
Study this view's' carefully and figure out what functionality you want to leave in your future application.

## Trip Details events

On the detailed trip screen, we allow users to see the events that happened to them during the trip.
We detect major events:`Acceleration`,`Braking`,`Speeding`,`Cornering`,`PhoneUsage`.
In the Telematics App, we offer you a clear interface that allows the user to change the event on the map if it is not correct or delete.

## Settings screen

Settings screen gives you the opportunity to make specific settings for the entire application, provide links to instructions, as well as addresses of technical support for the application.
>Use the values in the Configuration.plist file for easy linking for Privacy Policy, Email address or Rate you app link. This will help you easily customize the Settings screen.

## Leaderboard screen

We provide you with the ability to create user ratings based on their trips. All this is displayed and relied on in the Leaderboard section of our Telematics App.
There are 9 different leaderboards in total:

- Acceleration = 1
- Deceleration = 2
- Distraction = 3
- Speeding = 4
- Turn = 5
- RateOverall = 6
- Distance = 7
- Trips = 8
- Duration = 9

All types are presented in the Telematics App and you can understand which of these options for user ratings you need.

>Remember! It takes a little time to create a Leaderboard rating in our Leaderboard API. A user who does not have a sufficient number of trips cannot see the Leaderboard data. Use placeholders for new users with an offer to make a trip, who just signed up.

## User Log Out

In the Telematics App source code, we show you an option to clear user data after logging out. Do not forget - to stop tracking and record user journeys, you need to explicitly delete `VIRTUAL_DEVICE_TOKEN`.
This can be done using Telematics SDK method:

    [[RPEntry instance] removeVirtualDeviceToken];
    [[FIRAuth auth] signOut:nil];

## Connect OBD device

Telematics App provides you with the functionality with which you can connect to the OBD adapter in your car using Bluetooth® technology.
OBD adapter is a small device that plugs into the CAN-port of your car. Usually the CAN-port is located under the steering wheel.

Telematics App created by DATA MOTION PTE. LTD, has a full range of functionality that allows you to read almost any information and indicators from your car, and add it to trips recorded by the Telematics App on iOS/Android.
OBD adapter does not need to be disabled or configured. It is always in your car, the Telematics App works with the OBD adapter only when you are traveling. Connecting and disconnecting to your iOS device happens automatically.

Detailed documentation and the basic principle of operation can be found in the development portal https://docs.telematicssdk.com/sdk-features/bluetooth-obd/elm-api
To fully work with this functionality, you need additional equipment, which we can provide upon your request.

## Other features

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

[Official product Web-page](https://telematicssdk.com/)

[Official API services web-page](https://www.telematicssdk.com/api-services/)

[Official SDK and API references](https://www.telematicssdk.com/api-services/)

[Official ZenRoad web-page](https://www.telematicssdk.com/telematics-app/)

[Official ZenRoad app for iOS](https://apps.apple.com/jo/app/zenroad/id1563218393)

[Official ZenRoad app for Android](https://play.google.com/store/apps/details?id=com.telematicssdk.zenroad&hl=en&gl=US)

[Official ZenRoad app for Huawei](https://appgallery.huawei.com/#/app/C104163115)


###### Copyright © 2020-2021 DATA MOTION PTE. LTD. All rights reserved.

















