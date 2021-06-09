//
//  NSArray+UITableViewAdditions.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 09.01.18.
//  Copyright © 2019-2021 DATA MOTION PTE. LTD. All rights reserved.
//

@import Foundation;

@interface NSArray (UITableViewAdditions)

- (NSArray *)sectionsGroupedByKeyPath:(NSString *)keyPath;
- (NSArray *)sectionsGroupedByKeyPath:(NSString *)keyPath ascending:(BOOL)ascending;

@end
