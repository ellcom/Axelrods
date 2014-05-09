//
//  ViewController.h
//  Axelrod's Tournament
//
//  Created by Elliot Adderton on 05/04/2014.
//  Copyright (c) 2014 Elliot Adderton. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CoreData/CoreData.h>
#import "MStrategy+Category.h"
#import "MStrategy.h"
#import "MRule.h"

#import "EditRuleViewController.h"
#import "Prisoner.h"

@interface EditStrategyViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

// create rule button
@property (weak, nonatomic) IBOutlet UIButton* createButton;
// strategy name label
@property (weak, nonatomic) IBOutlet UILabel *strategyNameLabel;
// table for the rules
@property (weak, nonatomic) IBOutlet UITableView* tableview;
// delete strategy button
@property (weak, nonatomic) IBOutlet UIButton *deleteStrategyButton;

// unwind back to home screen
- (IBAction)mySaveUnwindSegueCallback:(UIStoryboardSegue *)segue;
// delete the strategy button
- (IBAction)deleteStrategy:(id)sender;
// the current strategy we are working on
@property(nonatomic,strong)MStrategy* strategy;

@end
