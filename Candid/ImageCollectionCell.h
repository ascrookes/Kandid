//
//  ImageCollectionCell.h
//  Candid
//
//  Created by Amadou Crookes.
//  Copyright (c) 2012 Amadou Crookes. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ImageCollectionCell;

typedef enum SaveLocation {
    SaveLocationPhotoAlbum = 0,
    //facebook
    //instagram
    //flickr
    //twitter
} SaveLocation;

@protocol ImageCollectionCellDelegate <NSObject>

@required
- (void)didSelectCell:(ImageCollectionCell*)cell forLocation:(SaveLocation)saveLocation;

@end

// this should be the same number as sources photos can be saved to


@interface ImageCollectionCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (nonatomic,strong) id <ImageCollectionCellDelegate> delegate;
@property (nonatomic) BOOL saveToPhotoAlbum;

// c.r.e. for delegate to be null
+ (ImageCollectionCell*)imageCellWithDelegate:(id<ImageCollectionCellDelegate>)delegateObject;
- (id)initWithDelegate:(id<ImageCollectionCellDelegate>)delegateObject;
- (void)setupViewWithImageData:(NSData*)imgData;
- (void)setupViewWithImage:(UIImage*)image;

@end
