//
//  ImageSelectionViewController.h
//  Candid
//
//  Created by Amadou Crookes on 1/6/13.
//  Copyright (c) 2013 Amadou Crookes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageManager.h"
#import "ImageCollectionCell.h"

@interface ImageSelectionViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, ImageCollectionCellDelegate>

@property (nonatomic, strong) ImageManager* imageManager;
@property (nonatomic, strong) IBOutlet UICollectionView* collectionView;

+ (ImageSelectionViewController*)imageSelectionWithManager:(ImageManager*)manager;
+ (void)presentModalImageSelectionWithManager:(ImageManager*)manager;

@end
