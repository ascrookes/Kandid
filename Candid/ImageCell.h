//
//  ImageCell.h
//  Candid
//
//  Created by Amadou Crookes on 7/4/12.
//  Copyright (c) 2012 Amadou Crookes. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ImageCellDelegate <NSObject>

//- (void)didClickImageInCell:(

@end

@interface ImageCell : UITableViewCell

- (id)initWithImageData:(NSData*)imageData reuseIdentifier:(NSString*)reuseIdentifier;
- (void)addImageToCell:(NSData*)imageData;
- (void)addThumbnailToCell:(UIImage*)thumbnail;

@end
