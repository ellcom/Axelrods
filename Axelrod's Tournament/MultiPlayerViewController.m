//
//  MultiPlayerViewController.m
//  Axelrod's Tournament
//
//  Created by Elliot Adderton on 24/04/2014.
//  Copyright (c) 2014 Elliot Adderton. All rights reserved.
//

#import "MultiPlayerViewController.h"

#import "MPCHandler.h"
#import "MStrategy.h"
#import "MRule.h"
#import "Game.h"
#import "GameRoundTableViewCell.h"
#import "IndividualGameReviewViewController.h"
#import "MStrategy+Category.h"
#import "ResultPopUpViewController.h"

@interface MultiPlayerViewController ()
    @property(strong, nonatomic)MPCHandler *mpcHandler; // Multi Peer Connection handler
    @property(strong, nonatomic)NSMutableDictionary* tableviewData;
    @property(strong, nonatomic)NSMutableArray* gameViewData;
    @property(strong, nonatomic)NSMutableArray* others;
@end

@implementation MultiPlayerViewController
// lazy inits
-(NSMutableDictionary*)tableviewData
{
    if(_tableviewData==nil)
        _tableviewData = [NSMutableDictionary new];
    return _tableviewData;
}
-(NSMutableArray*)gameViewData
{
    if(_gameViewData==nil)
        _gameViewData = [NSMutableArray new];
    return _gameViewData;
}
-(NSMutableArray*)others
{
    if(_others==nil){
        _others = [NSMutableArray new];
        [_others addObject:@{@"strategy_name" : [NSString stringWithFormat:@"You - %@",self.myStrategy.name],@"boiled_rule":[self.myStrategy ruleBoiler]}];
    }
    return _others;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Start the game server aka multi peer connectivity
    [self startmpcHandler];
    // place a stop button on the top right in the tool bar
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Stop" style:UIBarButtonItemStylePlain target:self action:@selector(stopStartTheGame:)];
    // register the game nib as in the local tournament
    [self.gamePlayTableView registerNib:[GameRoundTableViewCell nib] forCellReuseIdentifier:GameRoundCellIdentifier];
    
}

- (IBAction)stopStartTheGame:(id)sender
{
    // if the stop button is pressed then we need to kill the tournament and present the results view
    NSLog(@"StopStart The Game NOW");

    [self killmpcHandler];
    [self.navigationItem setRightBarButtonItem:nil animated:YES];
    [self performSegueWithIdentifier:@"resultsSegue" sender:self];
}
// if we press the back button we should stop the game and remove the notification listener
- (void)viewWillDisappear:(BOOL)animated
{
    [self killmpcHandler];
    self.tableviewData = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:kRecievedStrategyNotification];
    
}
// helper method for starting mpc
-(void)startmpcHandler
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(remoteDataRecieved:)
                                                 name:kRecievedStrategyNotification
                                               object:nil];
    // stop retain cycles and start the server
    __weak MultiPlayerViewController *weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        MPCHandler* handler = [[MPCHandler alloc]initWithStrategy:self.myStrategy];
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [weakSelf setMpcHandler:handler];
        });
    });
}
// helper method to stop the mpc handler
-(void)killmpcHandler
{
    __weak MultiPlayerViewController *weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        [weakSelf.mpcHandler stop];
        [weakSelf setMpcHandler:nil];
    });
    [[NSNotificationCenter defaultCenter] removeObserver:kRecievedStrategyNotification];
}
// one list of remote strategies and a list of playoffs
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(tableView == self.remotePlayersTableView)
        return 1;
    else
        return self.gameViewData.count;
}
//same as local tournament, the numeber strategies/remote players and the number games that have been played
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(tableView == self.remotePlayersTableView)
        return self.tableviewData.count;
    else
        return [[[self.gameViewData objectAtIndex:section] objectForKey:@"rounds"] count];
}
// set the title for the header in a given section, "Remote strategies" or the strategy vs strategy
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(tableView == self.remotePlayersTableView){
        return @"Remote Strategies";
    }else{
        return [NSString stringWithFormat:@"Game %d: %@ vs %@",(int)section+1,[[self.gameViewData objectAtIndex:section] objectForKey:@"strategy_1"],[[self.gameViewData objectAtIndex:section] objectForKey:@"strategy_2"]];
    }
}
// respond to clicking on a table view cell
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // we add the strategy (remote)
    if(tableView == self.remotePlayersTableView){
        NSLog(@"I Want that Strategy");
        
        NSArray *keys = [self.tableviewData allKeys];
        NSString *name = [keys objectAtIndex:indexPath.row];
        name = [name stringByAppendingString:@" - "];
        name = [name stringByAppendingString:[[self.tableviewData objectForKey:[keys objectAtIndex:indexPath.row]] objectForKey:@"strategy_name"]];
        
        // needs to be on the same thread for autosave.
        // find out if we need to replace or insert into the database, we dont want to strategies with the same name
        __block BOOL replace;
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            MStrategy *newStrategy = [MStrategy strategyForName:name];
            replace = YES;
            if(!newStrategy){
                newStrategy = [NSEntityDescription insertNewObjectForEntityForName:@"MStrategy"
                                                            inManagedObjectContext:appD.document.managedObjectContext];
                replace = NO;
            }
            newStrategy.name = name;
        
            for(NSDictionary* rule in [[self.tableviewData objectForKey:[keys objectAtIndex:indexPath.row]] objectForKey:@"ruleset"]){
                MRule *mrule = [NSEntityDescription insertNewObjectForEntityForName:@"MRule"
                                                             inManagedObjectContext:appD.document.managedObjectContext];
                mrule.strategy = newStrategy;
                mrule.response = [rule objectForKey:@"response"];
                mrule.position = [rule objectForKey:@"position"];
            }
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Added Strategy"
                                                                message:replace?@"This strategy has been updated.":@"This strategy has been added."
                                                               delegate:self cancelButtonTitle:@"Close"
                                                      otherButtonTitles:nil];
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    [alert show];
                    [self.gamePlayTableView deselectRowAtIndexPath:indexPath animated:YES];
                });
            });
        });

    }else{
        // present the results of a game i.e. the game inspector
        [self performSegueWithIdentifier:@"inspectRound" sender:self];
    }
}


-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == self.remotePlayersTableView){
        // set the cell to the remote players strategy name and the device broadcast as the subtitle
        UITableViewCell *cell;
        static NSString *kCellIdentifier = @"detailedCell";
        cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
        
        if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kCellIdentifier];
        
        NSArray *keys = [self.tableviewData allKeys];
        NSString *name = [keys objectAtIndex:indexPath.row];
        NSString *strategy = [[self.tableviewData objectForKey:name] objectForKey:@"strategy_name"];
        [cell.textLabel setText:strategy];
        [cell.detailTextLabel setText:name];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeContactAdd];
        [button setUserInteractionEnabled:NO];
        cell.accessoryView = button;
        return cell;
    }else{
        // set the values for the game cell. this is the same as in the local tournement.
        // This shouldnt need commenting as the variables are named well.
        GameRoundTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:GameRoundCellIdentifier forIndexPath:indexPath];
        if(cell == nil){
            cell = [[GameRoundTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:GameRoundCellIdentifier];
        }
        
        cell.strategyOneLabel.text = [self.gameViewData[indexPath.section] objectForKey:@"strategy_1"];
        cell.strategyTwoLabel.text = [self.gameViewData[indexPath.section] objectForKey:@"strategy_2"];
        
        NSArray* payoffArray = [[[self.gameViewData[indexPath.section] objectForKey:@"rounds"] objectAtIndex:indexPath.row] objectForKey:@"payoffs"];
        
        cell.rewardsLabel.text = [NSString stringWithFormat:@"%@ times",[[payoffArray objectAtIndex:0]objectAtIndex:0]];
        cell.punshmentsLabel.text = [NSString stringWithFormat:@"%@ times",[[payoffArray objectAtIndex:0]objectAtIndex:3]];
        cell.strategyOneSuckerTemptedLabel.text = [NSString stringWithFormat:@"%@/%@",
                                                   [[payoffArray objectAtIndex:0]objectAtIndex:1],
                                                   [[payoffArray objectAtIndex:0]objectAtIndex:2]];
        
        cell.strategyTwoSuckerTemptedLabel.text = [NSString stringWithFormat:@"%@/%@",
                                                   [[payoffArray objectAtIndex:1]objectAtIndex:1],
                                                   [[payoffArray objectAtIndex:1]objectAtIndex:2]];
        
        
        int p1score = [[[self.gameViewData[indexPath.section] objectForKey:@"rounds"][indexPath.row] objectForKey:@"p1score"] intValue];
        int p2score = [[[self.gameViewData[indexPath.section] objectForKey:@"rounds"][indexPath.row] objectForKey:@"p2score"] intValue];
        [cell.trophyOneImage setHidden:(BOOL)(p1score<p2score)];
        [cell.trophyTwoImage setHidden:(BOOL)(p1score>p2score)];
        [cell.drawLabel setText:(p1score==p2score)?@"Draw":@"Winner"];
        return cell;
    }
    
}
// we define a winner or a draw in the footer
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if(tableView == self.remotePlayersTableView){ return nil; }
    UIView *footer = [[UIView alloc]initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30)];
    footer.backgroundColor = [UIColor blackColor];
    
    UILabel *lbl = [[UILabel alloc]initWithFrame:footer.frame];
    lbl.backgroundColor = [UIColor clearColor];
    
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
    
    return footer;
}

// manuualy need to set the size of a footer should one exist
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if(self.remotePlayersTableView == tableView) return 0;
    return 30.0;
}
// foots group and float by default which gets confusing
- (BOOL) allowsFooterViewsToFloat {
    return NO;
}
// we must manually define the size of our cells
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(tableView == self.remotePlayersTableView) return 44;
    else return 117;
    
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // present the round inspector if a game cell is pressed
    if([segue.identifier isEqual:@"inspectRound"]){
        NSIndexPath *indexPath = [self.gamePlayTableView indexPathForSelectedRow];
        [self.gamePlayTableView deselectRowAtIndexPath:indexPath animated:NO];
        [(IndividualGameReviewViewController*)segue.destinationViewController
         setRoundData:[[self.gameViewData[indexPath.section] objectForKey:@"rounds"] objectAtIndex:indexPath.row]];
        [(IndividualGameReviewViewController*)segue.destinationViewController
         setStrategyNames:@[[self.gameViewData[indexPath.section] objectForKey:@"strategy_1"],[self.gameViewData[indexPath.section] objectForKey:@"strategy_2"]]];
    }else if([segue.identifier isEqual:@"resultsSegue"]){
        // show the ordered results
        NSMutableDictionary *winners = [NSMutableDictionary new];
        
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
        // sort the winners anad losers
        NSArray *orderedWinners;
        
        orderedWinners = [winners keysSortedByValueUsingComparator: ^(id obj1, id obj2) {
            
            if ([obj1 unsignedLongValue] < [obj2 unsignedLongValue]) return (NSComparisonResult)NSOrderedDescending;
            if ([obj1 unsignedLongValue] > [obj2 unsignedLongValue]) return (NSComparisonResult)NSOrderedAscending;
            return (NSComparisonResult)NSOrderedSame;
        }];
        
        [(ResultPopUpViewController*)segue.destinationViewController setWinners:orderedWinners];
    }
    
}

-(void)remoteDataRecieved:(NSNotification *)notification
{
    //NSLog(@"Recieved data: %@",notification.userInfo);
    
    // this method is called when a remote strategy is recieved
    // the remote strategy is added to the left side table
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        NSString *deviceName = [notification.userInfo objectForKey:@"device_name"];
        BOOL replace = [self.tableviewData objectForKey:deviceName] != nil;
        [self.tableviewData setObject:notification.userInfo forKey:deviceName];
        if(replace){
            NSArray *keys = [self.tableviewData allKeys];
            for(int i=0; i<keys.count; i++){
                if([keys[i] isEqualToString:deviceName]){
                    [self.remotePlayersTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
                    break;
                }
            }
        }else{
            [self.remotePlayersTableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.tableviewData.count-1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    });
    // a call is made to ensure that the new strategy plays every other already revcieved strategy, then the results are added to the tableview.
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        NSDictionary *remotePlayer = @{@"strategy_name" : [NSString stringWithFormat:@"%@ - %@",[notification.userInfo objectForKey:@"device_name"],[notification.userInfo objectForKey:@"strategy_name"]],@"boiled_rule":[notification.userInfo objectForKey:@"boiled_rule"]};
        NSArray *games = [Game play:remotePlayer againstArray:[self.others copy]];
        [self.others addObject:remotePlayer];
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            for(NSDictionary* game in games){
                [self.gameViewData addObject:game];
                [self.gamePlayTableView insertSections:[NSIndexSet indexSetWithIndex:self.gameViewData.count-1] withRowAnimation: UITableViewRowAnimationFade];
            }
        });
    });
}

@end
