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

- (void)addImageData:(NSData*)imageData save:(BOOL)saveImage
{
    [self.imageData addObject:imageData];
    [self.thumbnails addObject:[self thumbnailFromData:imageData]];
    
    if(saveImage) {
        [self saveImage:imageData watermark:YES];
    }
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

- (UIImage*)lastImage
{
    return [self getImageAtIndex:[self.thumbnails count] - 1];
}

- (void)saveImage:(NSData*)imageData watermark:(BOOL)watermark
{
    UIImage* img = [UIImage imageWithData:imageData];
    UIGraphicsBeginImageContext(img.size);
    [img drawInRect:CGRectMake(0, 0, img.size.width, img.size.height)];
    
    // If waterwark add a watermark to the bottom right corner of the saved image
    // WHY WONT THE WATERMAR STAY WHEN I SAVE THE IMAGE
    if(watermark) {
        //NSString* mark = @"Candid";
        //[mark drawInRect:CGRectMake(0, 0, img.size.width, img.size.height) withFont:[UIFont fontWithName:@"Didot" size:45]];
    }
    
    UIImage* saveImage = UIGraphicsGetImageFromCurrentImageContext();
    UIImageWriteToSavedPhotosAlbum(saveImage, nil, nil, nil);
    UIGraphicsEndImageContext();

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
