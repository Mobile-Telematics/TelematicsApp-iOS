//
//  CoreDataCoordinator.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 28.10.20.
//  Copyright © 2019-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "CoreDataCoordinator.h"

@implementation CoreDataCoordinator

+ (void)saveCoreDataCoordinatorContext {
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
        if (success) {
            NSLog(@"You successfully saved your context.");
        } else if (error) {
            NSLog(@"Error saving context: %@", error.description);
        }
    }];
}

+ (void)saveCoreDataCoordinatorContextArrays {
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
}

@end
