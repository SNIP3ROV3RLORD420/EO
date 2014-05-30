//
//  BGNViewController.h
//  EO
//
//  Created by Dylan Humphrey on 5/23/14.
//  Copyright (c) 2014 Dylan Humphrey. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BGNViewController : UIViewController <UIImagePickerControllerDelegate>

@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *email;

@end
