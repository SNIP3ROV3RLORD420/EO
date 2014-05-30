//
//  FilterViewController.m
//  EO
//
//  Created by Dylan Humphrey on 5/26/14.
//  Copyright (c) 2014 Dylan Humphrey. All rights reserved.
//

#import "FilterViewController.h"

@interface FilterViewController ()

@end

@implementation FilterViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.tableView.frame = CGRectMake(50, 130, 220, 240);
        self.tableView.layer.cornerRadius = 5.0f;
        self.tableView.scrollEnabled = NO;
        self.tableView.separatorInset = UIEdgeInsetsZero;
        self.tableView.layer.masksToBounds = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc]init];
    }
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"Nearby Areas";
            break;
        case 1:
            cell.textLabel.text = @"My Events";
            break;
        case 2:
            cell.textLabel.text = @"Events Invited To";
            break;
        case 3:
            cell.textLabel.text = @"Public Events";
            break;
        default:
            break;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.delegate FilterViewController:self didSelectFilter:[[[tableView cellForRowAtIndexPath:indexPath] textLabel] text]];
}

@end
