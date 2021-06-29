//
//  NSArray+UITableViewAdditions.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 09.01.21.
//  Copyright © 2019-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "NSArray+UITableViewAdditions.h"

@implementation NSArray (UITableViewAdditions)

- (NSArray *)sectionsGroupedByKeyPath:(NSString *)keyPath
{
    return [self sectionsGroupedByKeyPath:keyPath ascending:NO];
}

- (NSArray *)sectionsGroupedByKeyPath:(NSString *)keyPath ascending:(BOOL)ascending
{
    NSMutableArray *sections = [NSMutableArray array];
    
    if ([self count] == 0)
        return sections;
    
    NSMutableArray *sectionItems = [NSMutableArray array];
    id currentGroup = [[self objectAtIndex:0] valueForKey:keyPath];
    
    for(id item in self)
    {
        id itemGroup = [item valueForKey:keyPath];
        
        if (![itemGroup isEqual:currentGroup])
        {
            [sections addObject:sectionItems];
            sectionItems = [NSMutableArray array];
            currentGroup = itemGroup;
        }
        
        [sectionItems addObject:item];
    }
    
    if ([sectionItems count] > 0)
        [sections addObject:sectionItems];
    return sections;
}

@end
