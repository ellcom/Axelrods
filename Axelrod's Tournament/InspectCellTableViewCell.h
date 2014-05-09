//
//  InspectCellTableViewCell.h
//  Axelrod's Tournament
//
//  Created by Elliot Adderton on 30/04/2014.
//  Copyright (c) 2014 Elliot Adderton. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString * const InspectCellTableViewCellIdentifier = @"InspectCellTableViewCell";

@interface InspectCellTableViewCell : UITableViewCell

+ (UINib *)nib;

@property (weak, nonatomic) IBOutlet UILabel *s1Fate;
@property (weak, nonatomic) IBOutlet UILabel *s2Fate;
@property (weak, nonatomic) IBOutlet UILabel *s1Points;
@property (weak, nonatomic) IBOutlet UILabel *s2Points;
@property (weak, nonatomic) IBOutlet UILabel *payoffName;

@end
