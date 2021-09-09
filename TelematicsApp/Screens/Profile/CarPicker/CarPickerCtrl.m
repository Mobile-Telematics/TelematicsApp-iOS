//
//  CarPickerCtrl.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 26.11.20.
//  Copyright © 2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "CarPickerCtrl.h"
#import "BaseViewController.h"
#import "Color.h"
#import "UIViewController+Preloader.h"

@interface CarPickerCtrl () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchResultsUpdating, UISearchControllerDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITableView        *tableView;
@property (nonatomic) UISearchController                *searchController;

@property (nonatomic, strong) NSDictionary              *allCarsManufacturers;
@property (nonatomic, strong) NSDictionary              *allCarsModels;
@property (nonatomic) NSString                          *picked;

@end

@implementation CarPickerCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.frame = CGRectMake(0, 20.0f, self.view.frame.size.width, self.view.frame.size.height);
    
    self.view.backgroundColor = [Color officialWhiteColor];
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.searchController.searchBar.delegate = self;
    self.searchController.delegate = self;
    self.tableView.tableHeaderView = self.searchController.searchBar;
    
    self.searchController.searchBar.returnKeyType = UIReturnKeyDone;
    self.searchController.searchBar.tintColor = [Color officialMainAppColor];
    self.searchController.definesPresentationContext = YES;
    
    self.shiftHeight = -1;
    [self registerForKeyboardNotifications];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.brands = [self.brands filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id obj, NSDictionary *d) {
        return ![[obj valueForKey:@"Name"] isEqual:@"No option"];
    }]];

    self.brandsFiltered = [self.brandsFiltered filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id obj, NSDictionary *d) {
        return ![[obj valueForKey:@"Name"] isEqual:@"No option"];
    }]];
    
    self.models = [self.models filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id obj, NSDictionary *d) {
        return ![[obj valueForKey:@"Name"] isEqual:@"No option"];
    }]];

    self.modelsFiltered = [self.modelsFiltered filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id obj, NSDictionary *d) {
        return ![[obj valueForKey:@"Name"] isEqual:@"No option"];
    }]];
    
    if (self.pickType == PickBrand)
        self.searchController.searchBar.placeholder = localizeString(@"Make");
    if (self.pickType == PickModel)
        self.searchController.searchBar.placeholder = localizeString(@"Model");
    
    self.searchController.searchBar.text = @"";
    [self updateDatasource];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.searchController setActive:YES];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)updateDatasource {
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.pickType == PickBrand) {
        if (self.searchController.searchBar.text.length > 0) {
            return self.brandsFiltered.count;
        } else {
            return self.brands.count;
        }
    }
    if (self.pickType == PickModel) {
        if (self.searchController.searchBar.text.length > 0) {
            return self.modelsFiltered.count;
        } else {
            return self.models.count;
        }
    }
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *pick;
    if (self.pickType == PickBrand) {
        if (self.searchController.searchBar.text.length > 0) {
            pick = self.brandsFiltered[indexPath.row];
            self.picked = self.brandsFiltered[indexPath.row];
        } else {
            pick = self.brands[indexPath.row];
            self.picked = self.brands[indexPath.row];
        }
    }
    
    if (self.pickType == PickModel) {
        if (self.searchController.searchBar.text.length > 0) {
            pick = self.modelsFiltered[indexPath.row];
            self.picked = self.modelsFiltered[indexPath.row];
        } else {
            pick = self.models[indexPath.row];
            self.picked = self.models[indexPath.row];
        }
    }
    
    [self.searchController.searchBar resignFirstResponder];
    [self.delegate carPickerDidPick:pick];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CarCell"];
    
    if (self.pickType == PickBrand) {
        if (self.searchController.searchBar.text.length > 0) {
            cell.textLabel.text = [self.brandsFiltered[indexPath.row] valueForKey:@"Name"];
        } else {
            cell.textLabel.text = [self.brands[indexPath.row] valueForKey:@"Name"];
        }
    }
    if (self.pickType == PickModel) {
        if (self.searchController.searchBar.text.length > 0) {
            cell.textLabel.text = [self.modelsFiltered[indexPath.row] valueForKey:@"Name"];
        } else {
            cell.textLabel.text = [self.models[indexPath.row] valueForKey:@"Name"];
        }
    }
    
    return cell;
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    //self.brandsFiltered = @[];
    //self.modelsFiltered = @[];
    
    if (self.pickType == PickBrand) {
        self.brandsFiltered = [self.brands filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id object, NSDictionary *bindings) {
            return [[object valueForKey:@"Name"] localizedCaseInsensitiveContainsString:searchController.searchBar.text] || [[object valueForKey:@"Name"] isEqual:@"OTHER"] || [[object valueForKey:@"Name"] isEqual:@"Other"];
        }]];
    } else if (self.pickType == PickModel) {
        if ([self.models isKindOfClass:[NSArray class]]) {
            if (self.models.count > 0) {
                self.modelsFiltered = [self.models filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id object, NSDictionary *bindings) {
                    return [[object valueForKey:@"Name"] localizedCaseInsensitiveContainsString:searchController.searchBar.text] || [[object valueForKey:@"Name"] isEqual:@"OTHER"] || [[object valueForKey:@"Name"] isEqual:@"Other"];
                }]];
            }
        }
    }
    
    [self updateDatasource];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self.searchController.searchBar resignFirstResponder];
    [self.delegate carPickerDidCancel];
}

- (void)didPresentSearchController:(UISearchController *)searchController {
    [searchController.searchBar becomeFirstResponder];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
//ADD NEW VEHICLE MANUFACTURER DISABLED
//    NSString *pick = @{@"Id": @"00",
//                       @"Name": searchBar.text};
//
//    [self.delegate carPickerDidPick:pick];
}


#pragma mark - Keyboard Delegate

- (void)keyboardWasShown:(NSNotification *)notification {
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height + 15, 0.0);
    self.tableView.contentInset = contentInsets;
    self.tableView.scrollIndicatorInsets = contentInsets;
    
    CGRect aRect = self.view.frame;
    aRect.size.height -= keyboardSize.height;
    if (!CGRectContainsPoint(aRect, self.searchController.searchBar.frame.origin) ) {
        CGPoint scrollPoint = CGPointMake(0.0, self.searchController.searchBar.frame.origin.y - (keyboardSize.height-15));
        [self.tableView setContentOffset:scrollPoint animated:YES];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.tableView.contentInset = contentInsets;
    self.tableView.scrollIndicatorInsets = contentInsets;
}

@end
