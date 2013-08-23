//
//  ViewController.h
//  Candid
//
//  Created by Amadou Crookes on 6/23/12.
//  Copyright (c) 2012 Amadou Crookes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>
#import <ImageIO/ImageIO.h>
#import "ImageCell.h"
#import <QuartzCore/QuartzCore.h>
#import "ImageManager.h"
#import "ActionControlView.h"

@interface ViewController : UIViewController <AVAudioRecorderDelegate, UITableViewDataSource, UITableViewDelegate>


// seperate UI and controller stuff
@property (nonatomic,strong) AVAudioRecorder* recorder;
@property (nonatomic,strong) NSTimer* timer;
@property (nonatomic) int volumeMax;
@property (nonatomic) int volumeMin;
@property (nonatomic) double totalPeak;
@property (nonatomic) double timeIntervals;
@property (nonatomic) double averageUpdatePeak;
@property (nonatomic,strong) NSTimer* updateTimer;
@property (nonatomic, strong) NSTimer* timedPicture;
@property (strong, nonatomic) UIButton *cameraButton;
@property (strong, nonatomic) UIButton* clearButton;
@property (strong, nonatomic) UIButton* hideButton;
@property (strong, nonatomic)  UITableView *table;
@property (strong,nonatomic) ImageManager* imageManager;
@property (nonatomic) int updateTimerActionCount;
@property (weak, nonatomic) IBOutlet UIView *hideView;
@property (weak, nonatomic) IBOutlet UIButton *flashButton;
@property (nonatomic, strong) NSDate* sessionTime;
@property (nonatomic) NSTimeInterval sessionTimeInterval;
@property (weak, nonatomic) IBOutlet UILabel *clearButtonLabel;
@property (weak, nonatomic) IBOutlet UILabel *hideButtonLabel;
@property (nonatomic) CGFloat previousBrightness;

@property (nonatomic, strong) ActionControlView* actionControl;
@property (weak, nonatomic) IBOutlet UILabel *hideViewLabel; //can just make the hide view a label and have one reference to it


// The hidden view stuff
@property (weak, nonatomic) IBOutlet UILabel *hideLabel;
@property (weak, nonatomic) IBOutlet UILabel *numPixHiddenLabel;
@property (weak, nonatomic) IBOutlet UILabel *volumeHideLabel;
@property (nonatomic, strong) NSTimer* hideTimer;


- (void)levelTimerCallback:(NSTimer *)timer;
- (void)setupRecorder;
- (void)captureNow;
- (IBAction)toggleRecording:(id)sender;
- (void)monitorVolume;
+ (void)setViewController:(UIViewController*)vc Title:(NSString*)title Font:(UIFont*)font;


#pragma mark - DELME (DEBUG PURPOSES)

@property (weak, nonatomic) IBOutlet UILabel  *levelLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imgView;



@end
