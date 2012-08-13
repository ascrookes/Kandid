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


@interface ViewController : UIViewController <AVAudioRecorderDelegate>

@property (nonatomic,strong) AVAudioRecorder* recorder;
@property (nonatomic,strong) NSTimer* timer;
@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (strong, nonatomic) NSMutableArray* pictureData;
@property (nonatomic) int volumeMax;
@property (weak, nonatomic) IBOutlet UILabel *picturesTaken;
@property (nonatomic) double totalPeak;
@property (nonatomic) double timeIntervals;
@property (nonatomic) double averageUpdatePeak;
@property (nonatomic,strong) NSTimer* updateTimer;
@property (nonatomic, strong) NSTimer* timedPicture;
@property (weak, nonatomic) IBOutlet UIButton *cameraButton;

- (void)levelTimerCallback:(NSTimer *)timer;
- (void)setupRecorder;
- (void)captureNow;
- (IBAction)toggleRecording:(id)sender;
- (void)monitorVolume;


@end
