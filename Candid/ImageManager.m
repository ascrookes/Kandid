//
//  ImageManager.m
//  Candid
//
//  Created by Amadou Crookes on 8/15/12.
//  Copyright (c) 2012 Amadou Crookes. All rights reserved.
//

#import "ImageManager.h"
#import "KandidUtils.h"
#import "ALAssetsLibrary+CustomPhotoAlbum.h"

// images are square so this is the width and height
const int IMAGE_SIZE = 200;

// the distance from the images dimensions that the watermark is placed
// (these values are subtracted from the dimensions)
const int WATERMARK_DELTA_X = 150;
const int WATERMARK_DELTA_Y = 60;
// Used for the fram of the label used to draw that watermark
const int WATERMARK_WIDTH   = 130;
const int WATERMARK_HEIGHT  = 40;

// The bigger this number the small the watermark
const int WATER_MARK_FONT_REDUCE_FACTOR = 14;


@interface ImageManager ()

@property (nonatomic,strong) NSMutableArray* imageData;
@property (nonatomic,strong) NSMutableArray* thumbnails;

@end

@implementation ImageManager

@synthesize imageData = _imageData;
@synthesize thumbnails = _thumbnails;

//*********************************************************
//*********************************************************
#pragma mark - File I/O
//*********************************************************
//*********************************************************

// creates an image manager with the data from the file name
// if the file does not exist it just returns an empty image manager
+ (ImageManager*)imageManagerWithFileName:(NSString*)fileName
{
    ImageManager* manager = [[ImageManager alloc] init];

    manager.imageData = [NSMutableArray arrayWithContentsOfFile:[ImageManager getImageDataFilePath:fileName]];
    if(manager.imageData != nil || manager.imageData.count > 0) {
        //NSLog(@"Manager Image: %@", manager.imageData);
        // the thumbnails come from the image data so there is no need to save those seperatly
        manager.thumbnails = [NSMutableArray arrayWithCapacity:manager.imageData.count];
        for(int i = 0; i < manager.imageData.count; i++) {
            [manager.thumbnails addObject:[NSNull null]];
        }
    } else {
        manager.imageData = nil;
    }
    return manager;
}

- (void)writeInfoToFileName:(NSString*)fileName {
    [self.imageData writeToFile:[ImageManager getImageDataFilePath:fileName] atomically:YES];
}

+ (NSString*)getImageDataFilePath:(NSString*)fileName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString* filePath = [documentsDirectory stringByAppendingPathComponent:[fileName stringByAppendingString:@".imageData"]];
    return filePath;
}

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
        [self saveImage:imageData watermark:![[NSUserDefaults standardUserDefaults] boolForKey:@"premiumUser"]];
    }
}

- (UIImage*)getImageAtIndex:(NSInteger)index
{
    id image = [self.thumbnails objectAtIndex:index];
    //when memory needs to be conserved the thumbnails are replaced with nsnull
    // make sure to check before clearing them
    if([image isMemberOfClass:[NSNull class]]) {
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
    UIImage* saveImage = nil;
    if(watermark) {
        saveImage = [ImageManager addWatermarkToImageData:imageData];
    } else {
        saveImage = [UIImage imageWithData:imageData];
    }
    [ALAssetsLibrary saveImage:saveImage toAlbum:@"Kandid" withCompletionBlock:nil];
    UIGraphicsEndImageContext();
    [KandidUtils increaseSavedImagesCount];
}



// Draws the image in a context and then creates a label
// and draws that label on top of the image and returns that one
+ (UIImage*)addWatermarkToImageData:(NSData*)imageData
{
    UIImage* img = [UIImage imageWithData:imageData];
    UIGraphicsBeginImageContext(img.size);
    [img drawInRect:CGRectMake(0, 0, img.size.width, img.size.height)];
    
    int imgWidth = img.size.width;
    int imgHeight = img.size.height;
    // 2.4 and 7.5 are just percentages I found to work well with situating the waterwark in relation to the size of the image
    // the image varies by device camera quality so mae sure this works for all cams
    //int widthDelta  = 2.8;
    int heightDelta = 9.0;

    UILabel* watermark = [[UILabel alloc] initWithFrame:CGRectMake(0, imgHeight - imgHeight/heightDelta, imgWidth, imgHeight/heightDelta)];
    watermark.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
    watermark.textAlignment = UITextAlignmentRight;
    watermark.backgroundColor = [UIColor clearColor];
    watermark.textColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.6];
    watermark.text = @"Kandid ";
    watermark.font = [UIFont fontWithName:@"Didot-Italic" size:imgWidth/WATER_MARK_FONT_REDUCE_FACTOR];
    watermark.shadowColor = [UIColor blackColor];
    watermark.shadowOffset = CGSizeMake(0, -1.5);
    [watermark drawTextInRect:watermark.frame];
    
    UIImage* saveImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return saveImage;
}

- (void)saveImageAtIndex:(NSInteger)index Watermark:(BOOL)watermark {
    [self saveImage:[self.imageData objectAtIndex:index] watermark:watermark];
}

- (void)removeImagesAtIndices:(NSArray*)indices
{
    // sort the array in descending order and remove the objects in that order to avoid removing the wrong objects
    NSArray* sortedIndices = [indices sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"self" ascending:NO]]];
    for(int i = 0; i < [sortedIndices count]; i++) {
        int index = [[sortedIndices objectAtIndex:i] intValue];
        [self.imageData  removeObjectAtIndex:index];
        [self.thumbnails removeObjectAtIndex:index];        
    }
}

//*********************************************************
//*********************************************************
#pragma mark - Memory & Misc
//*********************************************************
//*********************************************************

// Fill the entire thumbnail array with a NULL, since thumbnails can be recreated
- (void)conserveMemory
{
    for(int i = 0; i < [self.thumbnails count]; i++) {
        [self.thumbnails replaceObjectAtIndex:i withObject:[NSNull null]];
    }
}

// if this is the datasource for a table (or something like that)
// reload the data immedietly after calling this function
- (void)clearImageData
{
    self.imageData = NULL;
    self.thumbnails = NULL;
}

// use image data because that is always accurate in terms of photos
- (NSInteger)count
{
    return [self.imageData count];
}

//*********************************************************
//*********************************************************
#pragma mark - Getters/Setters
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
