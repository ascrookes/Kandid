//
//  ImageCell.m
//  Candid
//
//  Created by Amadou Crookes on 7/4/12.
//  Copyright (c) 2012 Amadou Crookes. All rights reserved.
//

#import "ImageCell.h"

@implementation ImageCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithImageData:(NSData*)imageData reuseIdentifier:(NSString*)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        // resizing image for thumbnail on cell
        self.frame = CGRectMake(0, 0, 92, 92);
        [self addImageToCell:imageData];
    }
    
    return self;
}

- (void)selectCell
{
    NSLog(@"selecting cell---------------->");
    self.selected = YES;
}


- (void)addImageToCell:(NSData*)imageData
{
    UIImage* img = [UIImage imageWithData:imageData];
    CGSize size = CGSizeMake(92, 92);
    UIGraphicsBeginImageContext(size);
    [img drawInRect:CGRectMake(0,0,size.width,size.height)];
    UIImage* thumbnail = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImageView* imgView = [[UIImageView alloc] initWithImage:thumbnail];
    // rotates the img 90 degrees to fit into a horizontal table
    
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectCell)];
    [imgView addGestureRecognizer:tap];
    
    imgView.transform = CGAffineTransformMakeRotation(1.57079633);
    imgView.frame = self.frame;
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:thumbnail forState:UIControlStateNormal];
    
    [button addTarget:self action:@selector(selectCell) forControlEvents:UIControlEventTouchUpInside];
    //[self addSubview:imgView];
    [self addSubview:button];
}


- (void)addThumbnailToCell:(UIImage*)thumbnail
{
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:thumbnail forState:UIControlStateNormal];
    //[button addTarget:self action:@selector(argh) forControlEvents:UIControlEventTouchUpInside];
    // rotates the button 90 degrees to fit into a horizontal table
    button.transform = CGAffineTransformMakeRotation(1.57079633);
    button.frame = CGRectMake(0, 0, 92, 92);
    button.userInteractionEnabled = NO;
    [self addSubview:button];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)argh
{
    NSLog(@"%@",[self.superview class]);
}



@end
