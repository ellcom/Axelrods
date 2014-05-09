//
//  WelcomeViewController.h
//  Axelrod's Tournament
//
//  Created by Elliot Adderton on 10/04/2014.
//  Copyright (c) 2014 Elliot Adderton. All rights reserved.
//


// This is the first view controller to be created and presented to the user

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>


@interface WelcomeViewController : UIViewController
// Table view listing the strategies
@property (weak, nonatomic) IBOutlet UITableView *tableview;
// response to the create strategy button
- (IBAction)createStrategy:(id)sender;

// collection of the four buttons on screen
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *buttons;
// The buttons for the four options on screen
@property (weak, nonatomic) IBOutlet UIButton *createStrategyButton;
@property (weak, nonatomic) IBOutlet UIButton *editStrategyButton;
@property (weak, nonatomic) IBOutlet UIButton *localTournamentButton;
@property (weak, nonatomic) IBOutlet UIButton *multiplayerTournamentButton;
@end
