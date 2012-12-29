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


@interface ViewController : UIViewController <AVAudioRecorderDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic,strong) AVAudioRecorder* recorder;
@property (nonatomic,strong) NSTimer* timer;
@property (nonatomic) int volumeMax;
@property (nonatomic) double totalPeak;
@property (nonatomic) double timeIntervals;
@property (nonatomic) double averageUpdatePeak;
@property (nonatomic,strong) NSTimer* updateTimer;
@property (nonatomic, strong) NSTimer* timedPicture;
@property (weak, nonatomic) IBOutlet UIButton *cameraButton;
@property (weak, nonatomic) IBOutlet UITableView *table;
@property (strong,nonatomic) ImageManager* imageManager;
@property (nonatomic) int updateTimerActionCount;
@property (weak, nonatomic) IBOutlet UIView *hideView;
@property (nonatomic) int picturesTakenThisMinute;
@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (weak, nonatomic) IBOutlet UIButton *hideButton;
@property (weak, nonatomic) IBOutlet UIButton *flashButton;

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


#pragma mark - DELME (DEBUG PURPOSES)

@property (weak, nonatomic) IBOutlet UILabel  *levelLabel;
@property (weak, nonatomic) IBOutlet UILabel *picturesTaken; // maybe keep this, but make it blend with the polaroid
@property (weak, nonatomic) IBOutlet UIImageView *imgView;



@end
