//
//  DefineLocalTournamentViewController.h
//  Axelrod's Tournament
//
//  Created by Elliot Adderton on 16/04/2014.
//  Copyright (c) 2014 Elliot Adderton. All rights reserved.
//

#import <UIKit/UIKit.h>


#import "MRule+Category.h"
#import "MStrategy+Category.h"



#import "IndividualGameReviewViewController.h"

@interface DefineLocalTournamentViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (weak, nonatomic) IBOutlet UITableView *gameTableView;

- (IBAction)startTaurnamentButtonPress:(id)sender;

@end
