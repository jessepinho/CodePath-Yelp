//
//  MainViewController.m
//  Yelp
//
//  Created by Timothy Lee on 3/21/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import "MainViewController.h"
#import "YelpBusiness.h"
#import "BusinessTableViewCell.h"
#import "YelpBusiness.h"
#import "UIImageView+AFNetworking.h"

@interface MainViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UITableView *searchResultsTableView;
@property (strong, nonatomic) NSArray *businesses;
@property (strong, nonatomic) UISearchBar *searchBar;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpTable];
    [self setUpSearchBar];
    [self setUpNavigationItem];
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
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Filters" style:UIBarButtonItemStylePlain target:self action:@selector(openFilters)];
}

- (void)openFilters {

}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [YelpBusiness searchWithTerm:searchBar.text
                        sortMode:YelpSortModeBestMatched
                      categories:nil
                           deals:NO
                      completion:^(NSArray *businesses, NSError *error) {
                          self.businesses = businesses;
                          [self.searchResultsTableView reloadData];
                      }];
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
@end
