//
//  DefineLocalTournamentViewController.m
//  Axelrod's Tournament
//
//  Created by Elliot Adderton on 16/04/2014.
//  Copyright (c) 2014 Elliot Adderton. All rights reserved.
//

#import "DefineLocalTournamentViewController.h"

#import "GameRoundTableViewCell.h"
#import "Game.h"

#import "ResultPopUpViewController.h"

#define labelForTag(tag) ((UILabel*)[cell viewWithTag:tag])

@interface DefineLocalTournamentViewController ()
// the left table view with the strategies
@property(nonatomic,strong)NSArray* tableviewData;
// the right table view with the game data
@property(nonatomic,strong)NSArray* gameViewData;

@end

@implementation DefineLocalTournamentViewController

- (void) viewDidLoad
{
    // ensure that the left view with the strategies is editable i.e. can use tick boxes
    self.tableview.allowsMultipleSelectionDuringEditing = YES;
    // animation on the selection and the introduction of editing
    [self.tableview setEditing:YES animated:YES];
    // define the game view table cell nib files
    [self.gameTableView registerNib:[GameRoundTableViewCell nib] forCellReuseIdentifier:GameRoundCellIdentifier];
}
// Lazy init
- (NSArray*) gameViewData
{
    if(_gameViewData == nil)
        _gameViewData = [NSArray new];
    return _gameViewData;
}
// ensure that the correct size is returned for the cell's. we use custom sizes for the game view and this needs to be manually set
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(tableView == self.tableview) return 44;
    else return 117;
    
}
// Lazy init. pull all strategies available from the database document
- (NSArray*) tableviewData
{
    if(_tableviewData == nil){
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"MStrategy" inManagedObjectContext:appD.document.managedObjectContext];
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:entityDescription];
        [request setPredicate:nil];
        NSError *error;
        NSArray *array = [appD.document.managedObjectContext executeFetchRequest:request error:&error];
        if(error)
            NSLog(@"Database Error Occured in WelcomeViewController > contextDidSave");
        else{
            NSArray *sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES]];
            _tableviewData = [array sortedArrayUsingDescriptors:sortDescriptors];
        }
    }
    return _tableviewData;
}
// one section of strategies and many sections of games
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    if(tableView == self.tableview){
        return 1;
    }else{
        //NSLog(@"All KEYS: %@",(self.gameViewData.count)?[self.gameViewData[0] allKeys]:@"NO KEys");
        return [self.gameViewData count];
    }
}
// the number of strategies and the number of games within each round.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView == self.tableview){
        return [self.tableviewData count];
    }else{
        return [[[self.gameViewData objectAtIndex:section] objectForKey:@"rounds"] count];//GameViewTable
    }
}
// Set the titles for the tables
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(tableView == self.tableview){
        return @"Strategies";
    }else{
        return [NSString stringWithFormat:@"Game %d: %@ vs %@",(int)section+1,[[self.gameViewData objectAtIndex:section] objectForKey:@"strategy_1"],[[self.gameViewData objectAtIndex:section] objectForKey:@"strategy_2"]];
    }
}
// set the text for the cells in the tableviews
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == self.tableview){
        // list of strategies, use strategy name
        static NSString *CellIdentifier = @"basicCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil)
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
        [[cell textLabel] setText:((MStrategy*)[self.tableviewData objectAtIndex:indexPath.row]).name];
        return cell;
    }else {
        // The game view cells
        GameRoundTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:GameRoundCellIdentifier forIndexPath:indexPath];
        if(cell == nil){
            cell = [[GameRoundTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:GameRoundCellIdentifier];
        }
        // Set the strategy names
        cell.strategyOneLabel.text = [self.gameViewData[indexPath.section] objectForKey:@"strategy_1"];
        cell.strategyTwoLabel.text = [self.gameViewData[indexPath.section] objectForKey:@"strategy_2"];
        // ease of use array
        NSArray* payoffArray = [[[self.gameViewData[indexPath.section] objectForKey:@"rounds"] objectAtIndex:indexPath.row] objectForKey:@"payoffs"];
        // set the reward, punishment labels
        cell.rewardsLabel.text = [NSString stringWithFormat:@"%@ times",[[payoffArray objectAtIndex:0]objectAtIndex:0]];
        cell.punshmentsLabel.text = [NSString stringWithFormat:@"%@ times",[[payoffArray objectAtIndex:0]objectAtIndex:3]];
        // set the sucker labels
        cell.strategyOneSuckerTemptedLabel.text = [NSString stringWithFormat:@"%@/%@",
                                                   [[payoffArray objectAtIndex:0]objectAtIndex:1],
                                                   [[payoffArray objectAtIndex:0]objectAtIndex:2]];
        
        cell.strategyTwoSuckerTemptedLabel.text = [NSString stringWithFormat:@"%@/%@",
                                                   [[payoffArray objectAtIndex:1]objectAtIndex:1],
                                                   [[payoffArray objectAtIndex:1]objectAtIndex:2]];

        // define the winner using a trophy
        int p1score = [[[self.gameViewData[indexPath.section] objectForKey:@"rounds"][indexPath.row] objectForKey:@"p1score"] intValue];
        int p2score = [[[self.gameViewData[indexPath.section] objectForKey:@"rounds"][indexPath.row] objectForKey:@"p2score"] intValue];
        [cell.trophyOneImage setHidden:(BOOL)(p1score<p2score)];
        [cell.trophyTwoImage setHidden:(BOOL)(p1score>p2score)];
        [cell.drawLabel setText:(p1score==p2score)?@"Draw":@"Winner"];
        
        return cell;
    }
    
}
// footer text
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    // no footer text is needed for the strategies table view
    if(tableView == self.tableview){ return nil; }
    // we need to create a view for footers to work
    UIView *footer = [[UIView alloc]initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30)];
    footer.backgroundColor = [UIColor blackColor];
    
    UILabel *lbl = [[UILabel alloc]initWithFrame:footer.frame];
    lbl.backgroundColor = [UIColor clearColor];
    // find out if we are deaing with a draw or a winner
    int result = [[[self.gameViewData objectAtIndex:section] objectForKey:@"result"] integerValue];
    if(result == GameResultStateDraw){
        lbl.text = @"Draw";
    }else{
        NSString* winner = [[self.gameViewData objectAtIndex:section] objectForKey:(result == GameResultStatePlayerOneWinner)?@"strategy_1":@"strategy_2"];
        lbl.text = [NSString stringWithFormat:@"%@ Wins",winner];
    }
    lbl.textAlignment = NSTextAlignmentCenter;
    lbl.textColor = [UIColor whiteColor];
    [footer addSubview:lbl];
    // return the text in a view
    return footer;
}

// we need to define the size of a footer should one exist
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 30.0;
}
// footers float and group by default, we need to stop that
- (BOOL) allowsFooterViewsToFloat {
    return NO;
}
// if we select a game then we should present the game inspector
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == self.tableview) return;
    [self performSegueWithIdentifier:@"inspectRound" sender:self];
}
// start a tournmament
- (IBAction)startTaurnamentButtonPress:(id)sender {
    // if less than two strateiges are selected shown an error
    if([[self.tableview indexPathsForSelectedRows]count] < 2){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Select Strategies"
                                                        message:@"Select two or more strategies from the left for this option to work."
                                                       delegate:self cancelButtonTitle:@"Close"
                                              otherButtonTitles:nil];
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [alert show];
        });
        
    }else{
        // create a new game, send all the onjects across and then reload the data.
        Game *game = [[Game alloc] init];
        NSMutableArray *selectStrategies = [NSMutableArray new];
        for(NSIndexPath *indexPath in [self.tableview indexPathsForSelectedRows]){
            [selectStrategies addObject:[self.tableviewData objectAtIndex:indexPath.row]];
        }
        self.gameViewData = [game outcomeForStratagies:[selectStrategies copy]];
        [UIView animateWithDuration:0 animations:^{
            [self.gameTableView reloadData];
        }completion:^(BOOL finished) {
            [self performSegueWithIdentifier:@"resultsSegue" sender:self];
        }];
    }
}
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // present the game inspector is a game view row is tapped. this is a manual segue and needs to be handled as such
    if([segue.identifier isEqual:@"inspectRound"]){
        NSIndexPath *indexPath = [self.gameTableView indexPathForSelectedRow];
        [self.gameTableView deselectRowAtIndexPath:indexPath animated:NO];
        [(IndividualGameReviewViewController*)segue.destinationViewController
         setRoundData:[[self.gameViewData[indexPath.section] objectForKey:@"rounds"] objectAtIndex:indexPath.row]];
        [(IndividualGameReviewViewController*)segue.destinationViewController
         setStrategyNames:@[[self.gameViewData[indexPath.section] objectForKey:@"strategy_1"],[self.gameViewData[indexPath.section] objectForKey:@"strategy_2"]]];
    }else if([segue.identifier isEqual:@"resultsSegue"]){
        // once the results from a game come back we present the results pane
        NSMutableDictionary *winners = [NSMutableDictionary new];
        // we order the winners based off their scores and return an array of sorted winners
        for(int section = 0; section<self.gameViewData.count; section++ ){
            for(int row = 0; row<[[self.gameViewData[section] objectForKey:@"rounds"] count]; row++ ){
        int p1score = [[[self.gameViewData[section] objectForKey:@"rounds"][row] objectForKey:@"p1score"] intValue];
        int p2score = [[[self.gameViewData[section] objectForKey:@"rounds"][row] objectForKey:@"p2score"] intValue];

        if([winners objectForKey:[self.gameViewData[section] objectForKey:@"strategy_1"]]){
            [winners setObject:[NSNumber numberWithLong:p1score+[[[winners objectForKey:self.gameViewData[section]] objectForKey:@"strategy_1"] longValue]]
                             forKey:[self.gameViewData[section] objectForKey:@"strategy_1"]];
        }else{
            [winners setObject:@(p1score)
                             forKey:[self.gameViewData[section] objectForKey:@"strategy_1"]];
        }
        
        if([winners objectForKey:[self.gameViewData[section] objectForKey:@"strategy_2"]]){
            [winners setObject:[NSNumber numberWithLong:p2score+[[[winners objectForKey:self.gameViewData[section]] objectForKey:@"strategy_2"] longValue]]
                             forKey:[self.gameViewData[section] objectForKey:@"strategy_2"]];
        }else{
            [winners setObject:@(p2score)
                             forKey:[self.gameViewData[section] objectForKey:@"strategy_2"]];
        }
            }
        }
        
        NSArray *orderedWinners;
        
        orderedWinners = [winners keysSortedByValueUsingComparator: ^(id obj1, id obj2) {
            
            if ([obj1 unsignedLongValue] < [obj2 unsignedLongValue]) return (NSComparisonResult)NSOrderedDescending;
            if ([obj1 unsignedLongValue] > [obj2 unsignedLongValue]) return (NSComparisonResult)NSOrderedAscending;
            return (NSComparisonResult)NSOrderedSame;
        }];
        
        [(ResultPopUpViewController*)segue.destinationViewController setWinners:orderedWinners];
    }
    
}


@end
