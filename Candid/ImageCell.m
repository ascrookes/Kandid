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
    
    
    ImageCell* cell = [[ImageCell alloc] initWithFrame:CGRectMake(0, 0, 320, 250)];
    UIImageView* filmRoll = [[UIImageView alloc] initWithFrame:CGRectMake(10, 0, 300, 250)];
    filmRoll.image = [UIImage imageNamed:@"roundedFilmRoll.png"];
    cell.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(50, 25, 200, 200)];
    
    [filmRoll addSubview:cell.imageView];
    [cell addSubview:filmRoll];
    cell.table = table;
    cell.shouldSave = NO;
    
    return cell;
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self.table];
    int middleX = self.frame.size.width / 2;
    int newX = middleX + (location.x - self.lastLocation.x);
    self.center = CGPointMake(newX, self.center.y);
}



- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.table.scrollEnabled = NO;
    UITouch* touch = [touches anyObject];
    self.lastLocation = [touch locationInView:self.table];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.table.scrollEnabled = YES;
    if(self.center.x > 340) {
        self.shouldSave = YES;
        self.userInteractionEnabled = NO;
        [UIView animateWithDuration:0.20 animations:^{
            self.alpha = 0;
            self.center = CGPointMake(570, self.center.y);
        } completion:^(BOOL finished) {
            //self.imageView.hidden = YES;
            
            [self.delegate shouldSaveImageFromCell:self];
        }];
    } else if(self.center.x < -20) {
        self.shouldSave = YES;
        self.userInteractionEnabled = NO;
        [UIView animateWithDuration:0.20 animations:^{
            self.alpha = 0;
            self.center = CGPointMake(-250, self.center.y);
        } completion:^(BOOL finished) {
            //self.imageView.hidden = YES;
            [self.delegate shouldDeleteImageFromCell:self];
        }];
    } else {
        // move the image back to the center when the touch ends unless it made it into the range where
        // it should be saved or deleted
        NSLog(@"moving back to the middle");
        [UIView animateWithDuration:0.15 animations:^{
            self.center = CGPointMake(self.frame.size.width / 2, self.center.y);
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
