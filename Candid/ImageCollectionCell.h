//
//  ImageCollectionCell.h
//  EvernoteImages
//
//  Created by Amadou Crookes.
//  Copyright (c) 2012 Amadou Crookes. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageCollectionCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imageVIew;
- (void)setupViewWithImageData:(NSData*)imgData;

@end
