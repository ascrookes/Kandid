//
//  ImageManager.h
//  Candid
//
//  Created by Amadou Crookes on 8/15/12.
//  Copyright (c) 2012 Amadou Crookes. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageManager : NSObject


- (void)addImageData:(NSData*)imageData save:(BOOL)saveImage;
- (UIImage*)getImageAtIndex:(NSInteger)index;
- (void)conserveMemory;
- (NSInteger)count;
- (UIImage*)lastImage;
- (void)saveImage:(NSData*)imageData watermark:(BOOL)watermark;
- (void)saveImageAtIndex:(NSInteger)index Watermark:(BOOL)watermark;
- (void)clearImageData;
- (void)removeImagesAtIndices:(NSArray*)indices;



@end
