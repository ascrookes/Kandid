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
#import "ScrollBar.h"


@interface ViewController : UIViewController <AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate, AVAudioRecorderDelegate, UITableViewDelegate, UITableViewDataSource, ScrollBarDelegate>

@property (nonatomic,strong) AVAudioRecorder* recorder;
@property (nonatomic,strong) NSTimer* timer;

@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UIButton *record;
@property (weak, nonatomic) IBOutlet UILabel *volumeLabel;
@property (weak, nonatomic) IBOutlet UILabel *recordingLabel;

@property (strong, nonatomic) NSMutableArray* pictureData;

@property (weak, nonatomic) IBOutlet UISlider *slider;
@property (weak, nonatomic) IBOutlet UILabel *volumeLevelLabel;

@property (nonatomic) int volumeMax;
@property (weak, nonatomic) IBOutlet UILabel *picturesTaken;

@property (nonatomic) double totalPeak;
@property (nonatomic) double timeIntervals;
@property (nonatomic) double averageUpdatePeak;
@property (nonatomic,strong) NSTimer* updateTimer;
@property (nonatomic, strong) NSTimer* timedPicture;
@property (weak, nonatomic) IBOutlet UIView *scrollView;

@property (strong, nonatomic) UITableView *table;

@property (nonatomic, strong) ScrollBar* scrollBar;

@property (nonatomic) UIInterfaceOrientation currentOrientation;

- (void)levelTimerCallback:(NSTimer *)timer;
- (void)sliderChanged;
- (void)setupRecorder;
- (void)levelTimerCallback:(NSTimer *)timer;
- (void)captureNow;
- (IBAction)toggleRecording:(id)sender;
- (void)monitorVolume;


@end
