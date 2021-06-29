//
//  HapticHelper.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 19.04.21.
//  Copyright © 2019-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "HapticHelper.h"

@implementation HapticHelper

+ (void)generateFeedback:(FeedbackType)type{
    
    if ([[UIDevice currentDevice] systemVersion].floatValue < 10.0){
        return;
    }
    
    switch (type) {
        case FeedbackTypeSelection:
            [self generateSelectionFeedback];
            break;
        case FeedbackTypeImpactLight:
            [self generateImpactFeedback:UIImpactFeedbackStyleLight];
            break;
        case FeedbackTypeImpactMedium:
            [self generateImpactFeedback:UIImpactFeedbackStyleMedium];
            break;
        case FeedbackTypeImpactHeavy:
            [self generateImpactFeedback:UIImpactFeedbackStyleHeavy];
            break;
        case FeedbackTypeNotificationSuccess:
            [self generateNotificationFeedback:UINotificationFeedbackTypeSuccess];
            break;
        case FeedbackTypeNotificationWarning:
            [self generateNotificationFeedback:UINotificationFeedbackTypeWarning];
            break;
        case FeedbackTypeNotificationError:
            [self generateNotificationFeedback:UINotificationFeedbackTypeError];
            break;
        default:
            break;
    }
}

+ (void)generateSelectionFeedback{
    UISelectionFeedbackGenerator *generator = [[UISelectionFeedbackGenerator alloc] init];
    [generator prepare];
    [generator selectionChanged];
    generator = nil;
}

+ (void)generateImpactFeedback:(UIImpactFeedbackStyle)style{
    UIImpactFeedbackGenerator *generator = [[UIImpactFeedbackGenerator alloc] initWithStyle:style];
    [generator prepare];
    [generator impactOccurred]; 
    generator = nil;
}

+ (void)generateNotificationFeedback:(UINotificationFeedbackType)notificationType{
    UINotificationFeedbackGenerator *generator = [[UINotificationFeedbackGenerator alloc] init];
    [generator prepare];
    [generator notificationOccurred:notificationType];
    generator = nil;
}

@end
