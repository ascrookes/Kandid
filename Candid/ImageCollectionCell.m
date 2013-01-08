//
//  ImageCollectionCell.m
//  EvernoteImages
//
//  Created by Amadou Crookes.
//  Copyright (c) 2012 Amadou Crookes. All rights reserved.
//

#import "ImageCollectionCell.h"

@implementation ImageCollectionCell

- (void)setupViewWithImageData:(NSData*)imgData
{
    self.imageVIew.image = [UIImage imageWithData:imgData];
}


@end
