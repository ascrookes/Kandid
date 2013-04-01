//
//  ImageCell.h
//  Candid
//
//  Created by Amadou Crookes on 8/14/12.
//  Copyright (c) 2012 Amadou Crookes. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ImageCell;
@protocol ImageCellDelegate <NSObject>

- (void)shouldSaveImageFromCell:(ImageCell*)imgCell;
- (void)shouldDeleteImageFromCell:(ImageCell*)imgCell;

@end

@interface ImageCell : UITableViewCell


@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UIImageView *filmRoll;
@property (strong, nonatomic) UIImageView* saveImage;
@property (strong, nonatomic) UIButton* trashButton;
@property (strong, nonatomic) id <ImageCellDelegate> delegate;

+ (ImageCell*)createImageCellWithTable:(UITableView*)table;
- (void)addImage:(UIImage*)image;

@end
