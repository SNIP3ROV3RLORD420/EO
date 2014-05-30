//
//  LoginViewController.m
//  EO
//
//  Created by Dylan Humphrey on 5/21/14.
//  Copyright (c) 2014 Dylan Humphrey. All rights reserved.
//

#import "LoginViewController.h"
#import <Parse/Parse.h>
#import <FacebookSDK/FacebookSDK.h>
#import <SIAlertView.h>
#import "UPEViewController.h"
#import "MapViewController.h"
#import "LeftViewController.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]


@interface LoginViewController () <UITableViewDataSource, UITextFieldDelegate, FBLoginViewDelegate> {
    UITextField *loginTextField;
    UITextField *passwordTextField;
}

@property (nonatomic, strong) UILabel *logo;
@property (nonatomic, strong) UITableView *UP;
@property (nonatomic, strong) FUIButton *fbLogin;
@property (nonatomic, strong) FUIButton *loginButton;
@property (nonatomic, strong) FUIButton *createAccount;

@end

@implementation LoginViewController

@synthesize logo, UP, loginButton, createAccount, fbLogin, activityIndicator;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //creating the logo label
        logo = [[UILabel alloc]initWithFrame:CGRectMake(60, 50 - 44, 240, 50)];
        logo.text = @"App Name";
        logo.font = [UIFont boldFlatFontOfSize:44.0f];
        logo.textColor = [UIColor whiteColor];
        
        //creating the tview
        UP = [[UITableView alloc]initWithFrame:CGRectMake(30, 200 - 44, 260, 88)];
        UP.layer.cornerRadius = 4.0f;
        UP.layer.borderWidth = .5f;
        UP.layer.borderColor = [UIColor lightGrayColor].CGColor;
        UP.separatorInset = UIEdgeInsetsZero;
        UP.separatorColor = [UIColor lightGrayColor];
        UP.allowsSelection = NO;
        UP.dataSource = self;
        
        //creating the login button
        loginButton = [[FUIButton alloc]initWithFrame:CGRectMake(30, 200 + 88 + 10 - 44, 260, 40)];
        loginButton.buttonColor = UIColorFromRGB(0x47c9af);
        loginButton.shadowColor = [UIColor greenSeaColor];
        loginButton.shadowHeight = 3.0f;
        loginButton.cornerRadius = 6.0f;
        loginButton.titleLabel.font = [UIFont boldFlatFontOfSize:16];
        [loginButton setTitle:@"Log In" forState:UIControlStateNormal];
        [loginButton setTitleColor:[UIColor cloudsColor] forState:UIControlStateNormal];
        [loginButton setTitleColor:[UIColor cloudsColor] forState:UIControlStateHighlighted];
        [loginButton addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
        
        //facebook login button
        fbLogin = [[FUIButton alloc]initWithFrame:CGRectMake(60, 200 + 88 + 10 + 40 + 20 - 44, 200, 40)];
        fbLogin.buttonColor = UIColorFromRGB(0x3b5998);
        fbLogin.shadowColor = [UIColor midnightBlueColor];
        fbLogin.shadowHeight = 3.0f;
        fbLogin.cornerRadius = 6.0f;
        fbLogin.titleLabel.font = [UIFont boldFlatFontOfSize:14];
        [fbLogin setTitle:@"Log In with Facebook" forState:UIControlStateNormal];
        [fbLogin setTitleColor:[UIColor cloudsColor] forState:UIControlStateNormal];
        [fbLogin setTitleColor:[UIColor cloudsColor] forState:UIControlStateHighlighted];
        [fbLogin addTarget:self action:@selector(fLogin) forControlEvents:UIControlEventTouchUpInside];
        
        //creating the create account button
        createAccount = [[FUIButton alloc]initWithFrame:CGRectMake(90, 500 - 44, 320 - 180, 40)];
        createAccount.buttonColor = UIColorFromRGB(0x47c9af);
        createAccount.shadowColor = [UIColor greenSeaColor];
        createAccount.shadowHeight = 3.0f;
        createAccount.cornerRadius = 6.0f;
        createAccount.titleLabel.text = @"Sign Up";
        createAccount.titleLabel.font = [UIFont boldFlatFontOfSize:14];
        [createAccount setTitle:@"Sign Up" forState:UIControlStateNormal];
        [createAccount setTitleColor:[UIColor cloudsColor] forState:UIControlStateNormal];
        [createAccount setTitleColor:[UIColor cloudsColor] forState:UIControlStateHighlighted];
        [createAccount addTarget:self action:@selector(create) forControlEvents:UIControlEventTouchUpInside];
        
        //adding all the subviews to the main view
        [self.view addSubview:logo];
        [self.view addSubview:UP];
        [self.view addSubview:loginButton];
        [self.view addSubview:fbLogin];
        [self.view addSubview:createAccount];
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor turquoiseColor];
    activityIndicator = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(210, 200 + 88 + 11 - 44, 37, 37)];
    if ([PFUser currentUser] || [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
        NSLog(@"Already Logged In");
        [self performSelector:@selector(normalStart) withObject:nil afterDelay:1.0];
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}
#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 2;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc]init];
    }
    
    switch (indexPath.row) {
        case 0:
            loginTextField = [[UITextField alloc]initWithFrame:CGRectMake(15, 0, cell.bounds.size.width - 15, 44)];
            loginTextField.placeholder = @"Username";
            loginTextField.delegate = self;
            loginTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
            loginTextField.returnKeyType = UIReturnKeyNext;
            [cell.contentView addSubview:loginTextField];
            break;
        case 1:
            passwordTextField = [[UITextField alloc]initWithFrame:CGRectMake(15, 0, cell.bounds.size.width - 15, 44)];
            passwordTextField.placeholder = @"Password";
            passwordTextField.delegate = self;
            passwordTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
            passwordTextField.returnKeyType = UIReturnKeyGo;
            passwordTextField.secureTextEntry = YES;
            [cell.contentView addSubview:passwordTextField];
            break;
        default:
            break;
    }
    return cell;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField == loginTextField){
        [passwordTextField becomeFirstResponder];
    }
    if (textField == passwordTextField){
        [self.view endEditing:YES];
    }
    return YES;
}

#pragma mark - Login and Create account methods

- (void)login{
    [loginButton setTitle:@"Logging In" forState:UIControlStateNormal];
    [self.view addSubview:activityIndicator];
    [activityIndicator startAnimating];
    [PFUser logInWithUsernameInBackground:loginTextField.text password:passwordTextField.text block:^(PFUser *user, NSError *error){
        if (user) {
            [loginButton setTitle:@"Logged In" forState:UIControlStateNormal];
            NSLog(@"%@ logged in", user);
            [activityIndicator stopAnimating];
            [self normalStart];
        }
        //error has occurred
        if (!user) {
            SIAlertView *alert = [[SIAlertView alloc]initWithTitle:@"Oops!" andMessage:@"We couldn't find your account! Make sure your Username and Password are correct."];
            [alert addButtonWithTitle:@"Ok"
                                 type:SIAlertViewButtonTypeDefault
                              handler:^(SIAlertView *alert){
                              }];
            alert.transitionStyle = SIAlertViewTransitionStyleSlideFromBottom;
            [alert show];
            [loginButton setTitle:@"Log in" forState:UIControlStateNormal];
            [activityIndicator stopAnimating];
            [activityIndicator removeFromSuperview];
        }
    }];
}

- (void)create{
    UPEViewController *uv = [[UPEViewController alloc]initWithStyle:UITableViewStyleGrouped];
    [self.navigationController pushViewController:uv animated:YES];
}

#pragma mark - Facebook login

-(void)fLogin{
    [PFFacebookUtils logInWithPermissions:@[@"public_profile", @"email", @"user_friends", @"user_birthday"] block:^(PFUser *user, NSError *error) {
        
        if (!user) {
            if (!error) {
                NSLog(@"Uh oh. The user cancelled the Facebook login.");
            } else {
                NSLog(@"Uh oh. An error occurred: %@", error);
            }
        } else if (user.isNew) {
            NSLog(@"User with facebook signed up and logged in!");
            [self normalStart];
        } else {
            NSLog(@"User with facebook logged in!");
            [self normalStart];
        }
    }];
}

#pragma mark - Class Methods

- (void)normalStart{
    MapViewController *mv = [[MapViewController alloc]init];
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:mv];
    [nav.navigationBar configureFlatNavigationBarWithColor:[UIColor turquoiseColor]];
    [nav.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    LeftViewController *lv = [[LeftViewController alloc]init];
    [self.revealSideViewController preloadViewController:lv forSide:PPRevealSideDirectionLeft];
    [self.revealSideViewController popViewControllerWithNewCenterController:nav animated:YES];
}

@end
