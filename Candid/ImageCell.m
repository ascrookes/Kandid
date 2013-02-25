//
//  ImageCell.m
//  Candid
//
//  Created by Amadou Crookes on 8/14/12.
//  Copyright (c) 2012 Amadou Crookes. All rights reserved.
//

#import "ImageCell.h"

@interface ImageCell ()

@property (nonatomic) CGPoint lastLocation;
@property (nonatomic,strong) UITableView* table;
@property (nonatomic) BOOL shouldSave;

@end

@implementation ImageCell 
@synthesize imageView;
@synthesize lastLocation = _lastLocation;
@synthesize table = _table;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization coded    return self;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

+ (ImageCell*)createImageCellWithTable:(UITableView*)table
{
    
    ImageCell* cell = [[ImageCell alloc] initWithFrame:CGRectMake(0, 0, 300, 250)];
    cell.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(50, 25, 200, 200)];
    [cell addSubview:cell.imageView];
    cell.table = table;
    cell.shouldSave = NO;
    
    return cell;
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];
    int newX = 150 + (location.x - self.lastLocation.x);
    self.imageView.center = CGPointMake(newX, self.imageView.center.y);
}



- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.table.scrollEnabled = NO;
    UITouch* touch = [touches anyObject];
    self.lastLocation = [touch locationInView:self];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.table.scrollEnabled = YES;
    if(self.imageView.center.x > 340) {
        self.shouldSave = YES;
        self.userInteractionEnabled = NO;
        [UIView animateWithDuration:0.20 animations:^{
            self.imageView.center = CGPointMake(570, self.imageView.center.y);
        } completion:^(BOOL finished) {
            self.imageView.hidden = YES;
            [self.delegate shouldSaveImageFromCell:self];
        }];
    } else if(self.imageView.center.x < -20) {
        self.shouldSave = YES;
        self.userInteractionEnabled = NO;
        [UIView animateWithDuration:0.20 animations:^{
            self.imageView.center = CGPointMake(-250, self.imageView.center.y);
        } completion:^(BOOL finished) {
            self.imageView.hidden = YES;
            [self.delegate shouldDeleteImageFromCell:self];
        }];
    } else {
        // move the image back to the center when the touch ends unless it made it into the range where
        // it should be saved or deleted
        [UIView animateWithDuration:0.15 animations:^{
            self.imageView.center = CGPointMake(150, 125);
        }];
    }
}

                                

// Consider making the image fade in like a polaroid would
- (void)addImage:(UIImage*)image
{
    self.imageView.image = image;
    [self.imageView setClipsToBounds:YES];
}

@end
