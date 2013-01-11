//
//  ImageCollectionCell.m
//  Candid
//
//  Created by Amadou Crookes.
//  Copyright (c) 2012 Amadou Crookes. All rights reserved.
//

#import "ImageCollectionCell.h"

@implementation ImageCollectionCell

@synthesize delegate;
@synthesize saveToPhotoAlbum = _saveToPhotoAlbum;

+ (ImageCollectionCell*)imageCellWithDelegate:(id<ImageCollectionCellDelegate>)delegateObject
{
    ImageCollectionCell* cell = [[ImageCollectionCell alloc] init];
    cell.delegate = delegateObject;
    cell.saveToPhotoAlbum = NO;
    return cell;
}

- (id)initWithDelegate:(id<ImageCollectionCellDelegate>)delegateObject
{
    ImageCollectionCell* cell = [self init];
    cell.delegate = delegateObject;
    cell.saveToPhotoAlbum = NO;
    return cell;
}

- (void)setupViewWithImageData:(NSData*)imgData
{
    self.saveButton.titleLabel.textColor = [UIColor colorWithRed:122/255.0 green:0 blue:1 alpha:1];
    self.imageView.image = [UIImage imageWithData:imgData];
}

- (void)setupViewWithImage:(UIImage*)image
{
    self.saveButton.titleLabel.textColor = [UIColor colorWithRed:122/255.0 green:0 blue:1 alpha:1];
    self.imageView.image = image;
}

- (IBAction)saveButtonAction:(id)sender
{
    self.saveToPhotoAlbum = !self.saveToPhotoAlbum;
    [self.delegate didSelectCell:self forLocation:SaveLocationPhotoAlbum];
}

- (void)setSaveToPhotoAlbum:(BOOL)saveToPhotoAlbum {
    _saveToPhotoAlbum = saveToPhotoAlbum;
    if(_saveToPhotoAlbum) {
        [self.saveButton setTitle:@"Do Not Save" forState:UIControlStateNormal];
    } else {
        [self.saveButton setTitle:@"Save" forState:UIControlStateNormal];
    }
    self.saveButton.titleLabel.textColor = [UIColor colorWithRed:122/255.0 green:0 blue:1 alpha:1];
}


@end
