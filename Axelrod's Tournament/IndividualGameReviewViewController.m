//
//  IndividualGameReviewViewController.m
//  Axelrod's Tournament
//
//  Created by Elliot Adderton on 20/04/2014.
//  Copyright (c) 2014 Elliot Adderton. All rights reserved.
//

#import "IndividualGameReviewViewController.h"

#import "InspectCellTableViewCell.h"
#import "Game.h"

@interface IndividualGameReviewViewController ()

@end

@implementation IndividualGameReviewViewController

-(void) viewDidLoad
{
    // set the title and nib for the cells
    self.nav.topItem.title = [NSString stringWithFormat:@"%@ vs %@",self.strategyNames[0],self.strategyNames[1]];
    [self.tableview registerNib:[InspectCellTableViewCell nib] forCellReuseIdentifier:InspectCellTableViewCellIdentifier];
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.roundData objectForKey:@"history"][0] count];// 100 iterations
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // use the nib
    InspectCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:InspectCellTableViewCellIdentifier forIndexPath:indexPath];
    if(cell == nil){
        cell = [[InspectCellTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:InspectCellTableViewCellIdentifier];
    }
    // set the values
    int player1 = [[[[self.roundData objectForKey:@"history"] objectAtIndex:0] objectAtIndex:indexPath.row] intValue];
    int player2 = [[[[self.roundData objectForKey:@"history"] objectAtIndex:1] objectAtIndex:indexPath.row] intValue];
    
    cell.s1Fate.text = (player1)?@"Defect":@"Cooperate";
    cell.s2Fate.text = (player2)?@"Defect":@"Cooperate";
    
    cell.s1Points.text = [NSString stringWithFormat:@"+[%d]",payoff[player1][player2]];
    cell.s2Points.text = [NSString stringWithFormat:@"+[%d]",payoff[player2][player1]];
    
    NSArray *payoffnames = @[@[@"Rewarded",@"< Sucker | Tempted >"],@[@"< Tempted | Sucker >",@"Punished"]];
    
    cell.payoffName.text = payoffnames[player1][player2];
    
    return cell;
}

// So much better than a segue unwind.
- (IBAction)doneButtonPress:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
