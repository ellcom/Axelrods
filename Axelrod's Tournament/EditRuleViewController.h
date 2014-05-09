//
//  EditRuleViewController.h
//  Axelrod's Tournament
//
//  Created by Elliot Adderton on 07/04/2014.
//  Copyright (c) 2014 Elliot Adderton. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EditRuleView.h"

@interface EditRuleViewController : UIViewController

- (void) setRule:(NSDictionary*)ru;
- (NSDictionary*) returnRule;

@end
