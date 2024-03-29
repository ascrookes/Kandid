//
//  ImageManager.h
//  Candid
//
//  Created by Amadou Crookes on 8/15/12.
//  Copyright (c) 2012 Amadou Crookes. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ImageManagerDelegate <NSObject>

- (void)didFinishSavingImages;

@end

@interface ImageManager : NSObject

@property (nonatomic, strong) id <ImageManagerDelegate> delegate;

+ (ImageManager*)imageManagerWithFileName:(NSString*)fileName;
- (void)addImageData:(NSData*)imageData save:(BOOL)saveImage;
- (UIImage*)getImageAtIndex:(NSInteger)index;
- (NSData*)getImageDataAtIndex:(NSInteger)index;
- (void)conserveMemory;
- (NSInteger)count;
- (UIImage*)lastImage;
- (void)saveImage:(NSData*)imageData watermark:(BOOL)watermark;
- (void)saveImageAtIndex:(NSInteger)index Watermark:(BOOL)watermark;
- (void)clearImageData;
- (void)removeImagesAtIndices:(NSArray*)indices;
- (void)writeInfoToFileName:(NSString*)fileName;
- (void)saveImages:(NSArray*)images;
- (BOOL)isSavingImages;


@end
