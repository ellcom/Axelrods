//
//  ResultPopUpViewController.h
//  Axelrod's Tournament
//
//  Created by Elliot Adderton on 30/04/2014.
//  Copyright (c) 2014 Elliot Adderton. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ResultPopUpViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

- (IBAction)doneButtonPressed:(id)sender;

@property (weak, nonatomic) IBOutlet UINavigationBar *nav;
@property (weak, nonatomic) IBOutlet UITableView *tableview;

@property (strong, nonatomic) NSArray *winners;

@end
