//
//  ImageManager.h
//  Candid
//
//  Created by Amadou Crookes on 8/15/12.
//  Copyright (c) 2012 Amadou Crookes. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageManager : NSObject

@property (nonatomic,strong) NSMutableArray* imageData;
@property (nonatomic,strong) NSMutableArray* thumbnails;

- (void)addImageData:(NSData*)imageData;
- (UIImage*)getImageAtIndex:(NSInteger)index;
- (void)conserveMemory;
- (NSInteger)count;

@end
