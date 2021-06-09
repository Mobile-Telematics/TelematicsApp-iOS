//
//  CoreBarController.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 14.08.18.
//  Copyright © 2019-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "CoreTabBarController.h"

#define TelematicsAppAnimation_Bounce_Y  1
#define TelematicsAppAnimation_Bounce_X  2

#define TelematicsAppAnimation_FILP_BOTTOM 3
#define TelematicsAppAnimation_FILP_TOP 4
#define TelematicsAppAnimation_FILP_LEFT 5
#define TelematicsAppAnimation_FILP_RIGHT 6

#define TelematicsAppAnimation_Cross_Dissolve 7
#define TelematicsAppAnimation_Fade 8

#define TelematicsAppAnimation_CurlUp 9
#define TelematicsAppAnimation_CurlDown 10

@interface CoreBarController : CoreTabBarController

+ (void)setTabBarTitleColor:(NSDictionary *)color;
+ (void)setTabBar:(UITabBar*)tabBar andImages:(NSArray *)images andSelectedImages:(NSArray *)selectedImages;
+ (void)setAnimation:(UITabBarController *)tabBarItemview andAnimationType:(NSInteger)animationID;
@end
