//
//  IndividualGameReviewViewController.h
//  Axelrod's Tournament
//
//  Created by Elliot Adderton on 20/04/2014.
//  Copyright (c) 2014 Elliot Adderton. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IndividualGameReviewViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (weak, nonatomic) IBOutlet UINavigationBar *nav;

@property(strong, nonatomic)NSArray* strategyNames;
@property(strong, nonatomic)NSDictionary* roundData;

- (IBAction)doneButtonPress:(id)sender;

@end
