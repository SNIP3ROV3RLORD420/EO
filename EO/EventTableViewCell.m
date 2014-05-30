//
//  EventTableViewCell.m
//  EO
//
//  Created by Dylan Humphrey on 5/26/14.
//  Copyright (c) 2014 Dylan Humphrey. All rights reserved.
//

#import <FlatUIKit.h>
#import "EventTableViewCell.h"

@implementation EventTableViewCell

@synthesize nameLabel, dateLabel, hostLabel, eventImageView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(75, 5, 250, 20)];
        nameLabel.font = [UIFont flatFontOfSize:16];
        dateLabel = [[UILabel alloc]initWithFrame:CGRectMake(75, 26, 250, 20)];
        dateLabel.font = [UIFont flatFontOfSize:13];
        dateLabel.textColor = [UIColor lightGrayColor];
        hostLabel = [[UILabel alloc]initWithFrame:CGRectMake(75, 47, 250, 20)];
        hostLabel.font = [UIFont flatFontOfSize:13];
        hostLabel.textColor = [UIColor lightGrayColor];
        eventImageView = [[UIImageView alloc]initWithFrame:CGRectMake(5, 5, 60, 60)];
        eventImageView.layer.cornerRadius = 2.5f;
        eventImageView.clipsToBounds = YES;
        [self.contentView addSubview:nameLabel];
        [self.contentView addSubview:dateLabel];
        [self.contentView addSubview:hostLabel];
        [self.contentView addSubview:eventImageView];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

}

- (void)setImage:(UIImage *)newImage{
    UIGraphicsBeginImageContext(CGSizeMake(60, 60));
    [newImage drawInRect:CGRectMake(0, 0, 60, 60)];
    UIImage *compressedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    eventImageView.image = compressedImage;
}

@end
