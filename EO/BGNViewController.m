//
//  BGNViewController.m
//  EO
//
//  Created by Dylan Humphrey on 5/23/14.
//  Copyright (c) 2014 Dylan Humphrey. All rights reserved.
//

#import "BGNViewController.h"
#import <FlatUIKit.h>
#import "NViewController.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface BGNViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UINavigationControllerDelegate>
{
    UITableView *mainTableView;
    
    UIButton *finish;
    
    UITextField *birthdayText;
    UITextField *genderText;
    
    UIImageView *profPic;
    UIImage *theImage;
    
    UIButton *male;
    UIButton *female;
    
    UITapGestureRecognizer *gestureRecognizer;
    
    BOOL green;
    BOOL isMale;
}

@end

@implementation BGNViewController

@synthesize username, password, email;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //setting up the main table view
        mainTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, 320, 568) style:UITableViewStyleGrouped];
        mainTableView.dataSource = self;
        mainTableView.delegate = self;
        mainTableView.allowsSelection = NO;
        mainTableView.scrollEnabled = NO;
        mainTableView.contentInset = UIEdgeInsetsMake(-44, 0, 0, 0);
        mainTableView.separatorInset = UIEdgeInsetsZero;
        mainTableView.separatorColor = [UIColor turquoiseColor];
        
        [self.view addSubview:mainTableView];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    isMale = YES;
    
    theImage = [UIImage imageNamed:@"sampleProf.png"];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"Sign Up";
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancel:)];
    [cancel configureFlatButtonWithColor:UIColorFromRGB(0x47c9af) highlightedColor:[UIColor greenSeaColor] cornerRadius:3.0f];
    self.navigationItem.leftBarButtonItem = cancel;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [birthdayText becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View Data Source

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 74;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return -20;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc]init];
    }
    
    //creating the date picker
    UIDatePicker *dPicker = [[UIDatePicker alloc]init];
    dPicker.datePickerMode = UIDatePickerModeDate;
    [dPicker setBackgroundColor:[UIColor whiteColor]];
    [dPicker addTarget:self action:@selector(pickerDateChanged) forControlEvents:UIControlEventValueChanged];
    //creating the gender picker
    
    switch (indexPath.row) {
        case 1:
            birthdayText = [[UITextField alloc]initWithFrame:CGRectMake(5, 0, 320, 74)];
            birthdayText.placeholder = @"Birthday";
            birthdayText.delegate = self;
            birthdayText.inputView = dPicker;
            birthdayText.font = [UIFont flatFontOfSize:20];
            
            [cell.contentView addSubview:birthdayText];
            break;
        case 0:
            male = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 160, 74)];
            [male setTitle:@"Male" forState:UIControlStateNormal];
            [male addTarget:self action:@selector(genderChanged:) forControlEvents:UIControlEventTouchUpInside];
            if (isMale) {
                [male setBackgroundImage:[BGNViewController imageWithColor:[UIColor turquoiseColor]] forState:UIControlStateNormal];
                [male setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            }
            else{
                [male setBackgroundImage:[BGNViewController imageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
                [male setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            }
            
            female = [[UIButton alloc]initWithFrame:CGRectMake(160, 0, 160, 74)];
            [female setTitle:@"Female" forState:UIControlStateNormal];
            [female addTarget:self action:@selector(genderChanged:) forControlEvents:UIControlEventTouchUpInside];
            if (!isMale) {
                [female setBackgroundImage:[BGNViewController imageWithColor:[UIColor turquoiseColor]] forState:UIControlStateNormal
                 ];
                [female setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            }
            else{
                [female setBackgroundImage:[BGNViewController imageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
                [female setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            }
            
            [cell.contentView addSubview:male];
            [cell.contentView addSubview:female];
            break;
        case 2:
            cell.textLabel.text = @"Select a Profile Picture";
            cell.textLabel.font = [UIFont flatFontOfSize:20];
            
            gestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(editImage)];
            
            profPic = [[UIImageView alloc]initWithFrame:CGRectMake(320 - 74, 0, 74, 74)];
            profPic.userInteractionEnabled = YES;
            profPic.image = theImage;
            [profPic addGestureRecognizer:gestureRecognizer];
            
            [cell.contentView addSubview:profPic];
            break;
        case 3:
            finish = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 320, 74)];
            [finish setTitleColor:[UIColor cloudsColor] forState:UIControlStateNormal];
            if ([self allFilled]) {
                [finish addTarget:self action:@selector(next:) forControlEvents:UIControlEventTouchUpInside];
                finish.backgroundColor = [UIColor turquoiseColor];
                [finish setTitle:@"Continue" forState:UIControlStateNormal];
                finish.enabled = YES;
                [finish setBackgroundImage:[BGNViewController imageWithColor:[UIColor greenSeaColor]] forState:UIControlStateHighlighted];
            }
            
            else{
                finish.enabled = NO;
                [finish setTitle:@"Empty Text Fields" forState:UIControlStateNormal];
                [finish setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                finish.backgroundColor = [UIColor redColor];
            }
            
            [cell.contentView addSubview:finish];
            break;
        default:
            break;
    }
    
    return cell;
}

#pragma mark - Button Methods

- (void)cancel:(id)sender{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)next:(id)sender{
    NViewController *nv = [[NViewController alloc]initWithStyle:UITableViewStyleGrouped];
    nv.username = self.username;
    nv.password = self.password;
    nv.email = self.email;
    nv.date = birthdayText.text;
    nv.male = isMale;
    nv.profPic = profPic.image;
    [self.navigationController pushViewController:nv animated:YES];
}

- (void)editImage{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc]init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.delegate = self;
    [imagePicker.navigationBar configureFlatNavigationBarWithColor:[UIColor turquoiseColor]];
    imagePicker.allowsEditing = YES;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

#pragma mark - Saving the photo

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    
    //compressing the image
    UIGraphicsBeginImageContext(CGSizeMake(74, 74));
    [image drawInRect:CGRectMake(0, 0, 74, 74)];
    UIImage *compressedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    theImage = compressedImage;
    [mainTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:2 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Class Methods

- (BOOL)allFilled{
    if (   ![birthdayText.text isEqualToString:@""]
        && (!isMale || isMale))
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

- (void)pickerDateChanged{
    UIDatePicker *startPicker = (UIDatePicker*)birthdayText.inputView;
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateStyle:NSDateFormatterLongStyle];
    birthdayText.text = [formatter stringFromDate:startPicker.date];
    
    if ([self allFilled] && !green) {
        [mainTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:3 inSection:0]] withRowAnimation: UITableViewRowAnimationRight];
        green = YES;
    }
    if (![self allFilled] && green) {
        green = NO;
        [mainTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:3 inSection:0]] withRowAnimation:UITableViewRowAnimationLeft];
    }
}

- (void)genderChanged:(id)sender{
    if (sender == male) {
        isMale = YES;
        [mainTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    }
    if (sender == female) {
        isMale = NO;
        [mainTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    }
}

@end
