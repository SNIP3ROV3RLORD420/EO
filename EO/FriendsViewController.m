//
//  FriendsViewController.m
//  EO
//
//  Created by Dylan Humphrey on 5/29/14.
//  Copyright (c) 2014 Dylan Humphrey. All rights reserved.
//

#import "FriendsViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import <Parse/Parse.h>

@interface FriendsViewController (){
    NSMutableArray *friends;
    NSMutableArray *alphabetArray;
}

@end

@implementation FriendsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.revealSideViewController setPanInteractionsWhenClosed:PPRevealSideInteractionContentView | PPRevealSideInteractionNavigationBar];
    [self.revealSideViewController setPanInteractionsWhenOpened:PPRevealSideInteractionContentView | PPRevealSideInteractionNavigationBar];
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
    return alphabetArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSMutableArray* rowArray=[[NSMutableArray alloc]initWithCapacity:0];
    rowArray = [self getArrayOfRowsForSection:section];
    return rowArray.count;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    NSString *title;
    for (int i=0; i<alphabetArray.count; i++)
    {
        if (section==i)
        {
            title= [alphabetArray objectAtIndex:i];
        }
    }
    return title;
}

- (NSArray*)sectionIndexTitlesForTableView:(UITableView *)tableView{
    return alphabetArray;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index{
    NSIndexPath *indexpath;
    for (int i=0; i < alphabetArray.count; i++)
    {
        NSString *titleToSearch = [alphabetArray objectAtIndex:i];
        if ([title isEqualToString:titleToSearch])
        {
            indexpath=[NSIndexPath indexPathForRow:0 inSection:i];
            
            [self.tableView scrollToRowAtIndexPath:indexpath atScrollPosition:UITableViewScrollPositionTop animated:YES];
            break;
        }
    }
    return indexpath.section;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    NSMutableArray* rowArray=[[NSMutableArray alloc]initWithCapacity:0];
    rowArray=[self getArrayOfRowsForSection:indexPath.section];
    NSString *titleToBeDisplayed=[rowArray objectAtIndex:indexPath.row];
    cell.textLabel.text = titleToBeDisplayed;
    
    return cell;
}

#pragma mark - Class Methods

-(void)createAlphabetArray
{
    alphabetArray = [[NSMutableArray alloc]initWithCapacity:0];
    for (int i=0; i< friends.count; i++)
    {
        NSDictionary<FBGraphUser> *user = [friends objectAtIndex:i];
        NSString *firstletter = [user.name substringToIndex:1];
        if (![alphabetArray containsObject:firstletter])
        {
            [alphabetArray addObject:firstletter];
        }
    }
    [alphabetArray sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
}

-(NSMutableArray *)getArrayOfRowsForSection:(NSInteger)section
{
    NSString *rowTitle;
    NSString *sectionTitle;
    NSMutableArray *rowContainer=[[NSMutableArray alloc]initWithCapacity:0];
    
    for (int i=0; i<alphabetArray.count; i++)
    {
        if (section==i)
        {
            sectionTitle= [alphabetArray objectAtIndex:i];
            for (NSDictionary<FBGraphUser> *user in friends)
            {
                
                rowTitle = [user.name substringToIndex:1];
                if ([rowTitle isEqualToString:sectionTitle])
                {
                    [rowContainer addObject:user.name];
                }
            }
        }
    }
    return rowContainer;
}


@end