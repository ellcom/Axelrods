//
//  ViewController.m
//  Axelrod's Tournament
//
//  Created by Elliot Adderton on 05/04/2014.
//  Copyright (c) 2014 Elliot Adderton. All rights reserved.
//

#import "EditStrategyViewController.h"
#import "UIButton+Gradient.h"

@interface EditStrategyViewController ()

@property(strong,nonatomic)NSArray *ruleSet;

@end

@implementation EditStrategyViewController

@synthesize tableview;


-(NSArray*) ruleSet
{
    if(_ruleSet == nil){
        NSArray *sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:@"position" ascending:YES]];
        _ruleSet = [[self.strategy.rules allObjects] sortedArrayUsingDescriptors:sortDescriptors];
    }
    return _ruleSet;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.createButton applyGradient];
    [self.deleteStrategyButton applyRedGradient];
    
    [self setStrategyNameLabelTextWithText:[self.strategy name]];
}

#pragma mark - Table View Methods
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.strategy rules] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Draw out the cell for each of the rules
    static NSString *CellIdentifier = @"MyCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    MRule *rule = [self.ruleSet objectAtIndex:indexPath.row];
    int rulePosition = [rule.position intValue];
    
    int ruleLength = 0;
    for(int i=1; i<7; i++){
        int po = pow(2,i);
        if(rulePosition > po-2 && rulePosition < (po*2-1)){
            ruleLength = i;
        }
    }
    NSMutableString * signature = [NSMutableString new];
    
    int start = (rulePosition - pow(2,ruleLength))+1;
    
    for(int i=0; i<ruleLength; i++){
        
        if((int)pow(2,(ruleLength-1)-i) & start){
            [signature appendString:@"D"];
        }else
            [signature appendString:@"C"];
    }
    
    [(UILabel*)[cell viewWithTag:101] setText:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
    [(UILabel*)[cell viewWithTag:102] setText:signature];
    
    char response[] = {'C','D','R'};
    int res = (int)[rule.response integerValue];
    [(UILabel*)[cell viewWithTag:103] setText:[NSString stringWithFormat:@"%c",response[res]]];
    
    return cell;
}

#pragma mark - Segue
- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    NSIndexPath *indexPath = [self.tableview indexPathForSelectedRow];
    if([identifier isEqual:@"editRuleSegue"]){
        // don't allow the default rules to be altered
        int row = (int)indexPath.row;
        if(row <3){
            int response[] = {1,2,0};
            int currentValue = ((MRule*)[self.ruleSet objectAtIndex:row]).response.intValue;
            [((MRule*)[self.ruleSet objectAtIndex:row]) setResponse:@(response[currentValue])];
            [tableview reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            return NO;
        }
        
    }
    return YES;
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // set up for editing a rule
    if([segue.identifier isEqual:@"editRuleSegue"]){
        NSIndexPath *indexPath = [self.tableview indexPathForSelectedRow];
        [tableview deselectRowAtIndexPath:indexPath animated:NO];
        
        NSDictionary *dict = @{@"rulePosition" :((MRule*)[self.ruleSet objectAtIndex:indexPath.row]).position,
                               @"response" : ((MRule*)[self.ruleSet objectAtIndex:indexPath.row]).response };
        
        [(EditRuleViewController*)segue.destinationViewController setRule:dict];
        [self.strategy.managedObjectContext deleteObject:[self.ruleSet objectAtIndex:indexPath.row]];
        
    }else if ([segue.identifier isEqual:@"createRuleSegue"]){
        
        [(EditRuleViewController*)segue.destinationViewController setRule:@{@"rulePosition" :@0, @"response" : @0, }];
    }


}

- (IBAction)mySaveUnwindSegueCallback:(UIStoryboardSegue *)segue {
    [self dismissViewControllerAnimated:YES completion:nil];
    // unwind back to this view controller, we take the rule that has just been created, deleted or amened and make the change in the database
    if([segue.identifier isEqual:@"unwindToRuleSet"]){
        NSDictionary* dict = [(EditRuleViewController*)segue.sourceViewController returnRule];
        
        MRule *rule = [self.strategy ruleExistsAtPosition:[[dict objectForKey:@"rulePosition"] intValue]];
        
        if(rule == nil){
            rule = [[MRule alloc] initWithEntity:[NSEntityDescription entityForName:@"MRule" inManagedObjectContext:self.strategy.managedObjectContext] insertIntoManagedObjectContext:self.strategy.managedObjectContext];
        }
        rule.position = [dict objectForKey:@"rulePosition"];
        rule.response = [dict objectForKey:@"response"];
        rule.strategy = self.strategy;
        
        self.ruleSet = nil;
        [tableview reloadData];
    }else if ([segue.identifier isEqual:@"unwindToRuleSetDelete"]){
        self.ruleSet = nil;
        [tableview reloadData];
    }
    
    
}

#pragma mark - Rule/Strategy Manipulation
-(void) addToRuleSet:(NSDictionary*) ru
{
    // merge a "Rule" into the database
    MRule *rule = [ru objectForKey:@"rulePosition"];
    if(rule == nil){
        rule = [NSEntityDescription insertNewObjectForEntityForName:@"MRule"
                                             inManagedObjectContext:appD.document.managedObjectContext];
        rule.position = [ru objectForKey:@"rulePosition"];
        rule.response = [ru objectForKey:@"response"];
        rule.strategy = self.strategy;
    }else{
        rule.position = [ru objectForKey:@"rulePosition"];
        rule.response = [ru objectForKey:@"response"];
    }
    
    self.ruleSet = nil;
}

-(void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event{
    UITouch *touch = [touches anyObject];
    // detect a touch on the strategy name label, of so allow for the user to change it
    if(touch.view.tag == 201){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Strategy Name"
                                                        message:@"Change the strategy name"
                                                       delegate:self cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Change",nil];
        [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
        [[alert textFieldAtIndex:0] setText:self.strategy.name];
        [alert show];
    }
}
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    // Change button pressed
    if (buttonIndex == 1) {
        NSString *changedStrategyName = [alertView textFieldAtIndex:0].text;
        
        if(![self.strategy.name isEqualToString:changedStrategyName]){
            if([changedStrategyName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length > 0){
                // ensure that the new name isn't blank or already used
                NSError *error = nil;
                [self.strategy changeNameTo:changedStrategyName withError:&error];
                if(error){
                    [[[UIAlertView alloc] initWithTitle:@"Strategy Name"
                                                message:@"Strategy with this name already Exisits"
                                               delegate:self
                                      cancelButtonTitle:@"Close"
                                      otherButtonTitles:nil] show];
                }else{
                    [self setStrategyNameLabelTextWithText:self.strategy.name];
                }
            }else{
                // an empty strategy
                [[[UIAlertView alloc] initWithTitle:@"Strategy Name"
                                            message:@"Strategy name cannot be empty"
                                           delegate:self
                                  cancelButtonTitle:@"Close"
                                  otherButtonTitles:nil] show];
            }
        }
    }
}
// The strategy name label has some formatting and is set in differing places, this removes redundancey
-(void) setStrategyNameLabelTextWithText:(NSString*)text
{
    NSMutableAttributedString *textLabel = [[NSMutableAttributedString alloc] initWithString:@"Strategy Name: "
                                                                                  attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:17]}];
    [textLabel appendAttributedString:[[NSMutableAttributedString alloc] initWithString:text
                                                                             attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17]}]];
    
    [self.strategyNameLabel setAttributedText:textLabel];
}
// delete the strategy from the database then pop back to the welcome view
- (IBAction)deleteStrategy:(id)sender {
    [appD.document.managedObjectContext deleteObject:self.strategy];
    [self.navigationController popViewControllerAnimated:YES];
}


@end
