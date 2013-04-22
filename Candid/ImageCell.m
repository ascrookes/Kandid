//
//  ImageCell.m
//  Candid
//
//  Created by Amadou Crookes on 8/14/12.
//  Copyright (c) 2012 Amadou Crookes. All rights reserved.
//

#import "ImageCell.h"


const int saveX   = 350;
const int deleteX = -30;
// the distance away from the save or delete point to animate the image to
const int animateDistance = 300;


@interface ImageCell ()

@property (nonatomic) CGPoint lastLocation;
@property (nonatomic,strong) UITableView* table;
@property (nonatomic) BOOL shouldSave;

@end

@implementation ImageCell
@synthesize imageView;
@synthesize lastLocation = _lastLocation;
@synthesize table = _table;
@synthesize filmRoll = _filmRoll;
@synthesize saveImage = _saveImage;
@synthesize trashButton = _trashButton;

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
    cell.filmRoll = [[UIImageView alloc] initWithFrame:CGRectMake(10, 0, 300, 250)];
    cell.filmRoll.image = [UIImage imageNamed:@"roundedFilmRoll.png"];
    cell.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(50, 25, 200, 200)];
    
    cell.table = table;
    cell.shouldSave = NO;
    
    int ioImageWidth  = 150;
    int ioImageHeight = 160;
    int ioYCoord = (cell.filmRoll.frame.size.height - ioImageHeight) / 2;
    cell.saveImage = [[UIImageView alloc] initWithFrame:CGRectMake(-ioImageWidth, ioYCoord, ioImageWidth, 160)];
    cell.saveImage.image = [UIImage imageNamed:@"save.png"];
    
    cell.trashButton = [[UIImageView alloc] initWithFrame:CGRectMake(cell.filmRoll.frame.size.width, ioYCoord, ioImageWidth, 160)];
    cell.trashButton.image = [UIImage imageNamed:@"delete.png"];
    
    [cell.filmRoll addSubview:cell.saveImage];
    [cell.filmRoll addSubview:cell.trashButton];
    [cell.filmRoll addSubview:cell.imageView];
    [cell addSubview:cell.filmRoll];
    
    cell.trashButton.alpha = 0;
    cell.saveImage.alpha = 0;
    
    return cell;
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self.table];
    int middleX = self.frame.size.width / 2;
    int newX = middleX + (location.x - self.lastLocation.x);
    self.filmRoll.center = CGPointMake(newX, self.filmRoll.center.y);
    
    int filmCenterX = self.filmRoll.center.x;
    int centerX = self.center.x;
    
    if(filmCenterX > centerX) {
        self.saveImage.alpha   = (filmCenterX - centerX)/ (double)(saveX - centerX);
        NSString* imageName = (filmCenterX >= saveX) ? @"saveActive.png" : @"save.png";
        self.saveImage.image = [UIImage imageNamed:imageName];
    } else if(self.filmRoll.center.x < centerX) {
        int dist = -deleteX + centerX; // the distance from the center to the delete location
        int loc  = -(filmCenterX - centerX);
        self.trashButton.alpha = loc/(double)dist;
        NSString* imageName = (filmCenterX <= deleteX) ? @"deleteActive.png" : @"delete.png";
        self.trashButton.image = [UIImage imageNamed:imageName];
    } else {
        
    }
    
}



- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.table.scrollEnabled = NO;
    UITouch* touch = [touches anyObject];
    self.lastLocation = [touch locationInView:self.table];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    int centerX = self.center.x;
    
    self.table.scrollEnabled = YES;
    if(self.filmRoll.center.x > saveX) {
        self.shouldSave = YES;
        self.userInteractionEnabled = NO;
        [UIView animateWithDuration:0.20 animations:^{
            self.filmRoll.center = CGPointMake(saveX + animateDistance, self.filmRoll.center.y);
        } completion:^(BOOL finished) {
            //self.imageView.hidden = YES;
            self.saveImage.hidden = YES;
            [self.delegate shouldSaveImageFromCell:self];
        }];
    } else if(self.filmRoll.center.x < deleteX) {
        self.shouldSave = YES;
        self.userInteractionEnabled = NO;
        [UIView animateWithDuration:0.20 animations:^{
            self.filmRoll.center = CGPointMake(deleteX - animateDistance, self.filmRoll.center.y);
        } completion:^(BOOL finished) {
            self.trashButton.hidden = YES;
            [self.delegate shouldDeleteImageFromCell:self];
        }];
    } else {
        // move the image back to the center when the touch ends unless it made it into the range where
        // it should be saved or deleted
        //NSLog(@"moving back to the middle");
        [UIView animateWithDuration:0.15 animations:^{
            self.saveImage.alpha = 0;
            self.trashButton.alpha = 0;
            self.filmRoll.center = CGPointMake(centerX, self.filmRoll.center.y);
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
