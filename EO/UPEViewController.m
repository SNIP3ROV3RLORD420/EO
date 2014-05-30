//
//  UPEViewController.m
//  EO
//
//  Created by Dylan Humphrey on 5/23/14.
//  Copyright (c) 2014 Dylan Humphrey. All rights reserved.
//

#import "UPEViewController.h"
#import <FlatUIKit.h>
#import "BGNViewController.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#warning Need to add Username checking and password checking and email checking 

@interface UPEViewController () <UITextFieldDelegate> {
    UITextField *usernameText;
    UITextField *passwordText;
    UITextField *emailText;
    UIButton *b;
    
    BOOL green;
}

- (BOOL)allFilled;

@end

@implementation UPEViewController

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
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancel:)];
    [cancel configureFlatButtonWithColor:UIColorFromRGB(0x47c9af) highlightedColor:[UIColor greenSeaColor] cornerRadius:3.0f];
    self.navigationItem.leftBarButtonItem = cancel;

    //setting up the table view
    self.tableView.contentInset = UIEdgeInsetsMake(-36, 0 , 0, 0);
    self.tableView.scrollEnabled = NO;
    self.tableView.allowsSelection = NO;
    self.tableView.separatorInset = UIEdgeInsetsZero;
    self.tableView.separatorColor = [UIColor turquoiseColor];
    }

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [usernameText becomeFirstResponder];
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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 72;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc]init];
    }
    switch (indexPath.row) {
        case 0:
            usernameText = [[UITextField alloc]initWithFrame:CGRectMake(5, 0, 320, 72)];
            usernameText.placeholder = @"Username";
            usernameText.delegate = self;
            usernameText.font = [UIFont flatFontOfSize:20];
            [usernameText addTarget:self action:@selector(textViewUpdated:) forControlEvents:UIControlEventEditingChanged];
            usernameText.clearButtonMode = UITextFieldViewModeWhileEditing;

            usernameText.returnKeyType = UIReturnKeyNext;
            
            [cell.contentView addSubview:usernameText];
            break;
        case 1:
            passwordText = [[UITextField alloc]initWithFrame:CGRectMake(5, 0, 320, 72)];
            passwordText.placeholder = @"Password";
            passwordText.delegate = self;
            passwordText.secureTextEntry = YES;
            passwordText.font = [UIFont flatFontOfSize:20];
            [passwordText addTarget:self action:@selector(textViewUpdated:) forControlEvents:UIControlEventEditingChanged];
            passwordText.returnKeyType = UIReturnKeyNext;
            passwordText.clearButtonMode = UITextFieldViewModeWhileEditing;
            
            [cell.contentView addSubview:passwordText];
            break;
        case 2:
            emailText = [[UITextField alloc]initWithFrame:CGRectMake(5, 0, 320, 72)];
            emailText.placeholder = @"Email Address";
            emailText.delegate = self;
            emailText.font = [UIFont flatFontOfSize:20];
            [emailText addTarget:self action:@selector(textViewUpdated:) forControlEvents:UIControlEventEditingChanged];
            emailText.returnKeyType = UIReturnKeyDone;
            emailText.clearButtonMode = UITextFieldViewModeWhileEditing;
            
            [cell.contentView addSubview:emailText];
            break;
        case 3:
            b = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 320, 72)];
            [b setTitleColor:[UIColor cloudsColor] forState:UIControlStateNormal];
            if ([self allFilled]) {
                    [b addTarget:self action:@selector(next:) forControlEvents:UIControlEventTouchUpInside];
                    b.backgroundColor = [UIColor turquoiseColor];
                    [b setTitle:@"Continue" forState:UIControlStateNormal];
                    b.enabled = YES;
                    [b setBackgroundImage:[UPEViewController imageWithColor:[UIColor greenSeaColor]] forState:UIControlStateHighlighted];
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

#pragma mark = UITextfieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField == usernameText) {
        [passwordText becomeFirstResponder];
    }
    if (textField == passwordText) {
        [emailText becomeFirstResponder];
    }
    if (textField == emailText && b.enabled) {
        [self next:nil];
    }
    return YES;
}

#pragma mark - Button Methods

- (void)cancel:(id)sender{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)next:(id)sender{
    BGNViewController *bv = [[BGNViewController alloc]init];
    bv.username = usernameText.text;
    bv.password = passwordText.text;
    bv.email = emailText.text;
    [self.navigationController pushViewController:bv animated:YES];
}

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

#pragma mark - Class Methods

- (BOOL)allFilled{
    if (![usernameText.text isEqualToString:@""] &&
        ![passwordText.text isEqualToString:@""] &&
        ![emailText.text isEqualToString:@""])
    {
        return YES;
    }
    return NO;
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

@end
