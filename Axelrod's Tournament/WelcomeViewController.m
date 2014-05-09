//
//  WelcomeViewController.m
//  Axelrod's Tournament
//
//  Created by Elliot Adderton on 10/04/2014.
//  Copyright (c) 2014 Elliot Adderton. All rights reserved.
//

#import "WelcomeViewController.h"

#import "UIButton+Gradient.h"
#import "MStrategy.h"
#import "EditStrategyViewController.h"
#import "MultiPlayerViewController.h"

@interface WelcomeViewController ()
// nsarray of all the required table view data
@property(strong, nonatomic)NSArray* tableViewData;
// We need to keep hold of a strategy in the case of creation, i.e. create then set name, then pass to the edit view controller
@property(strong, nonatomic)MStrategy* strategy;

@end

@implementation WelcomeViewController
// laxy init the table view data
-(NSArray*) tableViewData
{
    if(_tableViewData == nil)
        _tableViewData = [NSArray new];
    
    return _tableViewData;
}
// if the view is about to be shown then we need to listen for changes in the database and when the document has been loaded in the event that this view is shown before its creation
- (void) viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(contextDidSave:)
                                                 name:NSManagedObjectContextDidSaveNotification
                                               object:appD.document.managedObjectContext];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(contextDidSave:)
                                                 name:kUIDOCUMENTREADYNOTIFICATION
                                               object:appD.document.managedObjectContext];
    // In the case the we repesent the view, we reload the data.
    if (self.isMovingToParentViewController == NO){
        [self contextDidSave:nil];
    }
    
    
    
}
- (void) viewDidLoad
{
    // apply a gradient to the buttons
    [self.buttons makeObjectsPerformSelector:@selector(applyGradient)];
}

- (void) viewWillDisappear:(BOOL)animated
{
    // if the view goes dark we should remove the listeners
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextDidSaveNotification object:appD.document.managedObjectContext];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kUIDOCUMENTREADYNOTIFICATION object:appD.document.managedObjectContext];
    
}

// This method will update and refresh the table view data from the database
- (void) contextDidSave:(NSNotification*)note
{
    // find all MStrategies in the database
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"MStrategy" inManagedObjectContext:appD.document.managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    [request setPredicate:nil];
    NSError *error;
    // Fetch all the data
    NSArray *array = [appD.document.managedObjectContext executeFetchRequest:request error:&error];
    if(error)
        NSLog(@"Database Error Occured in WelcomeViewController > contextDidSave");
    else{
        // sort the data alphabetically
        NSArray *sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES]];
        // save the data to the table view data store
        [self setTableViewData:[array sortedArrayUsingDescriptors:sortDescriptors]];
    }
    // refresh the table
    [self.tableview reloadData];
}


- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
     return 1; // Only one section
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.tableViewData count]; // number of strategies
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Strategies"; // title for the table view
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // set the value of each cell to be a value within the data store
    static NSString *CellIdentifier = @"basicCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
     [[cell textLabel] setText:((MStrategy*)[self.tableViewData objectAtIndex:indexPath.row]).name];
     return cell;
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    // ensure that a strategy is selected before moving on to another view
    BOOL rtn = [identifier isEqualToString:@"localSegue"] || self.strategy || [self.tableview indexPathForSelectedRow];
    
    if(!rtn){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Select a Strategy"
                                                        message:@"Select a strategy from the left for this option to work."
                                                       delegate:self cancelButtonTitle:@"Close"
                                              otherButtonTitles:nil];
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [alert show];
        });
    }
    
    return rtn;
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // get ready to pass the selected strategy to another view controller
    if([self.tableview indexPathForSelectedRow] && !self.strategy){
        self.strategy = [self.tableViewData objectAtIndex:[self.tableview indexPathForSelectedRow].row];
    }
    
    if([segue.identifier isEqualToString: @"strategySelectionSegue"]){
        [((EditStrategyViewController*)segue.destinationViewController) setStrategy:self.strategy];
        
    }else if([segue.identifier isEqualToString:@"multiplayerSegue"]){
        [((MultiPlayerViewController*)segue.destinationViewController) setMyStrategy:self.strategy];
        
    }
    self.strategy = nil;
}
- (IBAction)createStrategy:(id)sender {
    // Collect the users input for a new strategy name
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Strategy Name"
                                                    message:@"Define the strategy name"
                                                   delegate:self cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Create",nil];
    // set the alert to accept input
    [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        // must show the alert on the main context
        [alert show];
    });
    
    
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    // if the "Create" button is pressed then
    if (buttonIndex == 1) {
        NSString *strategyName = [alertView textFieldAtIndex:0].text;
        
        NSString *errorText = nil;
        // ensure the stategy name is not blank and isn't already taken
        if([strategyName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length < 1){
            errorText = @"Strategy name cannot be empty";
        }else if([MStrategy strategyWithNameExists:strategyName]){
            errorText = @"Strategy with this name already exists, pick another";
        }
        // if there is an error then present it
        if(errorText){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Strategy Name"
                                                            message:errorText
                                                           delegate:self cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles:@"Create",nil];
            [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
            [[alert textFieldAtIndex:0] setText:strategyName];
            [alert show];
        }else{
            // else create a new strategy
            self.strategy = [NSEntityDescription insertNewObjectForEntityForName:@"MStrategy"
                                                          inManagedObjectContext:appD.document.managedObjectContext];
            self.strategy.name = strategyName;
            
            MRule *rule0 = [NSEntityDescription insertNewObjectForEntityForName:@"MRule"
                                                                 inManagedObjectContext:appD.document.managedObjectContext];
            rule0.position = @0;
            rule0.response = @0;
            rule0.strategy = self.strategy;
                    
            MRule *rule1 = [NSEntityDescription insertNewObjectForEntityForName:@"MRule"
                                                                 inManagedObjectContext:appD.document.managedObjectContext];
            rule1.position = @1;
            rule1.response = @0;
            rule1.strategy = self.strategy;
                    
            MRule *rule2 = [NSEntityDescription insertNewObjectForEntityForName:@"MRule"
                                                                 inManagedObjectContext:appD.document.managedObjectContext];
            rule2.position = @2;
            rule2.response = @1;
            rule2.strategy = self.strategy;

            [self performSegueWithIdentifier:@"strategySelectionSegue" sender:self];
        }
    }else{
        self.strategy = nil;
    }
}

@end
