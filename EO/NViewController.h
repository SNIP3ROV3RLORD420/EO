//
//  NViewController.h
//  EO
//
//  Created by Dylan Humphrey on 5/24/14.
//  Copyright (c) 2014 Dylan Humphrey. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NViewController : UITableViewController

@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *date;
@property (nonatomic, strong) UIImage *profPic;
@property (nonatomic) BOOL male;

@end
