//
//  HapticHelper.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 19.04.21.
//  Copyright © 2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef enum {
    FeedbackTypeSelection,
    FeedbackTypeImpactLight,
    FeedbackTypeImpactMedium,
    FeedbackTypeImpactHeavy,
    FeedbackTypeNotificationSuccess,
    FeedbackTypeNotificationWarning,
    FeedbackTypeNotificationError
} FeedbackType;

@interface HapticHelper : NSObject

+ (void)generateFeedback:(FeedbackType)type;

@end
