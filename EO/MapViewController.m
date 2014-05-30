//
//  MapViewController.m
//  EO
//
//  Created by Dylan Humphrey on 5/25/14.
//  Copyright (c) 2014 Dylan Humphrey. All rights reserved.
//

#import "MapViewController.h"
#import <Parse/Parse.h>
#import <PPRevealSideViewController.h>
#import <FlatUIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import <MapKit/MapKit.h>
#import <UIViewController+MJPopupViewController.h>
#import "FilterViewController.h"
#import "EventTableViewCell.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface MapViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate, MKMapViewDelegate, FilterViewControllerDelegate, UIScrollViewDelegate>{
    
    UITableView *eventTableView;
    
    UIView *searchNavBar;
    UIView *bottom;
    UISearchBar *search;
    UIButton *filter;
    UIView *line;
    
    UIButton *eventMenu;
    
    MKMapView *map;
    
    NSMutableArray *events;
    
    UISearchDisplayController *searcher;
}

@property (nonatomic, assign) CGFloat lastContentOffset;

@end

@implementation MapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        /*creating the map view*/
        map = [[MKMapView alloc]initWithFrame:CGRectMake(0, 44, 320, 504-44)];
        map.showsUserLocation = YES;
        map.userTrackingMode = MKUserTrackingModeFollow;
        map.delegate = self;
        map.layer.shadowRadius = 3.0f;
        map.layer.shadowOpacity = .4f;
        map.layer.shadowOffset = CGSizeMake(0, 0);
        map.layer.masksToBounds = NO;
        [self.view addSubview:map];
        
        /*creating the search nav bar*/
        searchNavBar = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 44)];
        searchNavBar.backgroundColor = [UIColor whiteColor];
        searchNavBar.layer.shadowOffset = CGSizeMake(0, 3);
        searchNavBar.layer.shadowRadius = 3.0f;
        searchNavBar.layer.shadowOpacity = .5f;
        
        //creating the search bar to add to the search nav bar
        search = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, 240, 44)];
        search.backgroundColor = [UIColor clearColor];
        search.searchBarStyle = UISearchBarStyleMinimal;
        search.barTintColor = [UIColor clearColor];
        [search setSearchFieldBackgroundImage:[MapViewController imageSWithColor:[UIColor clearColor]] forState:UIControlStateNormal];
        search.delegate = self;
        search.text = @" Nearby Areas";
        
        //creaing teh filter button to add tot he search nav bar
        filter = [[UIButton alloc]initWithFrame:CGRectMake(240, 0, 80, 44)];
        [filter setTitle:@"Filter" forState:UIControlStateNormal];
        [filter setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [filter setBackgroundImage:[MapViewController imageWithColor:[UIColor lightGrayColor]] forState:UIControlStateHighlighted];
        [filter addTarget:self action:@selector(filter:) forControlEvents:UIControlEventTouchUpInside];
        
        //creating the little divider
        line = [[UIView alloc]initWithFrame:CGRectMake(240, 5, 1, 34)];
        line.backgroundColor = [UIColor lightGrayColor];
        
        [searchNavBar addSubview:line];
        [searchNavBar addSubview:search];
        [searchNavBar addSubview:filter];
        
        [self.view addSubview:searchNavBar];
        
        /*creating the table view*/
        eventTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 510, 320, 0) style:UITableViewStyleGrouped];
        eventTableView.dataSource = self;
        eventTableView.delegate = self;
        eventTableView.separatorInset = UIEdgeInsetsZero;
        eventTableView.backgroundColor = [UIColor whiteColor];
        eventTableView.showsVerticalScrollIndicator = NO;
        eventTableView.layer.masksToBounds = YES;
        [eventTableView setContentInset:UIEdgeInsetsMake(-40, 0, -40, 0)];
        [self.view addSubview:eventTableView];
        
        //adding the menu button to the view
        eventMenu = [[UIButton alloc]initWithFrame:CGRectMake(20, 440, 40, 40)];
        eventMenu.layer.cornerRadius = 10;
        eventMenu.layer.borderWidth = .5f;
        eventMenu.layer.borderColor = [UIColor darkGrayColor].CGColor;
        [eventMenu setImage:[UIImage imageNamed:@"menu.png"] forState:UIControlStateNormal];
        eventMenu.backgroundColor = [UIColor whiteColor];
        [eventMenu setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [eventMenu setBackgroundImage:[MapViewController imageWithColor:[UIColor lightGrayColor]] forState:UIControlStateHighlighted];
        [eventMenu addTarget:self action:@selector(menuPressed) forControlEvents:UIControlEventTouchUpInside];
        eventMenu.alpha = .9f;
        eventMenu.clipsToBounds = YES;
        [self.view addSubview:eventMenu];
        
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    events = [[NSMutableArray alloc]initWithObjects:@"",@"",@"",@"", nil];
    
    self.title = @"Map";
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.revealSideViewController setFakeiOS7StatusBarColor:[UIColor darkGrayColor]];
    
    UIBarButtonItem *menu = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"menu.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(menu:)];
    [menu configureFlatButtonWithColor:UIColorFromRGB(0x47c9af) highlightedColor:[UIColor greenSeaColor] cornerRadius:3.0f];
    self.navigationItem.leftBarButtonItem = menu;
    
    UIBarButtonItem *add = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(add)];
    [add configureFlatButtonWithColor:UIColorFromRGB(0x47c9af) highlightedColor:[UIColor greenSeaColor] cornerRadius:3.0f];
    self.navigationItem.rightBarButtonItem = add;
    
    [self.view addSubview:eventMenu];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self menuHide];
   // [self.revealSideViewController setDelegate:self];
    [self.revealSideViewController setPanInteractionsWhenClosed:PPRevealSideInteractionNavigationBar];
    [self.revealSideViewController setPanInteractionsWhenOpened:PPRevealSideInteractionContentView | PPRevealSideInteractionNavigationBar];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Button Methods

- (void)filter:(id)sender{
    FilterViewController *fv = [[FilterViewController alloc]init];
    fv.delegate = self;
    [self presentPopupViewController:fv animationType:MJPopupViewAnimationFade];
}

- (void)menuPressed{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:.5];
    [UIView setAnimationDelay:0.0];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    
    searchNavBar.frame = CGRectMake(0, 0, 320, 0);
    [filter setAlpha:0];
    [filter setFrame:CGRectMake(240, 0, 80, 0)];
    [search setAlpha:0];
    [line setAlpha:0];
    [line setFrame:CGRectMake(240, 5, 1, 0)];
    
    if (events.count >= 4 && events.count) {
        eventTableView.frame = CGRectMake(0, 504 - 280, 320, 280);
    }
    else if (events.count == 0){
        eventTableView.frame = CGRectMake(0, 504 - 70, 320, 70);
    }
    else{
        eventTableView.frame = CGRectMake(0, 504 - (70 * events.count), 320, (70 * events.count));
    }
    [eventMenu setAlpha:0.0f];

    map.frame = CGRectMake(0, 0 - eventTableView.frame.size.height, 320, 504);
    
    [UIView commitAnimations];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(menuHide)];
    [map addGestureRecognizer:tap];
}

- (void)menu:(id)sender{
    [self.revealSideViewController pushOldViewControllerOnDirection:PPRevealSideDirectionLeft animated:YES];
}

- (void)add{
    
}

- (void)menuHide{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:.5];
    [UIView setAnimationDelay:0.0];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    
    eventTableView.frame = CGRectMake(0, 520, 320, 0);
    [eventMenu setAlpha:0.9f];
    map.frame = CGRectMake(0, 0, 320, 504);
    searchNavBar.frame = CGRectMake(0, 0, 320, 44);
    [filter setAlpha:1];
    [filter setFrame:CGRectMake(240, 0, 80, 44)];
    [search setAlpha:1];
    [search setFrame:CGRectMake(0, 0, 240, 44)];
    [line setAlpha:1];
    [line setFrame:CGRectMake(240, 5, 1, 34)];
    
    [UIView commitAnimations];
    
    [self.view sendSubviewToBack:eventTableView];
}

#pragma mark - Class Methods

+ (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage*)imageSWithColor:(UIColor *)color{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 44.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

#pragma mark - UITableViewDatasource and Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return events.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (events.count == 0) {
        return 70;
    }
    return 0;
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (events.count == 0) {
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 70)];
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(80, 25, 160, 20)];
        label.text = @"No Events Nearby";
        label.font = [UIFont flatFontOfSize:20];
        label.textColor = [UIColor lightGrayColor];
        [view addSubview:label];
        return view;
    }
    return nil;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    EventTableViewCell *cell = (EventTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[EventTableViewCell alloc]init];
    }
    cell.nameLabel.text = @"Event Name";
    cell.dateLabel.text = @"MM/DD/YY";
    cell.hostLabel.text = @"Hosted By: Name";
    [cell setImage:[UIImage imageNamed:@"sampleProf.png"]];
    
    return cell;
}

#pragma mark - PPReavealSideViewControllerDelegate

- (void)pprevealSideViewController:(PPRevealSideViewController *)controller didPushController:(UIViewController *)pushedController{
    map.userInteractionEnabled = NO;
    searchNavBar.userInteractionEnabled = NO;
    eventMenu.userInteractionEnabled = NO;
}

- (void)pprevealSideViewController:(PPRevealSideViewController *)controller didPopToController:(UIViewController *)centerController{
    if (centerController == self) {
        map.userInteractionEnabled = YES;
        searchNavBar.userInteractionEnabled = YES;
        eventMenu.userInteractionEnabled = YES;
    }
}

#pragma mark - FilterViewControllerDelegate
- (void)FilterViewController:(FilterViewController *)fv didSelectFilter:(NSString *)f{
    [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
    //do other stuff with the filter
    search.text = [NSString stringWithFormat:@" %@",f];
}

#pragma mark - Search Bar Delegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    searcher = [[UISearchDisplayController alloc]initWithSearchBar:searchBar contentsController:self];
    searchBar.placeholder = @"Search for Events";
    searcher.delegate = self;
    searcher.searchResultsDataSource = self;
    searcher.searchResultsDelegate = self;
    [searcher setActive:YES animated:YES];
    [filter setHidden:YES];
}

#pragma mark - UISearchDisplayControllerDelegate

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller{
    [filter setHidden:NO];
}
@end
