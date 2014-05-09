//
//  ResultPopUpViewController.m
//  Axelrod's Tournament
//
//  Created by Elliot Adderton on 30/04/2014.
//  Copyright (c) 2014 Elliot Adderton. All rights reserved.
//

#import "ResultPopUpViewController.h"
// 1ST 2ND, the ST ND RD TH suffix
#define SUFFIX(x) (x%10==1 && x != 11)?@"st":(x%10 == 2 && x != 12)?@"nd":(x%10 == 3 && x != 13)?@"rd":@"th"

@interface ResultPopUpViewController ()

@end

@implementation ResultPopUpViewController

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // list the number of strategies
    return self.winners.count;
}

-(void)viewWillAppear:(BOOL)animated
{
    // resize the view
    [self.view.superview setBounds:CGRectMake(0, 0, 540, 300)];
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // create cell for each winner
    static NSString * const cellIdentifier = @"detailCell";
    UITableViewCell *cell = [self.tableview dequeueReusableCellWithIdentifier:cellIdentifier];
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    cell.textLabel.text = self.winners[indexPath.row];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d%@ place",indexPath.row+1,SUFFIX(indexPath.row+1)];
    //1st 2nd 3rd 4th 4th .. 21st 22nd 2rd
    
    if(indexPath.row%2){
        cell.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
    }
    
    return cell;
}

-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    return NO;
}


- (IBAction)doneButtonPressed:(id)sender {
    // remove from view
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
