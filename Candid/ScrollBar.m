//
//  ScrollBar.m
//  Candid
//
//  Created by Amadou Crookes on 6/28/12.
//  Copyright (c) 2012 Amadou Crookes. All rights reserved.
//

#import "ScrollBar.h"

const int HEIGHT      = 92;
const int TAB_WIDTH   = 40;
const int TABLE_WIDTH = 320 - (TAB_WIDTH * 2);
const int PAUSED = 1;
const int RECORDING = 0;
const int STOPPED = 2;



@interface ScrollBar ()

@property (nonatomic) int status;

@end

@implementation ScrollBar



@synthesize table             = _table;
@synthesize leftTab           = _leftTab;
@synthesize rightTab          = _rightTab;
@synthesize pictureData       = _pictureData;
@synthesize thumbnails        = _thumbnails;
@synthesize delegate          = _delegate;
@synthesize orientationTranform = _orientationTranform;
@synthesize status = _status;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (IBAction)leftTabAction:(id)sender 
{
    NSLog(@"Left Tab Action");
    [self.delegate stop];
}


- (IBAction)rightTabAction:(id)sender 
{
    NSLog(@"Right Tab Action");
    [self.delegate start];
}


- (void)addImage:(NSData*)imageData
{
    dispatch_queue_t queue = dispatch_queue_create("add Image", nil);
    dispatch_async(queue, ^{
        [self.pictureData addObject:imageData];
        UIImage* img = [UIImage imageWithData:imageData];
        CGSize size = CGSizeMake(92, 92);
        UIGraphicsBeginImageContext(size);
        [img drawInRect:CGRectMake(0,0,size.width,size.height)];
        UIImage* thumbnail = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [self.thumbnails addObject:thumbnail];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.table reloadData];
        });
        
    });
    dispatch_release(queue);
}

#pragma mark - UITableView Datasource/Delegate


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    self.table.hidden = ([self.thumbnails count] == 0);
    return [self.thumbnails count];   
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* reuse = @"Image Cell";
    ImageCell* cell = [self.table dequeueReusableCellWithIdentifier:reuse];
    if(cell == nil) {
        cell = [[ImageCell alloc] initWithFrame:CGRectMake(0, 0, 92, 92)];
    }
    [cell addThumbnailToCell:[self.thumbnails objectAtIndex:indexPath.row]];
    cell.transform = CGAffineTransformMakeRotation(self.orientationTranform);
    //cell.frame = CGRectMake(0, 0, 92, 92);
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 92;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.delegate didSelectImage:[self.pictureData objectAtIndex:indexPath.row]];
    NSLog(@"WANG");
}




#pragma mark - Superview

- (id)initWithSuperView:(UIView*)superView
{
    self.backgroundColor = [UIColor blackColor];
    int bottom = superView.frame.size.height - 92;

    NSArray* xibs = [[NSBundle mainBundle] loadNibNamed:@"ScrollBar" owner:self options:nil];
    self = [xibs objectAtIndex:0];
    self.table.transform = CGAffineTransformMakeRotation(-1.57079633);
    
    self.table.frame = CGRectMake(40, 0, 240, 92);
    self.table.delegate = self;
    self.table.dataSource = self;
    self.table.backgroundColor = [UIColor blackColor];
    self.table.pagingEnabled = NO;
    
    UIImage* pause = [UIImage imageNamed:@"pause@2x.png"];
    UIImage* play = [UIImage imageNamed:@"play@2x.png"];
    UIImage* stop = [UIImage imageNamed:@"stop@2x.png"];
    
    CGRect imgFrame = CGRectMake(10, 36, 20, 20);
    UIImageView* pauseView = [[UIImageView alloc] initWithImage:pause];
    UIImageView* playView = [[UIImageView alloc] initWithImage:play];
    UIImageView* stopView = [[UIImageView alloc] initWithImage:stop];
    stopView.frame = imgFrame;
    playView.frame = imgFrame;
    
    
    self.leftTab = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 92)];
    self.leftTab.backgroundColor = [UIColor lightGrayColor];
    [self.leftTab addSubview:stopView];
    UITapGestureRecognizer* leftTap = [[UITapGestureRecognizer alloc] initWithTarget:self 
                                                                              action:@selector(leftTabAction:)];
    [self.leftTab addGestureRecognizer:leftTap];
    self.rightTab = [[UIView alloc] initWithFrame:CGRectMake(280, 0, 40, 92)];
    self.rightTab.backgroundColor = [UIColor lightGrayColor];
    [self.rightTab addSubview:playView];
    UITapGestureRecognizer* rightTap = [[UITapGestureRecognizer alloc] initWithTarget:self 
                                                                               action:@selector(rightTabAction:)];
    [self.rightTab addGestureRecognizer:rightTap];
    self.frame = CGRectMake(0, bottom, 320, 92);

    
    [self addSubview:self.leftTab];
    [self addSubview:self.rightTab];
    
    

    //[superView addSubview:self];
    [superView addSubview:self];
    
    return self;
}


#pragma mark - Setters

- (NSMutableArray*)pictureData
{
    if(!_pictureData) {
        _pictureData = [[NSMutableArray alloc] init];
    }
    return _pictureData;
}

- (NSMutableArray*)thumbnails
{
    if(!_thumbnails) {
        _thumbnails = [[NSMutableArray alloc] init];
    }
    return _thumbnails;
}

- (int)status
{
    if(!_status) {
        _status = 0;
    }
    return _status;
}







- (void)rotateToOrientation:(UIInterfaceOrientation)desiredOrientation
{
    double values[5] = { 0, -M_PI/2, M_PI/2, M_PI/2, -M_PI/2 };

    //self.table.transform = CGAffineTransformMakeRotation(values[originOrientation]);
    self.table.transform = CGAffineTransformMakeRotation(values[desiredOrientation]);
    self.orientationTranform = (desiredOrientation == 3 || desiredOrientation == 4) ? -M_PI/2 : 0;
    [self.table reloadData];
}






@end
