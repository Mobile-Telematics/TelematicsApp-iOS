//
//  CoreBarController.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 14.05.21.
//  Copyright © 2019-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "CoreBarController.h"

@implementation CoreBarController


+ (void)setTabBar:(UITabBar*)tabBar andImages:(NSArray *)images andSelectedImages:(NSArray *)selectedImages;{
    
    @try {
        if (images.count != selectedImages.count) {
            NSLog(@"Tabbar Images and SelectedImages are not equal"); return ;
        } else if (images.count != tabBar.items.count) {
            NSLog(@"Tabbar Buttons and Images are not equal"); return ;
        } else if (selectedImages.count != tabBar.items.count) {
            NSLog(@"Tabbar Buttons and SelectedImages are not equal"); return ;
        }
        int index = 0;
        for (UITabBarItem * tabBarItem in tabBar.items) {
            [tabBarItem setImage:[[UIImage imageNamed:[images objectAtIndex:index]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
            [tabBarItem setSelectedImage:[[UIImage imageNamed:[selectedImages objectAtIndex:index]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
            index++ ;
        }
    }
    @catch (NSException *exception) {
        NSLog(@"%s:%@", __FUNCTION__, exception);
    }
    @finally {
        //
    }
}

+ (void)setTabBarTitleColor:(NSDictionary *)color {
    @try {
        [[UITabBarItem appearance] setTitleTextAttributes:color forState:UIControlStateNormal];
    }
    @catch (NSException *exception) {
        NSLog(@"%s:%@", __FUNCTION__, exception);
    }
    @finally {
        //
    }
}

+ (void)setAnimation:(UITabBarController *)tabBarController andAnimationType:(NSInteger)animationtype {
    @try {
        UITabBar *tabBar = tabBarController.tabBar;
        UIView *tabBarItemview = [self getImageViewForTabInTabBar:tabBar withIndex:tabBarController.selectedIndex];
        CGPoint origin = tabBarItemview.center;
        switch (animationtype) {
                
            case TelematicsAppAnimation_Bounce_Y:{
                CGPoint target = CGPointMake(tabBarItemview.center.x, tabBarItemview.center.y+10);
                CABasicAnimation *bounce = [CABasicAnimation animationWithKeyPath:@"position.y"];
                bounce.duration = 0.4;
                bounce.fromValue = [NSNumber numberWithInt:origin.y];
                bounce.toValue = [NSNumber numberWithInt:target.y];
                bounce.repeatCount = 1;
                bounce.autoreverses = YES;
                [tabBarItemview.layer addAnimation:bounce forKey:@"position"];
            } break;
                
            case TelematicsAppAnimation_Bounce_X:{
                CGPoint target = CGPointMake(tabBarItemview.center.x-5, tabBarItemview.center.y);
                CABasicAnimation *bounce = [CABasicAnimation animationWithKeyPath:@"position.x"];
                bounce.duration = 0.4;
                bounce.fromValue = [NSNumber numberWithInt:origin.x+5];
                bounce.toValue = [NSNumber numberWithInt:target.x];
                bounce.repeatCount = 1;
                bounce.autoreverses = YES;
                [tabBarItemview.layer addAnimation:bounce forKey:@"position"];
            } break;
                
            case TelematicsAppAnimation_FILP_TOP:{
                    [UIView transitionWithView:tabBarItemview
                                      duration:1.5
                                       options: UIViewAnimationOptionTransitionFlipFromTop
                                    animations:^{}
                                    completion:^(BOOL finished) {
                                        //animationCompleteHandler
                                    }];
            } break;
                
            case TelematicsAppAnimation_FILP_BOTTOM:{
                    [UIView transitionWithView:tabBarItemview
                                  duration:1.5
                                   options: UIViewAnimationOptionTransitionFlipFromBottom
                                animations:^{}
                                completion:^(BOOL finished) {
                                    //animationCompleteHandler
                                }];
            } break;
                
            case TelematicsAppAnimation_FILP_LEFT:{
                    [UIView transitionWithView:tabBarItemview
                                  duration:1.5
                                   options: UIViewAnimationOptionTransitionFlipFromLeft
                                animations:^{}
                                completion:^(BOOL finished) {
                                    //animationCompleteHandler
                                }];
            } break;
                
            case TelematicsAppAnimation_FILP_RIGHT:{
                    [UIView transitionWithView:tabBarItemview
                                  duration:1.5
                                   options: UIViewAnimationOptionTransitionFlipFromRight
                                animations:^{}
                                completion:^(BOOL finished) {
                                    //animationCompleteHandler
                                }];
            } break;
                
            case TelematicsAppAnimation_Cross_Dissolve:{
                    [UIView transitionWithView:tabBarItemview
                                  duration:0.7
                                   options: UIViewAnimationOptionTransitionCrossDissolve
                                animations:^{}
                                completion:^(BOOL finished) {
                                    //animationCompleteHandler
                                }];
            } break;
                
            case TelematicsAppAnimation_Fade:{
                [UIView animateWithDuration:0.6
                     animations:^{
                         tabBarItemview.alpha = 0;
                     }
                 completion:^(BOOL finished) {
                     
                     [UIView animateWithDuration:0.6
                      animations:^{
                          tabBarItemview.alpha = 1;
                      }
                      completion:^(BOOL finished) {
                          // Do other
                      }];
                 }];
                
            } break;
            case TelematicsAppAnimation_CurlUp:{
                [UIView transitionWithView:tabBarItemview
                                  duration:1.5
                                   options: UIViewAnimationOptionTransitionCurlUp
                                animations:^{}
                                completion:^(BOOL finished) {
                                    //animationCompleteHandler
                }];
            } break;
                
            case TelematicsAppAnimation_CurlDown:{
                [UIView transitionWithView:tabBarItemview
                                  duration:1.5
                                   options: UIViewAnimationOptionTransitionCurlDown
                                animations:^{}
                                completion:^(BOOL finished) {
                                    //animationCompleteHandler
                                }];
            } break;
                default:
                break;
        }
    }
    @catch (NSException *exception) {
        NSLog(@"%s:%@", __FUNCTION__, exception);
    }
    @finally {
        //
    }
}

+ (UIView *)getImageViewForTabInTabBar:(UITabBar*)tabBar withIndex:(NSUInteger)index {
    @try {
        NSUInteger currentTabIndex = 0;
        
        for (UIView* subView in tabBar.subviews)
        {
            if ([subView isKindOfClass:NSClassFromString(@"UITabBarButton")])
            {
                if (currentTabIndex == index) {
                    
                    for (UIView *imgView in subView.subviews) {
                        if ([imgView isKindOfClass:NSClassFromString(@"UITabBarSwappableImageView")]) {
                            return imgView ;
                        }
                    }
                }
                else
                    currentTabIndex++;
            }
        }
        
        NSAssert(NO, @"Index is out of bounds");
        return nil ;
    }
    @catch (NSException *exception) {
        //Exception
    }
    @finally {
        //
    }
}

@end
