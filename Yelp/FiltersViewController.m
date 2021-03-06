//
//  FiltersViewController.m
//  Yelp
//
//  Created by Jesse Pinho on 11/1/15.
//  Copyright © 2015 codepath. All rights reserved.
//

#import "FiltersViewController.h"
#import "SegmentedControlCell.h"
#import "SwitchCell.h"
#import "YelpClient.h"

@interface FiltersViewController () <UITableViewDataSource, UITableViewDelegate, SwitchCellDelegate, SegmentControllCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, readonly) NSDictionary *filters;
@property (nonatomic, strong) NSArray *sections;
@property (nonatomic, strong) NSArray *categories;
@property BOOL offeringDeal;
@property (nonatomic, strong) NSNumber *sortMode;
@property (nonatomic, strong) NSMutableSet *selectedCategories;
@property (nonatomic, strong) NSArray *sortModes;
@property (nonatomic, strong) NSArray *radii;
@property (nonatomic, strong) NSNumber *radius;
@end

@implementation FiltersViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

    if (self) {
        self.selectedCategories = [NSMutableSet set];
        [self initSections];
        [self initCategories];
        self.sortModes = @[@(YelpSortModeBestMatched), @(YelpSortModeDistance), @(YelpSortModeHighestRated)];
        self.radii = @[@1000, @5000, @10000];
    }

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpTable];
    [self setUpNavigationBar];
    self.title = @"Filters";
}

- (void)initSections {
    self.sections = @[@"Offering a deal", @"Sort mode", @"Distance", @"Categories"];
}

- (void)setUpNavigationBar {
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(onCancelButton)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Apply" style:UIBarButtonItemStylePlain target:self action:@selector(onApplyButton)];
}

- (void)setUpTable {
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"SwitchCell" bundle:nil] forCellReuseIdentifier:@"CategoryCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"SwitchCell" bundle:nil] forCellReuseIdentifier:@"OfferingDealCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"SegmentedControlCell" bundle:nil] forCellReuseIdentifier:@"SortModeCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"SegmentedControlCell" bundle:nil] forCellReuseIdentifier:@"DistanceCell"];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sections.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
            return [self getOfferingDealCell];
        case 1:
            return [self getSortModeCell];
        case 2:
            return [self getDistanceCell];
        case 3:
            return [self categoryCellForRow:indexPath.row];
        default:
            return nil;
    }
}

- (SwitchCell *)getOfferingDealCell {
    SwitchCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"OfferingDealCell"];
    cell.on = self.offeringDeal;
    cell.titleLabel.text = @"Offering a deal";
    cell.delegate = self;
    return cell;
}

- (SegmentedControlCell *)getSortModeCell {
    SegmentedControlCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"SortModeCell"];
    [cell.segmentedControl removeAllSegments];
    [cell.segmentedControl insertSegmentWithTitle:@"Best match" atIndex:0 animated:NO];
    [cell.segmentedControl insertSegmentWithTitle:@"Distance" atIndex:1 animated:NO];
    [cell.segmentedControl insertSegmentWithTitle:@"Rating" atIndex:2 animated:NO];
    cell.delegate = self;
    return cell;
}

- (SegmentedControlCell *)getDistanceCell {
    SegmentedControlCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"DistanceCell"];
    [cell.segmentedControl removeAllSegments];
    [cell.segmentedControl insertSegmentWithTitle:@"1km" atIndex:0 animated:NO];
    [cell.segmentedControl insertSegmentWithTitle:@"5km" atIndex:1 animated:NO];
    [cell.segmentedControl insertSegmentWithTitle:@"10km" atIndex:2 animated:NO];
    cell.delegate = self;
    return cell;
}

- (void)segmentedControlCell:(SegmentedControlCell *)cell didUpdateValue:(NSInteger)value {
    if ([cell.reuseIdentifier isEqualToString:@"SortModeCell"]) {
        self.sortMode = self.sortModes[value];
    } else if ([cell.reuseIdentifier isEqualToString:@"DistanceCell"]) {
        self.radius = self.radii[value];
    }
}

- (SwitchCell *)categoryCellForRow:(NSInteger)row {
    SwitchCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"CategoryCell"];
    cell.on = [self.selectedCategories containsObject:self.categories[row]];
    cell.titleLabel.text = self.categories[row][@"name"];
    cell.delegate = self;
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
        case 1:
        case 2:
            return 1;
        case 3:
            return self.categories.count;
        default:
            return 1;
    }
}

- (void)switchCell:(SwitchCell *)cell didUpdateValue:(BOOL)value {
    if ([cell.reuseIdentifier isEqualToString:@"OfferingDealCell"]) {
        self.offeringDeal = value;
    } else {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        if (value) {
            [self.selectedCategories addObject:self.categories[indexPath.row]];
        } else {
            [self.selectedCategories removeObject:self.categories[indexPath.row]];
        }
    }
}

- (void)onCancelButton {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)onApplyButton {
    [self.delegate filtersViewController:self didChangeFilters:self.filters];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSDictionary *)filters {
    NSMutableDictionary *filters = [NSMutableDictionary dictionary];
    if (self.selectedCategories.count > 0) {
        NSMutableArray *categoryNames = [NSMutableArray array];
        for (NSDictionary *category in self.selectedCategories) {
            [categoryNames addObject:category[@"code"]];
        }
        [filters setObject:categoryNames forKey:@"categories"];
    }

    if (self.offeringDeal) {
        [filters setObject:@1 forKey:@"offeringDeal"];
    }
    if (self.sortMode) {
        [filters setValue:self.sortMode forKey:@"sortMode"];
    } else {
        [filters setValue:YelpSortModeBestMatched forKey:@"sortMode"];
    }
    
    if (self.radius) {
        [filters setValue:self.radius forKey:@"radius"];
    }
    return filters;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.sections[section];
}

- (void)initCategories {
    self.categories = @[@{@"name": @"Afghan", @"code": @"afghani"},
                        @{@"name": @"African", @"code": @"african"},
                        @{@"name": @"American, New", @"code": @"newamerican"},
                        @{@"name": @"American, Traditional", @"code": @"tradamerican"},
                        @{@"name": @"Arabian", @"code": @"arabian"},
                        @{@"name": @"Argentine", @"code": @"argentine"},
                        @{@"name": @"Armenian", @"code": @"armenian"},
                        @{@"name": @"Asian Fusion", @"code": @"asianfusion"},
                        @{@"name": @"Asturian", @"code": @"asturian"},
                        @{@"name": @"Australian", @"code": @"australian"},
                        @{@"name": @"Austrian", @"code": @"austrian"},
                        @{@"name": @"Baguettes", @"code": @"baguettes"},
                        @{@"name": @"Bangladeshi", @"code": @"bangladeshi"},
                        @{@"name": @"Barbeque", @"code": @"bbq"},
                        @{@"name": @"Basque", @"code": @"basque"},
                        @{@"name": @"Bavarian", @"code": @"bavarian"},
                        @{@"name": @"Beer Garden", @"code": @"beergarden"},
                        @{@"name": @"Beer Hall", @"code": @"beerhall"},
                        @{@"name": @"Beisl", @"code": @"beisl"},
                        @{@"name": @"Belgian", @"code": @"belgian"},
                        @{@"name": @"Bistros", @"code": @"bistros"},
                        @{@"name": @"Black Sea", @"code": @"blacksea"},
                        @{@"name": @"Brasseries", @"code": @"brasseries"},
                        @{@"name": @"Brazilian", @"code": @"brazilian"},
                        @{@"name": @"Breakfast & Brunch", @"code": @"breakfast_brunch"},
                        @{@"name": @"British", @"code": @"british"},
                        @{@"name": @"Buffets", @"code": @"buffets"},
                        @{@"name": @"Bulgarian", @"code": @"bulgarian"},
                        @{@"name": @"Burgers", @"code": @"burgers"},
                        @{@"name": @"Burmese", @"code": @"burmese"},
                        @{@"name": @"Cafes", @"code": @"cafes"},
                        @{@"name": @"Cafeteria", @"code": @"cafeteria"},
                        @{@"name": @"Cajun/Creole", @"code": @"cajun"},
                        @{@"name": @"Cambodian", @"code": @"cambodian"},
                        @{@"name": @"Canadian", @"code": @"New)"},
                        @{@"name": @"Canteen", @"code": @"canteen"},
                        @{@"name": @"Caribbean", @"code": @"caribbean"},
                        @{@"name": @"Catalan", @"code": @"catalan"},
                        @{@"name": @"Chech", @"code": @"chech"},
                        @{@"name": @"Cheesesteaks", @"code": @"cheesesteaks"},
                        @{@"name": @"Chicken Shop", @"code": @"chickenshop"},
                        @{@"name": @"Chicken Wings", @"code": @"chicken_wings"},
                        @{@"name": @"Chilean", @"code": @"chilean"},
                        @{@"name": @"Chinese", @"code": @"chinese"},
                        @{@"name": @"Comfort Food", @"code": @"comfortfood"},
                        @{@"name": @"Corsican", @"code": @"corsican"},
                        @{@"name": @"Creperies", @"code": @"creperies"},
                        @{@"name": @"Cuban", @"code": @"cuban"},
                        @{@"name": @"Curry Sausage", @"code": @"currysausage"},
                        @{@"name": @"Cypriot", @"code": @"cypriot"},
                        @{@"name": @"Czech", @"code": @"czech"},
                        @{@"name": @"Czech/Slovakian", @"code": @"czechslovakian"},
                        @{@"name": @"Danish", @"code": @"danish"},
                        @{@"name": @"Delis", @"code": @"delis"},
                        @{@"name": @"Diners", @"code": @"diners"},
                        @{@"name": @"Dumplings", @"code": @"dumplings"},
                        @{@"name": @"Eastern European", @"code": @"eastern_european"},
                        @{@"name": @"Ethiopian", @"code": @"ethiopian"},
                        @{@"name": @"Fast Food", @"code": @"hotdogs"},
                        @{@"name": @"Filipino", @"code": @"filipino"},
                        @{@"name": @"Fish & Chips", @"code": @"fishnchips"},
                        @{@"name": @"Fondue", @"code": @"fondue"},
                        @{@"name": @"Food Court", @"code": @"food_court"},
                        @{@"name": @"Food Stands", @"code": @"foodstands"},
                        @{@"name": @"French", @"code": @"french"},
                        @{@"name": @"French Southwest", @"code": @"sud_ouest"},
                        @{@"name": @"Galician", @"code": @"galician"},
                        @{@"name": @"Gastropubs", @"code": @"gastropubs"},
                        @{@"name": @"Georgian", @"code": @"georgian"},
                        @{@"name": @"German", @"code": @"german"},
                        @{@"name": @"Giblets", @"code": @"giblets"},
                        @{@"name": @"Gluten-Free", @"code": @"gluten_free"},
                        @{@"name": @"Greek", @"code": @"greek"},
                        @{@"name": @"Halal", @"code": @"halal"},
                        @{@"name": @"Hawaiian", @"code": @"hawaiian"},
                        @{@"name": @"Heuriger", @"code": @"heuriger"},
                        @{@"name": @"Himalayan/Nepalese", @"code": @"himalayan"},
                        @{@"name": @"Hong Kong Style Cafe", @"code": @"hkcafe"},
                        @{@"name": @"Hot Dogs", @"code": @"hotdog"},
                        @{@"name": @"Hot Pot", @"code": @"hotpot"},
                        @{@"name": @"Hungarian", @"code": @"hungarian"},
                        @{@"name": @"Iberian", @"code": @"iberian"},
                        @{@"name": @"Indian", @"code": @"indpak"},
                        @{@"name": @"Indonesian", @"code": @"indonesian"},
                        @{@"name": @"International", @"code": @"international"},
                        @{@"name": @"Irish", @"code": @"irish"},
                        @{@"name": @"Island Pub", @"code": @"island_pub"},
                        @{@"name": @"Israeli", @"code": @"israeli"},
                        @{@"name": @"Italian", @"code": @"italian"},
                        @{@"name": @"Japanese", @"code": @"japanese"},
                        @{@"name": @"Jewish", @"code": @"jewish"},
                        @{@"name": @"Kebab", @"code": @"kebab"},
                        @{@"name": @"Korean", @"code": @"korean"},
                        @{@"name": @"Kosher", @"code": @"kosher"},
                        @{@"name": @"Kurdish", @"code": @"kurdish"},
                        @{@"name": @"Laos", @"code": @"laos"},
                        @{@"name": @"Laotian", @"code": @"laotian"},
                        @{@"name": @"Latin American", @"code": @"latin"},
                        @{@"name": @"Live/Raw Food", @"code": @"raw_food"},
                        @{@"name": @"Lyonnais", @"code": @"lyonnais"},
                        @{@"name": @"Malaysian", @"code": @"malaysian"},
                        @{@"name": @"Meatballs", @"code": @"meatballs"},
                        @{@"name": @"Mediterranean", @"code": @"mediterranean"},
                        @{@"name": @"Mexican", @"code": @"mexican"},
                        @{@"name": @"Middle Eastern", @"code": @"mideastern"},
                        @{@"name": @"Milk Bars", @"code": @"milkbars"},
                        @{@"name": @"Modern Australian", @"code": @"modern_australian"},
                        @{@"name": @"Modern European", @"code": @"modern_european"},
                        @{@"name": @"Mongolian", @"code": @"mongolian"},
                        @{@"name": @"Moroccan", @"code": @"moroccan"},
                        @{@"name": @"New Zealand", @"code": @"newzealand"},
                        @{@"name": @"Night Food", @"code": @"nightfood"},
                        @{@"name": @"Norcinerie", @"code": @"norcinerie"},
                        @{@"name": @"Open Sandwiches", @"code": @"opensandwiches"},
                        @{@"name": @"Oriental", @"code": @"oriental"},
                        @{@"name": @"Pakistani", @"code": @"pakistani"},
                        @{@"name": @"Parent Cafes", @"code": @"eltern_cafes"},
                        @{@"name": @"Parma", @"code": @"parma"},
                        @{@"name": @"Persian/Iranian", @"code": @"persian"},
                        @{@"name": @"Peruvian", @"code": @"peruvian"},
                        @{@"name": @"Pita", @"code": @"pita"},
                        @{@"name": @"Pizza", @"code": @"pizza"},
                        @{@"name": @"Polish", @"code": @"polish"},
                        @{@"name": @"Portuguese", @"code": @"portuguese"},
                        @{@"name": @"Potatoes", @"code": @"potatoes"},
                        @{@"name": @"Poutineries", @"code": @"poutineries"},
                        @{@"name": @"Pub Food", @"code": @"pubfood"},
                        @{@"name": @"Rice", @"code": @"riceshop"},
                        @{@"name": @"Romanian", @"code": @"romanian"},
                        @{@"name": @"Rotisserie Chicken", @"code": @"rotisserie_chicken"},
                        @{@"name": @"Rumanian", @"code": @"rumanian"},
                        @{@"name": @"Russian", @"code": @"russian"},
                        @{@"name": @"Salad", @"code": @"salad"},
                        @{@"name": @"Sandwiches", @"code": @"sandwiches"},
                        @{@"name": @"Scandinavian", @"code": @"scandinavian"},
                        @{@"name": @"Scottish", @"code": @"scottish"},
                        @{@"name": @"Seafood", @"code": @"seafood"},
                        @{@"name": @"Serbo Croatian", @"code": @"serbocroatian"},
                        @{@"name": @"Signature Cuisine", @"code": @"signature_cuisine"},
                        @{@"name": @"Singaporean", @"code": @"singaporean"},
                        @{@"name": @"Slovakian", @"code": @"slovakian"},
                        @{@"name": @"Soul Food", @"code": @"soulfood"},
                        @{@"name": @"Soup", @"code": @"soup"},
                        @{@"name": @"Southern", @"code": @"southern"},
                        @{@"name": @"Spanish", @"code": @"spanish"},
                        @{@"name": @"Steakhouses", @"code": @"steak"},
                        @{@"name": @"Sushi Bars", @"code": @"sushi"},
                        @{@"name": @"Swabian", @"code": @"swabian"},
                        @{@"name": @"Swedish", @"code": @"swedish"},
                        @{@"name": @"Swiss Food", @"code": @"swissfood"},
                        @{@"name": @"Tabernas", @"code": @"tabernas"},
                        @{@"name": @"Taiwanese", @"code": @"taiwanese"},
                        @{@"name": @"Tapas Bars", @"code": @"tapas"},
                        @{@"name": @"Tapas/Small Plates", @"code": @"tapasmallplates"},
                        @{@"name": @"Tex-Mex", @"code": @"tex-mex"},
                        @{@"name": @"Thai", @"code": @"thai"},
                        @{@"name": @"Traditional Norwegian", @"code": @"norwegian"},
                        @{@"name": @"Traditional Swedish", @"code": @"traditional_swedish"},
                        @{@"name": @"Trattorie", @"code": @"trattorie"},
                        @{@"name": @"Turkish", @"code": @"turkish"},
                        @{@"name": @"Ukrainian", @"code": @"ukrainian"},
                        @{@"name": @"Uzbek", @"code": @"uzbek"},
                        @{@"name": @"Vegan", @"code": @"vegan"},
                        @{@"name": @"Vegetarian", @"code": @"vegetarian"},
                        @{@"name": @"Venison", @"code": @"venison"},
                        @{@"name": @"Vietnamese", @"code": @"vietnamese"},
                        @{@"name": @"Wok", @"code": @"wok"},
                        @{@"name": @"Wraps", @"code": @"wraps"},
                        @{@"name": @"Yugoslav", @"code": @"yugoslav"}];
}
@end
