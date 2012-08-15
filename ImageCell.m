//
//  ImageCell.m
//  Candid
//
//  Created by Amadou Crookes on 8/14/12.
//  Copyright (c) 2012 Amadou Crookes. All rights reserved.
//

#import "ImageCell.h"

@implementation ImageCell
@synthesize imageView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (ImageCell*)imageCellWithImage:(UIImage*)image reuseIdentifier:(NSString*)reuseIdentifier
{
    ImageCell* cell = [[ImageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    self.imageView.image = image;
    return cell;
}

@end
