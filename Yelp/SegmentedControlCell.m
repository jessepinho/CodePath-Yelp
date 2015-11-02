//
//  SegmentedControlCell.m
//  Yelp
//
//  Created by Jesse Pinho on 11/1/15.
//  Copyright © 2015 codepath. All rights reserved.
//

#import "SegmentedControlCell.h"

@interface SegmentedControlCell ()
- (IBAction)didUpdateValue:(id)sender;
@end

@implementation SegmentedControlCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)didUpdateValue:(id)sender {
    [self.delegate segmentedControlCell:self didUpdateValue:self.segmentedControl.selectedSegmentIndex];
}
@end
