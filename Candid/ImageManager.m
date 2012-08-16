//
//  ImageManager.m
//  Candid
//
//  Created by Amadou Crookes on 8/15/12.
//  Copyright (c) 2012 Amadou Crookes. All rights reserved.
//

#import "ImageManager.h"

// images are square so this is the width and height
const int IMAGE_SIZE = 200;

@implementation ImageManager

@synthesize imageData = _imageData;
@synthesize thumbnails = _thumbnails;

//*********************************************************
//*********************************************************
#pragma mark - Images
//*********************************************************
//*********************************************************

- (void)addImageData:(NSData*)imageData
{
    [self.imageData addObject:imageData];
    [self.thumbnails addObject:[self thumbnailFromData:imageData]];
}

- (UIImage*)getImageAtIndex:(NSInteger)index
{
    id image = [self.thumbnails objectAtIndex:index];
    if(!image) {
        image = [self thumbnailFromData:[self.imageData objectAtIndex:index]];
        [self.thumbnails replaceObjectAtIndex:index withObject:image];
    }
    
    return image;
}

- (UIImage*)thumbnailFromData:(NSData*)data
{
    UIImage* img = [UIImage imageWithData:data];
    CGSize size = CGSizeMake(IMAGE_SIZE, IMAGE_SIZE);
    UIGraphicsBeginImageContext(size);
    [img drawInRect:CGRectMake(0,0,size.width,size.height)];
    UIImage* thumbnail = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return thumbnail;
}



//*********************************************************
//*********************************************************
#pragma mark - Memory & Misc
//*********************************************************
//*********************************************************

- (void)conserveMemory
{
    for(int i = 0; i < [self.thumbnails count]; i++)
    {
        [self.thumbnails replaceObjectAtIndex:i withObject:[NSNumber numberWithBool:NO]];
    }
}

- (NSInteger)count
{
    return [self.imageData count];
}

//*********************************************************
//*********************************************************
#pragma mark - Setters
//*********************************************************
//*********************************************************

- (NSMutableArray*)imageData
{
    if(!_imageData) {
        _imageData = [NSMutableArray array];
    }
    return _imageData;
}

- (NSMutableArray*)thumbnails
{
    if(!_thumbnails) {
        _thumbnails = [NSMutableArray array];
    }
    return _thumbnails;
}


@end
