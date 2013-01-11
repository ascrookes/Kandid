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

@protocol ImageSelectionDelegate <NSObject>

- (void)didFinishSelection;

@end

@interface ImageSelectionViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, ImageCollectionCellDelegate>

@property (nonatomic, strong) ImageManager* imageManager;
@property (nonatomic, strong) IBOutlet UICollectionView* collectionView;
@property (nonatomic, strong) id <ImageSelectionDelegate> delegate;

+ (ImageSelectionViewController*)imageSelectionWithManager:(ImageManager *)manager AndDelegate:(id)delegate;

@end
