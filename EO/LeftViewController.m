//
//  LeftViewController.m
//  EO
//
//  Created by Dylan Humphrey on 5/26/14.
//  Copyright (c) 2014 Dylan Humphrey. All rights reserved.
//

#import "LeftViewController.h"
#import <Parse/Parse.h>
#import <FacebookSDK/FacebookSDK.h>
#import <FlatUIKit.h>
#import "FriendsViewController.h"
#import "MapViewController.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:.65]

@interface LeftViewController (){
    NSMutableArray *allEvents;
    NSMutableArray *hosting;
    NSMutableArray *invited;
    
    BOOL facebookLinked;
}

@end

@implementation LeftViewController

- (id)init {
    self = [super init];
    if (self) {
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
        if ([PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
            facebookLinked = YES;
        }
        //tableview
        self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(5, 50, 240, 518) style:UITableViewStyleGrouped];
        self.tableView.backgroundColor = [UIColor clearColor];
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.contentInset = UIEdgeInsetsMake(-40, 0, 0, 0);
        
        //header view
        UIView *header = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 275, 50)];
        header.backgroundColor = [UIColor clearColor];
        
        UIView *touchView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 189, 50)];
        touchView.backgroundColor = [UIColor clearColor];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(goAccount)];
        [touchView addGestureRecognizer:tap];
        
        [header addSubview:touchView];
        
        UIImageView *imageView;
        FBProfilePictureView *profView;
        imageView.layer.cornerRadius = 3.0f;
        imageView.clipsToBounds = YES;
        if (!facebookLinked) {
            imageView = [[UIImageView alloc]initWithFrame:CGRectMake(5, 5, 40, 40)];
            PFFile *userImage = [PFUser currentUser][@"profPic"];
            [userImage getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error){
                if (!error) {
                    imageView.image = [UIImage imageWithData:imageData];
                }
            }];
        }
        else{
            profView = [[FBProfilePictureView alloc]initWithFrame:CGRectMake(5, 5, 40, 40)];
            profView.layer.cornerRadius = 3.0f;
            profView.clipsToBounds = YES;
        }
        
        UILabel *name = [[UILabel alloc]initWithFrame:CGRectMake(55, 12, 135, 13)];
        if (!facebookLinked) {
            name.text = [PFUser currentUser][@"name"];
        }
        name.font = [UIFont flatFontOfSize:13];
        name.textColor = [UIColor whiteColor];
        name.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        UILabel *email = [[UILabel alloc]initWithFrame:CGRectMake(55, 26, 135, 13)];
        if (!facebookLinked) {
            email.text = [[PFUser currentUser] email];
        }
        email.font = [UIFont flatFontOfSize:12];
        email.textColor = [UIColor lightGrayColor];
        email.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        UIView *divider = [[UIView alloc]initWithFrame:CGRectMake(190, 10, .5, 30)];
        divider.backgroundColor = [UIColor whiteColor];
        
        UIButton *settings = [[UIButton alloc]initWithFrame:CGRectMake(200, 5, 32, 32)];
        [settings setImage:[UIImage imageNamed:@"set.png"] forState:UIControlStateNormal];
        settings.layer.masksToBounds = YES;
        [settings setTintColor:[UIColor whiteColor]];
        
        [header addSubview:name];
        [header addSubview:email];
        [header addSubview:divider];
        [header addSubview:settings];
        if (facebookLinked){
            [header addSubview:profView];
        }
        else{
            [header addSubview:imageView];
        }
        
        [self.view addSubview:header];
        [self.view addSubview:self.tableView];
        
        if (facebookLinked) {
            [FBRequestConnection startWithGraphPath:@"/me?scope=email"
                                         parameters:nil
                                         HTTPMethod:@"GET"
                                  completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                                      NSLog(@"user info: %@", result);
                                      name.text = result[@"name"];
                                      email.text = result[@"email"];
                                      profView.profileID = result[@"id"];
                                  }];
        }
    }
    return self;
}


- (void)viewDidLoad{
    [super viewDidLoad];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return 50;
    }
    return 60;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 4;
            break;
        case 1:
            return invited.count;
            break;
        case 2:
            return hosting.count;
            break;
        default:
            break;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 0;
    }
    return 20;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == 1 && invited.count == 0) {
        return 80;
    }
    if (section == 2 && hosting.count == 0) {
        return 80;
    }
    return 0;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *header = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 270, 20)];
    
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 19, 315, .5)];
    line.backgroundColor = [UIColor whiteColor];
    
    UILabel *title = [[UILabel alloc]initWithFrame:CGRectMake(10, 5, 300, 14)];
    title.font = [UIFont flatFontOfSize:13];
    title.textColor = [UIColor whiteColor];
    
    if (section == 1) {
        title.text = @"Invited To";
    }
    if (section == 2) {
        title.text = @"Hosting";
    }
    
    [header addSubview:line];
    [header addSubview:title];
    
    return header;
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (section == 1 && invited.count == 0) {
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 245, 80)];
        view.backgroundColor = [UIColor clearColor];
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(75, 30, 145, 30)];
        label.font = [UIFont flatFontOfSize:18];
        label.text = @"No Events";
        label.textColor = [UIColor whiteColor];
        [view addSubview:label];
        return view;
    }
    if (section == 2 && hosting.count == 0) {
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 245, 80)];
        view.backgroundColor = [UIColor clearColor];
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(75, 30, 145, 30)];
        label.font = [UIFont flatFontOfSize:18];
        label.text = @"No Events";
        label.textColor = [UIColor whiteColor];
        [view addSubview:label];
        return view;
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc]init];
    }
    cell.textLabel.textColor = [UIColor lightGrayColor];
    cell.textLabel.highlightedTextColor = [UIColor whiteColor];
    cell.textLabel.font = [UIFont flatFontOfSize:18];
    cell.backgroundColor = [UIColor clearColor];
    
    //creating the selected background view
    UIView *selectedView = [[UIView alloc]initWithFrame:cell.bounds];
    selectedView.backgroundColor = UIColorFromRGB(0x191919);
    selectedView.alpha = .5;
    cell.selectedBackgroundView = selectedView;
    
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = @"Map";
                break;
            case 1:
                cell.textLabel.text = @"Freinds";
                break;
            case 2:
                cell.textLabel.text = @"Something";
                break;
            case 3:
                cell.textLabel.text = @"Something";
                break;
            default:
                break;
        }
    }
    if ([cell.textLabel.text isEqualToString:[[self.revealSideViewController rootViewController] title]]) {
        [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        MapViewController *mv = [[MapViewController alloc]init];
        UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:mv];
        [nav.navigationBar configureFlatNavigationBarWithColor:[UIColor turquoiseColor]];
        [nav.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
        [self.revealSideViewController popViewControllerWithNewCenterController:nav animated:YES];
    }
    if (indexPath.row == 1) {
        FriendsViewController *fv = [[FriendsViewController alloc]initWithStyle:UITableViewStyleGrouped];
        [self.revealSideViewController popViewControllerWithNewCenterController:fv animated:YES];
    }
}

#pragma mark - Button Methods

- (void)goAccount{
    NSLog(@"This is working");
}

@end
