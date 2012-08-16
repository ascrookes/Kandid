//
//  ImageCell.h
//  Candid
//
//  Created by Amadou Crookes on 8/14/12.
//  Copyright (c) 2012 Amadou Crookes. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageCell : UITableViewCell


@property (weak, nonatomic) IBOutlet UIImageView *imageView;

- (void)addImage:(UIImage*)image;

@end
