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
        map = [[MKMapView alloc]initWithFrame:CGRectMake(0, 0, 320, 504)];
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
        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(240, 5, 1, 34)];
        line.backgroundColor = [UIColor lightGrayColor];
        
        [searchNavBar addSubview:line];
        [searchNavBar addSubview:search];
        [searchNavBar addSubview:filter];
        
        [self.view addSubview:searchNavBar];
    
        //adding the menu button to the view
        eventMenu = [[UIButton alloc]initWithFrame:CGRectMake(20, 430, 45, 45)];
        eventMenu.layer.cornerRadius = 45/2;
        eventMenu.layer.borderWidth = .5f;
        eventMenu.layer.borderColor = [UIColor blackColor].CGColor;
        [eventMenu setImage:[UIImage imageNamed:@"menu.png"] forState:UIControlStateNormal];
        eventMenu.backgroundColor = [UIColor whiteColor];
        [eventMenu setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [eventMenu setBackgroundImage:[MapViewController imageWithColor:[UIColor lightGrayColor]] forState:UIControlStateHighlighted];
        [eventMenu addTarget:self action:@selector(menuPressed) forControlEvents:UIControlEventTouchUpInside];
        eventMenu.alpha = .9f;
        eventMenu.clipsToBounds = YES;
        [self.view addSubview:eventMenu];
        
        /*creating the table view*/
        eventTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 504, 320, 0) style:UITableViewStyleGrouped];
        eventTableView.dataSource = self;
        eventTableView.delegate = self;
        eventTableView.separatorInset = UIEdgeInsetsZero;
        eventTableView.backgroundColor = [UIColor whiteColor];
        eventTableView.showsVerticalScrollIndicator = NO;
        eventTableView.layer.shadowOffset = CGSizeMake(0, -2);
        eventTableView.layer.shadowRadius = 4.0f;
        eventTableView.layer.shadowOpacity = 0.80f;
        eventTableView.layer.shadowPath = [[UIBezierPath bezierPathWithRect:eventTableView.layer.bounds] CGPath];
        [self.view addSubview:eventTableView];
        [self.view bringSubviewToFront:eventTableView];
        [self.view bringSubviewToFront:searchNavBar];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Map";
    
    self.revealSideViewController.delegate = self;
    
    self.revealSideViewController.fakeiOS7StatusBarColor = [UIColor darkGrayColor];
    
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
    
    eventTableView.frame = CGRectMake(0, 300, 320, 504);
    map.frame = CGRectMake(0, 0, 320, 300);
    
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
    
    eventTableView.frame = CGRectMake(0, 504, 320, 504);
    map.frame = CGRectMake(0, 0, 320, 504);
    
    [UIView commitAnimations];
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
    return 10; //later return events.count
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0;
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
    NSLog(@"Delegate will push");
}

- (void)pprevealSideViewController:(PPRevealSideViewController *)controller didPopToController:(UIViewController *)centerController{
    map.userInteractionEnabled = YES;
    NSLog(@"Delegate will pop");
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

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    CGRect mFrame = map.frame;
    CGRect tFrame = eventTableView.frame;
    CGFloat diff = scrollView.contentOffset.y - self.lastContentOffset;
    
    if (scrollView.contentOffset.y > self.lastContentOffset && tFrame.origin.y >= 0){
        NSLog(@"dif: %f T Origin: %f", diff, tFrame.origin.y);
        mFrame.size.height -= diff;
        tFrame.origin.y -= diff;
        [map setFrame:mFrame];
        [eventTableView setFrame:tFrame];
    }
    else if (scrollView.contentOffset.y < self.lastContentOffset && tFrame.origin.y <= 300){
        NSLog(@"fired");
        mFrame.size.height -= diff;
        tFrame.origin.y -= diff;
        [map setFrame:mFrame];
        [eventTableView setFrame:tFrame];
    }
    else if (tFrame.origin.y > 300){
        [self menuHide];
    }
    self.lastContentOffset = scrollView.contentOffset.y;
}
@end
