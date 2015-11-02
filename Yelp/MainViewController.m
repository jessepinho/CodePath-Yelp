//
//  MainViewController.m
//  Yelp
//
//  Created by Timothy Lee on 3/21/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import "BusinessTableViewCell.h"
#import "FiltersViewController.h"
#import "MainViewController.h"
#import "UIImageView+AFNetworking.h"
#import "YelpBusiness.h"

@interface MainViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, FiltersViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *searchResultsTableView;
@property (strong, nonatomic) NSArray *businesses;
@property (strong, nonatomic) UISearchBar *searchBar;

- (void)fetchBusinessesWithQuery:(NSString *)query params:(NSDictionary *)params;
@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpTable];
    [self setUpSearchBar];
    [self setUpNavigationItem];
    [self fetchBusinessesWithQuery:@"" params:nil];
}

- (void)setUpTable {
    [self.searchResultsTableView registerNib:[UINib nibWithNibName:@"BusinessTableViewCell" bundle:nil] forCellReuseIdentifier:@"BusinessTableViewCell"];
    self.searchResultsTableView.dataSource = self;
    self.searchResultsTableView.delegate = self;
    self.searchResultsTableView.estimatedRowHeight = 96;
    self.searchResultsTableView.rowHeight = UITableViewAutomaticDimension;
}

- (void)setUpSearchBar {
    self.searchBar = [[UISearchBar alloc] init];
    self.searchBar.delegate = self;
    [self.searchBar sizeToFit];
}

- (void)setUpNavigationItem {
    self.navigationItem.titleView = self.searchBar;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Filter" style:UIBarButtonItemStylePlain target:self action:@selector(onFilterButton)];
}

- (void)onFilterButton {
    FiltersViewController *fvc = [[FiltersViewController alloc] init];
    fvc.delegate = self;
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:fvc];
    [self presentViewController:nvc animated:YES completion:nil];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self fetchBusinessesWithQuery:searchBar.text params:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.businesses.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BusinessTableViewCell *cell = [self.searchResultsTableView dequeueReusableCellWithIdentifier:@"BusinessTableViewCell"];
    YelpBusiness *business = self.businesses[indexPath.row];
    cell.nameLabel.text = business.name;
    [cell.nameLabel sizeToFit];
    [cell.businessImageView setImageWithURL:business.imageUrl];
    [cell.ratingImageView setImageWithURL:business.ratingImageUrl];
    cell.reviewCountLabel.text = [NSString stringWithFormat:@"%@ reviews", business.reviewCount];
    return cell;
}

- (void)filtersViewController:(FiltersViewController *)filtersViewController didChangeFilters:(NSDictionary *)filters {
    [self fetchBusinessesWithQuery:self.searchBar.text params:filters];
}

- (void)fetchBusinessesWithQuery:(NSString *)query params:(NSDictionary *)params {
    NSNumber *sortMode = params[@"sortMode"];
    [YelpBusiness searchWithTerm:self.searchBar.text
                        sortMode:[sortMode integerValue]
                      categories:params[@"categories"]
                           deals:(params[@"offeringDeal"] ? YES : NO)
                          radius:params[@"radius"]
                      completion:^(NSArray *businesses, NSError *error) {
                          self.businesses = businesses;
                          [self.searchResultsTableView reloadData];
                      }];
}
@end
