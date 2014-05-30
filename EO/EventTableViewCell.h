//
//  EventTableViewCell.h
//  EO
//
//  Created by Dylan Humphrey on 5/26/14.
//  Copyright (c) 2014 Dylan Humphrey. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EventTableViewCell : UITableViewCell

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UILabel *hostLabel;
@property (nonatomic, strong) UIImageView *eventImageView;

- (void)setImage:(UIImage*)newImage;

@end
