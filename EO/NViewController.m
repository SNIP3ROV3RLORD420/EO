//
//  NViewController.m
//  EO
//
//  Created by Dylan Humphrey on 5/24/14.
//  Copyright (c) 2014 Dylan Humphrey. All rights reserved.
//

#import "NViewController.h"
#import <FlatUIKit.h>
#import <Parse/Parse.h>
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface NViewController () <UITextFieldDelegate>{
 
    UITextField *firstName;
    UITextField *lastName;
    
    UIButton *b;
    
    BOOL green;
}

@end

@implementation NViewController

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
    self.title = @"Sign Up";
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancel)];
    [cancel configureFlatButtonWithColor:UIColorFromRGB(0x47c9af) highlightedColor:[UIColor greenSeaColor] cornerRadius:3.0f];
    self.navigationItem.leftBarButtonItem = cancel;
    
    //setting up the table view
    self.tableView.contentInset = UIEdgeInsetsMake(-36, 0 , 0, 0);
    self.tableView.scrollEnabled = NO;
    self.tableView.allowsSelection = NO;
    self.tableView.separatorInset = UIEdgeInsetsZero;
    self.tableView.separatorColor = [UIColor turquoiseColor];
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
    return 74;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc]init];
    }
    
    switch (indexPath.row) {
        case 0:
            firstName = [[UITextField alloc]initWithFrame:CGRectMake(5, 0, 320, 74)];
            firstName.placeholder = @"First Name";
            firstName.delegate = self;
            firstName.font = [UIFont flatFontOfSize:20];
            [firstName addTarget:self action:@selector(textViewUpdated:) forControlEvents:UIControlEventEditingChanged];
            firstName.clearButtonMode = UITextFieldViewModeWhileEditing;
            
            firstName.returnKeyType = UIReturnKeyNext;
            
            [cell.contentView addSubview:firstName];
            break;
        case 1:
            lastName = [[UITextField alloc]initWithFrame:CGRectMake(5, 0, 320, 74)];
            lastName.placeholder = @"Last Name";
            lastName.delegate = self;
            lastName.font = [UIFont flatFontOfSize:20];
            [lastName addTarget:self action:@selector(textViewUpdated:) forControlEvents:UIControlEventEditingChanged];
            lastName.clearButtonMode = UITextFieldViewModeWhileEditing;
            
            lastName.returnKeyType = UIReturnKeyDone;
            
            [cell.contentView addSubview:lastName];
            break;
        case 2:
            break;
        case 3:
            b = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 320, 74)];
            [b setTitleColor:[UIColor cloudsColor] forState:UIControlStateNormal];
            if ([self allFilled]) {
                [b addTarget:self action:@selector(finish) forControlEvents:UIControlEventTouchUpInside];
                b.backgroundColor = [UIColor turquoiseColor];
                [b setTitle:@"Create Account" forState:UIControlStateNormal];
                b.enabled = YES;
                [b setBackgroundImage:[NViewController imageWithColor:[UIColor greenSeaColor]] forState:UIControlStateHighlighted];
            }
            else{
                b.enabled = NO;
                [b setTitle:@"Empty Text Fields" forState:UIControlStateNormal];
                [b setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                b.backgroundColor = [UIColor redColor];
            }
            
            [cell.contentView addSubview:b];
            break;
        default:
            break;
    }
    
    return cell;
}

#pragma mark - Text Field Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField == firstName) {
        [lastName becomeFirstResponder];
    }
    if (textField == lastName) {
        [self finish];
    }
    return YES;
}


#pragma mark - Button Methods

- (void)cancel{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)finish{
    UIActivityIndicatorView *av = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(240, 272, 50, 50)];
    [self.view addSubview:av];
    [av startAnimating];
    
    [b setTitle:@"Creating..." forState:UIControlStateNormal];
    
    //creating the image to be uploaded
    NSData *imageData = UIImagePNGRepresentation(self.profPic);
    PFFile *imageFile = [PFFile fileWithName:[NSString stringWithFormat:@"%@ProfilePicture.png",self.username] data:imageData];
    
    PFUser *newUser = [PFUser user];
    newUser.username = self.username;
    newUser.password = self.password;
    newUser.email = self.email;
    newUser[@"birthday"] = self.date;
    newUser[@"male"] = @(self.male);
    newUser[@"profPic"] = imageFile;
    newUser[@"name"] = [NSString stringWithFormat:@"%@ %@", firstName.text, lastName.text];
    
    [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
        if (!error) {
            [b setTitle:@"Created" forState:UIControlStateNormal];
            [av stopAnimating];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
        else{
            NSLog(@"An Error Occurred");
        }
    }];
}

#pragma mark - class methods

- (void)textViewUpdated:(id)sender{
    if ([self allFilled] && !green) {
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:3 inSection:0]] withRowAnimation: UITableViewRowAnimationRight];
        green = YES;
    }
    if (![self allFilled] && green) {
        green = NO;
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:3 inSection:0]] withRowAnimation:UITableViewRowAnimationLeft];
    }
    
}

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

- (BOOL)allFilled{
    if (   ![firstName.text isEqualToString:@""]
        && ![lastName.text isEqualToString:@""])
    {
        return YES;
    }
    return NO;
}


@end