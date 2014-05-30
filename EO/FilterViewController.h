//
//  FilterViewController.h
//  EO
//
//  Created by Dylan Humphrey on 5/26/14.
//  Copyright (c) 2014 Dylan Humphrey. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FilterViewController;

@protocol FilterViewControllerDelegate <NSObject>

- (void)FilterViewController:(FilterViewController*)fv didSelectFilter:(NSString*)f;

@end

@interface FilterViewController : UITableViewController

@property (nonatomic, weak) id <FilterViewControllerDelegate> delegate;

@end
