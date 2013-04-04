//
//  ActionControlView.m
//  Candid
//
//  Created by Amadou Crookes on 4/1/13.
//  Copyright (c) 2013 Amadou Crookes. All rights reserved.
//

const int CONTROL_VIEW_HEIGHT = 95;
const int BUTTON_HEIGHT = 60;
const int START_BUTTON_WIDTH = 130;

#import "ActionControlView.h"

@interface ActionControlView ()

@property (nonatomic) CGPoint origCenter;
@property (nonatomic) CGPoint beganPoint;

@end

@implementation ActionControlView

@synthesize camera     = _camera;
@synthesize delegate   = _delegate;
@synthesize origCenter = _origCenter;
@synthesize beganPoint = _beganPoint;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

+ (ActionControlView*)actionControl:(id <ActionControlDelegate>)del {

    CGSize size = [[UIScreen mainScreen] bounds].size;
    int screenWidth = size.width;
    int x = 0;
    
    // remove an extra 20 for the status bar
    int y = size.height - CONTROL_VIEW_HEIGHT - 20;

    ActionControlView* acv = [[ActionControlView alloc] initWithFrame:CGRectMake(x, y, screenWidth, CONTROL_VIEW_HEIGHT)];
    acv.origCenter = acv.center;
    acv.delegate = del;
    acv.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"controlImage.png"]];
    
    int sideButtonWidth = (screenWidth - START_BUTTON_WIDTH) / 2;
    int sideButtonY = CONTROL_VIEW_HEIGHT - BUTTON_HEIGHT;
    UIButton* hide  = [[UIButton alloc] initWithFrame:
                       CGRectMake(0, sideButtonY, sideButtonWidth, BUTTON_HEIGHT)];
    UIButton* clear = [[UIButton alloc] initWithFrame:
                       CGRectMake(sideButtonWidth + START_BUTTON_WIDTH, sideButtonY, sideButtonWidth, BUTTON_HEIGHT)];
    UIButton* start = [[UIButton alloc] initWithFrame:
                       CGRectMake(sideButtonWidth, sideButtonY, START_BUTTON_WIDTH, BUTTON_HEIGHT)];
    int imageWidth  = 60;
    int imageHeight = 40;
    acv.camera      = [[UIImageView alloc] initWithFrame:
                       CGRectMake((START_BUTTON_WIDTH/2) - (imageWidth/2), (BUTTON_HEIGHT - imageHeight)/2 , imageWidth, imageHeight)];
    
    
    [hide  setBackgroundImage:[UIImage imageNamed:@"sideButton.png"] forState:UIControlStateNormal];
    [clear setBackgroundImage:[UIImage imageNamed:@"sideButton.png"] forState:UIControlStateNormal];
    [start setBackgroundImage:[UIImage imageNamed:@"mainButton.png"] forState:UIControlStateNormal];
    [acv.camera setImage:     [UIImage imageNamed:@"cameraStart.png"]];
    
    
    // when a button is clicked tell the delegate
    [hide  addTarget:del action:@selector(shouldHide)      forControlEvents:UIControlEventTouchUpInside];
    [clear addTarget:del action:@selector(shouldClear)     forControlEvents:UIControlEventTouchUpInside];
    [start addTarget:del action:@selector(toggleRecording) forControlEvents:UIControlEventTouchUpInside];
    
    [acv addSubview:hide];
    [acv addSubview:clear];
    [acv addSubview:start];
    [start addSubview:acv.camera];
    
    return acv;
}


- (void)setRecording:(BOOL)recording {
    NSString* imageName = recording ? @"cameraStop.png" : @"cameraStart.png";
    [self.camera setImage:[UIImage imageNamed:imageName]];
    CGAffineTransform rotation;
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    BOOL shouldRotateImage = YES;
    switch (orientation) {
        case UIDeviceOrientationPortrait:
            rotation = CGAffineTransformMakeRotation(0.0);
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            rotation = CGAffineTransformMakeRotation(M_PI);
            break;
        case UIDeviceOrientationLandscapeLeft:
            rotation = CGAffineTransformMakeRotation(M_PI_2);
            break;
        case UIDeviceOrientationLandscapeRight:
            rotation = CGAffineTransformMakeRotation(M_PI + M_PI_2);
            break;
        default:
            shouldRotateImage = NO;
            break;
    }
    
    if(shouldRotateImage) {
        [UIView animateWithDuration:0.25 animations:^{
            self.camera.transform = rotation;
        }];
    }
}

- (void)shouldBeHidden:(BOOL)hidden {
    int newY  = hidden ? 562 : 505;
    [UIView animateWithDuration:0.2 animations:^{
        self.center = CGPointMake(self.center.x, newY);
    }];
}




//*********************************************************
//*********************************************************
#pragma mark - Touch Handling
//*********************************************************
//*********************************************************

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch* touch = [touches anyObject];
    self.beganPoint = [touch locationInView:self];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    // DELME -- this must change to handle 3.5 inch screen
    int newY = (self.center.y > 540) ? 562 : 505;
    
    [UIView animateWithDuration:0.2 animations:^{
        self.center = CGPointMake(self.origCenter.x, newY);
    }];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch* touch = [touches anyObject];
    CGPoint loc = [touch locationInView:self];
    
    int newY = self.center.y - (self.beganPoint.y - loc.y);
    CGSize screenSize =[[UIScreen mainScreen] bounds].size;
    if(newY < self.origCenter.y) {
        newY = 505;
    } else if(newY > screenSize.height - 10) {
        newY = 558;
    }
    
    self.center = CGPointMake(self.origCenter.x, newY);
    
}







@end
