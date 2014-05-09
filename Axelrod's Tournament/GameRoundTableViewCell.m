//
//  GameRoundTableViewCell.m
//  Axelrod's Tournament
//
//  Created by Elliot Adderton on 28/04/2014.
//  Copyright (c) 2014 Elliot Adderton. All rights reserved.
//

#import "GameRoundTableViewCell.h"

@implementation GameRoundTableViewCell

+ (UINib *)nib
{
    return [UINib nibWithNibName:@"GameRoundTableViewCell" bundle:nil];
}

+ (uint)cellHeight
{
    return 117;
}

@end
