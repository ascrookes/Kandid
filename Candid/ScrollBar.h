//
//  ScrollBar.h
//  Candid
//
//  Created by Amadou Crookes on 6/28/12.
//  Copyright (c) 2012 Amadou Crookes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreAudio/CoreAudioTypes.h>
#import "ImageCell.h"

@protocol ScrollBarDelegate <NSObject>

- (void)didSelectImage:(NSData*)imageData;
- (void)stop;
- (void)start;

@end

@interface ScrollBar : UIView <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UITableView* table;
@property (strong, nonatomic) IBOutlet UIView *leftTab;
@property (strong, nonatomic) IBOutlet UIView *rightTab;
@property (nonatomic,strong) NSMutableArray* pictureData;
@property (strong,nonatomic) NSMutableArray* thumbnails;
@property (strong,nonatomic) id <ScrollBarDelegate> delegate;

@property (nonatomic) double orientationTranform;

- (id)initWithSuperView:(UIView*)superView;

- (void)addImage:(NSData*)imageData;

- (void)rotateToOrientation:(UIInterfaceOrientation)desiredOrientation;

@end
