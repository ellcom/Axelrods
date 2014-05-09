//
//  GameRoundTableViewCell.h
//  Axelrod's Tournament
//
//  Created by Elliot Adderton on 28/04/2014.
//  Copyright (c) 2014 Elliot Adderton. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString* const GameRoundCellIdentifier = @"GameRoundCell";

@interface GameRoundTableViewCell : UITableViewCell

+ (UINib *)nib;
+ (uint)cellHeight;

@property (weak, nonatomic) IBOutlet UILabel* strategyOneLabel;
@property (weak, nonatomic) IBOutlet UILabel* strategyTwoLabel;

@property (weak, nonatomic) IBOutlet UILabel* punshmentsLabel;
@property (weak, nonatomic) IBOutlet UILabel* rewardsLabel;

@property (weak, nonatomic) IBOutlet UILabel* strategyOneSuckerTemptedLabel;
@property (weak, nonatomic) IBOutlet UILabel* strategyTwoSuckerTemptedLabel;

@property (weak, nonatomic) IBOutlet UIImageView* trophyOneImage;
@property (weak, nonatomic) IBOutlet UIImageView* trophyTwoImage;
@property (weak, nonatomic) IBOutlet UILabel* drawLabel;

@end
