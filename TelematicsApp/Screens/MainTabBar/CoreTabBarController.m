//
//  CoreTabBarController.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 14.05.21.
//  Copyright © 2019-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "CoreTabBarController.h"
#import "CoreBarController.h"
#import "Helpers.h"


@interface CoreTabBarController ()
@end

@implementation CoreTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.delegate = self;
    
    NSArray *unSelectedImgArray = [NSArray arrayWithObjects:@"dashboard_unselected", @"feed_unselected", @"profile_unselected", nil];
    NSArray *selectedImgArray = [NSArray arrayWithObjects:@"dashboard_selected", @"feed_selected", @"profile_selected", nil];
    
    [CoreBarController setTabBar:self.tabBar andImages:unSelectedImgArray andSelectedImages:selectedImgArray];
    
    UITabBar *tabBar = self.tabBar;
    
    CGSize imgSize = CGSizeMake(tabBar.frame.size.width/tabBar.items.count +1, tabBar.frame.size.height);
    if (IS_IPHONE_11 || IS_IPHONE_12_PRO || IS_IPHONE_11_PROMAX || IS_IPHONE_12_PROMAX) {
        imgSize = CGSizeMake(tabBar.frame.size.width/tabBar.items.count +1, tabBar.frame.size.height +33);
    }
    
    UIGraphicsBeginImageContextWithOptions(imgSize, NO, 0);
    UIBezierPath* p = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, imgSize.width, imgSize.height)];
    [[Color tabBarLightColor] setFill];
    [p fill];
    UIImage* finalImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [tabBar setSelectionIndicatorImage:finalImg];
    
    NSDictionary *attribute =  [NSDictionary dictionaryWithObjectsAndKeys:[Color officialWhiteColor], NSForegroundColorAttributeName, nil];
    [CoreBarController setTabBarTitleColor:attribute];
    
    [self setSelectedIndex:[[Configurator sharedInstance].mainTabBarNumber intValue]];
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController{
    @try {
        UITabBar *tabBar = self.tabBar;
        CGSize imgSize = CGSizeMake(tabBar.frame.size.width/tabBar.items.count, tabBar.frame.size.height);
        UIGraphicsBeginImageContextWithOptions(imgSize, NO, 0);
        UIBezierPath* p = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, imgSize.width, imgSize.height)];
        [[Color tabBarLightColor] setFill];
        [p fill];
        UIImage* finalImg = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [tabBar setSelectionIndicatorImage:finalImg];
        
        [CoreBarController setAnimation:tabBarController andAnimationType:TelematicsAppAnimation_Cross_Dissolve];
    }
    @catch (NSException *exception) {
        //
    }
    @finally {
        //
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
