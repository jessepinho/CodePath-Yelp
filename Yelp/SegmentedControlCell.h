//
//  SegmentedControlCell.h
//  Yelp
//
//  Created by Jesse Pinho on 11/1/15.
//  Copyright © 2015 codepath. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SegmentedControlCell;

@protocol SegmentControllCellDelegate <NSObject>
- (void)segmentedControlCell:(SegmentedControlCell *)cell didUpdateValue:(NSInteger)value;
@end

@interface SegmentedControlCell : UITableViewCell
@property (nonatomic, weak) id<SegmentControllCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@end
