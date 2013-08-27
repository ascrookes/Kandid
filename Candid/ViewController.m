//
//  ViewController.m
//  Candid
//
//  Created by Amadou Crookes on 6/23/12.
//  Copyright (c) 2012 Amadou Crookes. All rights reserved.
//

#import "ViewController.h"
#import "ImageSelectionViewController.h"
#import "DatabaseManager.h"
#import "KandidUtils.h"
#import "ImageCell.h"

//*********************************************************
//*********************************************************
#pragma mark - Camera Related constants
//*********************************************************
//*********************************************************

const int SECONDS_BETWEEN_IMAGES = -5;
const int PEAK_DIFFERENCE = 5;
const int ADJUST_NUM = 5;
const int UPDATE_TIME = 15; //the time that it takes before updating the threshold
const int MINUTE = 60/UPDATE_TIME;
const int MAIN_TIMER_REPEAT_TIME = 0.3;
// The cushion above the max to monitor where the max should be
const int VOLUME_CUSHION = 20;
// if the max average is greater than -5 set it too take images on a timer
const int TOO_LOUD_TIMED_SHOT_INTERVAL = 45;
// if the average peak is above or equal to this the timed shot begins
const double TIMED_SHOT_LEVEL = -5;
const int MAX_PICTURES_PER_MINUTE = 5;
const int VOLUME_MIN = -60; // the minimum the volume limit can get
const int MAX_IMAGES_IN_TABLE = 25;
// the amount of images to save before asking them to review the app
const int NUMBER_OF_IMAGES_TO_REVIEW = 20;
// TODO -- move static variables to kandid utils

const int CAMERA_BUTTON_DIAMETER = 90;
const int OTHER_BUTTON_DIAMETER = 70;
const int NOTIFIER_HEIGHT = 20;


static NSString* CLEAR_ALERT_TITLE = @"Are You Sure?";
static NSString* REVIEW_ALERT_TITLE = @"Enjoying Kandid?";
static NSString* HAS_SHOWN_REVIEW_KEY = @"hasShownReviewAlert";
// TODO -- change this when the app name is final and has been submitted to apple
static NSString* KANDID_ITUNES_URL = @"http://itunes.com/apps/ijumbo";


//*********************************************************
//*********************************************************
#pragma mark - Enums
//*********************************************************
//*********************************************************

// if this changes, also change the setFlashMode function
// so that it bounds check correctly
typedef enum FLASH_MODE {
    FLASH_MODE_ON   = 0,
    FLASH_MODE_OFF,
    /*FLASH_MODE_AUTO = 2*/
} FLASH_MODE;

typedef enum ClearAlertViewIndex {
    ClearAlertViewIndexNevermind = 0,
    ClearAlertViewIndexClear,
} ClearAlertViewIndex;

typedef enum ReviewAppAlertIndex {
    ReviewAlertIndexNo = 0,
    ReviewAlertIndexYes,
} ReviewAppAlertIndex;


@interface ViewController () <UIAlertViewDelegate, ImageSelectionDelegate, ImageManagerDelegate, ImageCellDelegate>

//*********************************************************
//*********************************************************
#pragma mark - Property Stuff
//*********************************************************
//*********************************************************

@property (nonatomic, strong) AVCaptureStillImageOutput* imageCapture;
@property (nonatomic, strong) AVCaptureDeviceInput* camInput;
@property (nonatomic, strong) AVCaptureDevice* camDevice;
@property (nonatomic, strong) AVCaptureSession* session;
@property (nonatomic, strong) NSDate* lastTakenTime;
@property (nonatomic, strong) AVCaptureConnection *videoConnection;
@property (nonatomic) int numPictures;
@property (nonatomic) FLASH_MODE flashMode;
@property (nonatomic) BOOL isRunning;
@property (nonatomic) BOOL shouldResumeAfterInterruption;
@property (nonatomic) BOOL cameraIsReady;

@property (nonatomic) unsigned int imagesTakenThisMinute;

@end

@implementation ViewController

@synthesize levelLabel = _levelLabel;

@synthesize recorder = _recorder;
@synthesize timer = _timer;

@synthesize imageCapture = _imageCapture;
@synthesize camInput = _camInput;
@synthesize camDevice = _camDevice;
@synthesize session = _session;
@synthesize videoConnection = _videoConnection;

@synthesize imageManager = _imageManager;

@synthesize volumeMax = _volumeMax;
@synthesize volumeMin = _volumeMin;

@synthesize lastTakenTime = _lastTakenTime;
@synthesize numPictures = _numPictures;
@synthesize totalPeak = _totalPeak;
@synthesize timeIntervals = _timeIntervals;
@synthesize averageUpdatePeak = _averageUpdatePeak;
@synthesize updateTimer = _updateTimer;
@synthesize timedPicture = _timedPicture;
@synthesize cameraButton = _cameraButton;
@synthesize hideButton = _hideButton;
@synthesize clearButton = _clearButton;
@synthesize table = _table;
@synthesize updateTimerActionCount;
@synthesize hideView = _hideView;
@synthesize hideLabel = _hideLabel;
@synthesize numPixHiddenLabel = _numPixHiddenLabel;
@synthesize volumeHideLabel = _volumeHideLabel;
@synthesize hideTimer = _hideTimer;
@synthesize sessionTime = _sessionTime;
@synthesize sessionTimeInterval;
@synthesize previousBrightness;
@synthesize cameraIsReady = _cameraIsReady;

@synthesize notifier = _notifier;
@synthesize notifierTimer = _notifierTimer;

@synthesize imagesTakenThisMinute = _imagesTakenThisMinute;

//*********************************************************
//*********************************************************
#pragma mark - Standard Stuff
//*********************************************************
//*********************************************************

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self addNotificationObservers];
    if(!self.recorder.recording) {
        [self.recorder prepareToRecord];
        self.recorder.meteringEnabled = YES;
    }
    self.clearButtonLabel.textColor = [KandidUtils kandidPurple];
    self.hideButtonLabel.textColor = [KandidUtils kandidPurple];
    
    self.table.backgroundColor = [UIColor clearColor];//cc
    self.table.separatorColor  = [UIColor clearColor];
    self.table.showsHorizontalScrollIndicator = YES;
    self.sessionTimeInterval = 0;
    self.volumeMax = -5.0;
    self.flashMode = FLASH_MODE_OFF;
    self.flashButton.hidden = YES;
    self.cameraIsReady = YES;
    self.isRunning = NO;
    self.levelLabel.text = @"";
    self.shouldResumeAfterInterruption = NO;
    
    self.hideViewLabel.font = [UIFont fontWithName:@"Dosis-SemiBold" size:100];
    
    [self addGlobalButtons];
    self.table.alpha = 0;
    [UIView animateWithDuration:0.5 animations:^{
        self.table.alpha = 1;
    }];
    
    [self updateUI];
}

- (void)viewDidAppear:(BOOL)animated {
    self.previousBrightness = [[UIScreen mainScreen] brightness];
    [self shouldPresentTutorial];
}

+ (void)setViewController:(UIViewController*)vc Title:(NSString*)title Font:(UIFont*)font {
    UIButton *titleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [titleButton setFrame:CGRectMake(0, 0, 170, 35)];
    [titleButton setTitle:title forState:UIControlStateNormal];
    titleButton.titleLabel.font = font;
    titleButton.titleLabel.textColor = [KandidUtils kandidPurple];
    titleButton.userInteractionEnabled = NO;
    // make interactions possible and add an action here if wanted
    vc.navigationItem.titleView = titleButton;
}

+ (UIColor*)kandidPurple {
    return [UIColor colorWithRed:122/255.0 green:0 blue:1 alpha:1];
}

// adds the functions to be called by specific notifications
- (void)addNotificationObservers
{
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUI) name:UIDeviceOrientationDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackground) name:@"kandid.didEnterBackground" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(beginInterruption) name:@"kandid.beginInterruption" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(endInterruption) name:@"kandid.endInterruption" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillTerminate) name:@"kandid.appWillTerminate" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkForNumberOfImagesSaved) name:@"kandid.appBecameActive" object:nil];
}

- (void)checkForNumberOfImagesSaved {
    BOOL hasShownAlert = [[NSUserDefaults standardUserDefaults] boolForKey:HAS_SHOWN_REVIEW_KEY];
    if(!hasShownAlert && [KandidUtils getSavedCount] >= NUMBER_OF_IMAGES_TO_REVIEW) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:HAS_SHOWN_REVIEW_KEY];
        //UIAlertView* alert = [[UIAlertView alloc] initWithTitle:REVIEW_ALERT_TITLE message:@"Would you review the app?" delegate:self cancelButtonTitle:@"Not Now" otherButtonTitles:@"OK!", nil];
        //[alert show];
        // TODO -- add this back in after beta testing
    }
}

- (void)didEnterBackground {
    [[UIScreen mainScreen] setBrightness:self.previousBrightness];
    [self stopEverything];
    [self showHiddenLabels];
    [self.imageManager writeInfoToFileName:@"kandid"];
}


// since the UI does not rotate show something to indicate
// that the camera can face any direction
- (void)updateUI {
    [self.table reloadData];
    self.numPictures = [self.imageManager count];
}

- (void)viewDidUnload {
    [self setCameraButton:nil];
    [self setTable:nil];
    [self setLevelLabel:nil];
    [self setHideView:nil];
    [self setFlashButton:nil];
    [self setHideLabel:nil];
    [self setNumPixHiddenLabel:nil];
    [self setVolumeHideLabel:nil];
    [self setClearButtonLabel:nil];
    [self setHideButtonLabel:nil];
    [self setHideViewLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

// TODO(amadou): Animate these buttons coming onto the screen from below.
- (void)addGlobalButtons {
    int camera_y = [KandidUtils screenHeight] - CAMERA_BUTTON_DIAMETER - 30;
    int other_y = camera_y + (CAMERA_BUTTON_DIAMETER - OTHER_BUTTON_DIAMETER)/2;
    self.cameraButton = [[UIButton alloc] initWithFrame:CGRectMake([KandidUtils screenWidth]/2 - CAMERA_BUTTON_DIAMETER/2, camera_y, CAMERA_BUTTON_DIAMETER, CAMERA_BUTTON_DIAMETER)];
    self.hideButton = [[UIButton alloc] initWithFrame:CGRectMake(20, other_y, OTHER_BUTTON_DIAMETER, OTHER_BUTTON_DIAMETER)];
    self.clearButton = [[UIButton alloc] initWithFrame:CGRectMake([KandidUtils screenWidth] - OTHER_BUTTON_DIAMETER - 20, other_y, OTHER_BUTTON_DIAMETER, OTHER_BUTTON_DIAMETER)];
    
    [self.hideButton addTarget:self action:@selector(toggleHide:) forControlEvents:UIControlEventTouchUpInside];
    [self.clearButton addTarget:self action:@selector(clearFilmRoll:) forControlEvents:UIControlEventTouchUpInside];
    [self.cameraButton addTarget:self action:@selector(toggleRecording:) forControlEvents:UIControlEventTouchUpInside];
    
    self.cameraButton.backgroundColor = [UIColor clearColor];
    self.hideButton.backgroundColor = [UIColor clearColor];
    self.clearButton.backgroundColor = [UIColor clearColor];
    
    [self.cameraButton setBackgroundImage:[UIImage imageNamed:@"cameraButton.png"] forState:UIControlStateNormal];
    [self.hideButton setBackgroundImage:[UIImage imageNamed:@"cameraButton.png"] forState:UIControlStateNormal];
    [self.clearButton setBackgroundImage:[UIImage imageNamed:@"cameraButton.png"] forState:UIControlStateNormal];
    
    [self.view insertSubview:self.cameraButton belowSubview:self.hideView];
    [self.view insertSubview:self.hideButton belowSubview:self.hideView];
    [self.view insertSubview:self.clearButton belowSubview:self.hideView];
}

//*********************************************************
//*********************************************************
#pragma mark - Constructors
//*********************************************************
//*********************************************************

+ (ViewController*)standardViewController {
    ViewController* vc = [[ViewController alloc] init];
    CGRect table_frame = CGRectMake(0, 20, vc.view.bounds.size.width, vc.view.bounds.size.height - 20);
    vc.table = [[UITableView alloc] initWithFrame:table_frame];
    vc.table.delegate = vc;
    vc.table.dataSource = vc;
    [vc.view addSubview:vc.table];
    // TODO(amadou): Add flash button on top of table - not attached to table though
    // TODO(amadou): Add hide view
    
    return vc;
}

//*********************************************************
//*********************************************************
#pragma mark - Orientation
//*********************************************************
//*********************************************************

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    //[UIView setAnimationsEnabled:NO];
    //[self setUIBasedOnOrientation:interfaceOrientation];
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


//*********************************************************
//*********************************************************
#pragma mark - AV Stuff
//*********************************************************
//*********************************************************

- (void)setupRecorder
{
    // Doesnt save the audio, throws it away
    NSURL *url = [NSURL fileURLWithPath:@"/dev/null"];
    
    NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithFloat:24000.0],                 AVSampleRateKey,
                              [NSNumber numberWithInt:kAudioFormatAppleLossless], AVFormatIDKey,
                              [NSNumber numberWithInt:1],                         AVNumberOfChannelsKey,
                              [NSNumber numberWithInt:AVAudioQualityHigh],        AVEncoderAudioQualityKey,
                              nil];
    NSError* error;
    self.recorder = [[AVAudioRecorder alloc] initWithURL:url settings:settings error:&error];
    if (error)
        NSLog(@"setup recorder error: %@", error);
    self.recorder.delegate = self;
}


// Captures an image, adds that image to the table in view, and saves it to the library
- (void)captureNow
{
    self.cameraIsReady = NO;
    if(self.flashMode == FLASH_MODE_ON) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self changeTorchMode:AVCaptureTorchModeOn];
            sleep(1.0); // TODO -- get rid of this somehow, it delays the taking of the picture
            // which is not wanted since it throws off the image taking exactly at the peak
        });
    }
    self.lastTakenTime = [NSDate date];
    if (!self.videoConnection.active || !self.videoConnection.enabled) {
        NSLog(@"Video connection was not active - cannot capture image");
        return;
    }
    [self.imageCapture captureStillImageAsynchronouslyFromConnection:self.videoConnection
                                                   completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError *error) {
        if (error)
            NSLog(@"capture now error: %@", error);
        self.cameraIsReady = YES;
        if(!CMSampleBufferIsValid(imageSampleBuffer) || !CMSampleBufferDataIsReady(imageSampleBuffer)) {
            // the buffer is not ready to capture the image and would crash
            // Reset the time so it doesnt wait to take another picture
            self.lastTakenTime = [NSDate distantPast];
            return;
        }
                                                       

        NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
        //UIImageWriteToSavedPhotosAlbum([UIImage imageWithData:imageData], nil, nil, nil);
        [self.imageManager addImageData:imageData save:YES];
        self.numPictures++;
        self.imagesTakenThisMinute++;
        dispatch_async(dispatch_get_main_queue(), ^{
            //[self.table reloadRowsAtIndexPaths:[self.table visibleCells] withRowAnimation:UITableViewRowAnimationAutomatic];
            NSIndexPath* path = [NSIndexPath indexPathForRow:0 inSection:0];
            [self.table insertRowsAtIndexPaths:[NSArray arrayWithObject:path] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self changeTorchMode:AVCaptureTorchModeOff];
        });
        NSLog(@"CAPTURING: %i",self.numPictures);
        self.videoConnection = nil;
        [TestFlight passCheckpoint:@"Captured Imaged"];
    }];
}


//*********************************************************
//*********************************************************
#pragma mark - Timer
//*********************************************************
//*********************************************************


// Called by self.timer and checks if it is loud enough for a picture to be taken
// Takes the function to take a picture if that is the case
- (void)levelTimerCallback:(NSTimer *)timer {
    
    [self.recorder updateMeters];
    float peak = [self.recorder peakPowerForChannel:0];
    self.totalPeak += peak;
    self.timeIntervals++;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.levelLabel.text = @"";//[NSString stringWithFormat:@"Level: %f Max: %i", peak, self.volumeMax];
    });
    if([self allowedToCapturePeak:peak]) {
        [self captureNow];
    }
}

// Given the current volume peak it says if a picture should be taken
- (BOOL)allowedToCapturePeak:(float)peak
{
    return     peak >= self.volumeMax /*|| peak <= self.volumeMin -- add this to capture images when the volume decresses a lot*/
            && self.cameraIsReady
            && [self.lastTakenTime timeIntervalSinceNow] < SECONDS_BETWEEN_IMAGES
            && ![self.timedPicture isValid]
            && self.session.running
            && self.recorder.recording
    && self.imagesTakenThisMinute < MAX_PICTURES_PER_MINUTE;
}

// Action for self.updateTimer
// Updates the max and cushion based on the average peak
// And starts the appropriate timer if it is not running
// It will start the timedPicture timer if it is too loud to rely on the volume
// It will start updateTimer so that timer can function
- (void)monitorVolume
{
    double avgPeak = self.totalPeak/self.timeIntervals;
    // If the average volume is very close to 0 set up a timer for a timed shot and stop the regular timer
    if(avgPeak > TIMED_SHOT_LEVEL) {
        if(![self.timedPicture isValid]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.timedPicture = [NSTimer scheduledTimerWithTimeInterval:TOO_LOUD_TIMED_SHOT_INTERVAL target:self selector:@selector(captureIfTimerIsValid) userInfo:nil repeats:YES];
            });
        }
    } else {//stop the timed shot timer
        [self.timedPicture invalidate];
    }
    
    double peakDiff = self.averageUpdatePeak - avgPeak;
    [self monitorThreshold:peakDiff];
}

// the difference in the current average peak and the current peak for the past
- (void)monitorThreshold:(double)peakDiff
{
    // If the average is too far away decrease the threshold
    // If the average is louder than the cushion from the threshold increase the threshold
    //NSLog(@"\nthe peak diff: %f\naverage update: %f\nmax volume: %i", peakDiff, self.averageUpdatePeak, self.volumeMax);
    bool update = YES;
    int diffNum = 0;
    if(peakDiff > PEAK_DIFFERENCE) {
        diffNum = -1 * ADJUST_NUM;
    } else if(peakDiff < 0) {
        diffNum = ADJUST_NUM;
    } else {
        update = NO;
    }
    self.totalPeak = 0;
    self.timeIntervals = 0;
    
    if(update) {
        [self adjustMetersWithNum:diffNum];
    }
    
    // used to monitor images taken per minute
    self.updateTimerActionCount++;
    if(self.updateTimerActionCount >= MINUTE) {
        self.updateTimerActionCount = 0;
        self.imagesTakenThisMinute = 0;
    }

}

// Only capture if the average volume is greater than what is designated as too loud (TIMED_SHOT_LEVEL)
- (void)captureIfTimerIsValid
{
    double avgPeak = self.totalPeak/self.timeIntervals;
    if(avgPeak > TIMED_SHOT_LEVEL) {
        NSLog(@"timed capture!");
        [self captureNow];
        self.volumeMax = 0;
    } else {
        [self.timedPicture invalidate];
    }
}

//*********************************************************
//*********************************************************
#pragma mark - Monitoring
//*********************************************************
//*********************************************************

- (void)adjustMetersWithNum:(double)diff
{
    if([self.updateTimer isValid]) {
        self.volumeMax += diff;
    }
}

//*********************************************************
//*********************************************************
#pragma mark - Table View Delegate/Datasource
//*********************************************************
//*********************************************************

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* cellID = @"imageCellPolaroid";
    ImageCell* cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if(cell == nil) {
        cell = [ImageCell createImageCellWithTable:self.table];
        cell.delegate = self;
    }
        
    // add the images to the table in reverse order and limit to 10
    // hopefully that will stop the app from crashing as much
    [cell addImage:[self.imageManager getImageAtIndex:[self.imageManager count] - indexPath.row - 1]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.imageManager count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // DONT DO SHIT!
}

//*********************************************************
//*********************************************************
#pragma mark - Image Cell Delegate
//*********************************************************
//*********************************************************

- (void)shouldSaveImageFromCell:(ImageCell*)imgCell {
    [TestFlight passCheckpoint:@"Saved Imaged"];
    [self removeImageFromCell:imgCell shouldSave:YES];
}

- (void)shouldDeleteImageFromCell:(ImageCell*)imgCell {
    [TestFlight passCheckpoint:@"Deleted Imaged"];
    [self removeImageFromCell:imgCell shouldSave:NO];
}

- (void)removeImageFromCell:(ImageCell*)imgCell shouldSave:(BOOL)save {
    NSIndexPath* path = [self.table indexPathForCell:imgCell];
    unsigned int imgIndex = [self.imageManager count] - path.row - 1;
    
    if(save) {
        [self.imageManager saveImages:[NSArray arrayWithObject:[[self.imageManager getImageDataAtIndex:imgIndex] copy]]];
    }
    [self.imageManager removeImagesAtIndices:[NSArray arrayWithObject:@(imgIndex)]];
    
    //[self.table reloadData];
    [self.table deleteRowsAtIndexPaths:[NSArray arrayWithObject:path] withRowAnimation:UITableViewRowAnimationAutomatic];
    self.numPictures = [self.imageManager count];
}

- (void)deleteImageFromAlertView {
    // the delete swipe should show a button or open an alert view
    // before they delete the image
}

//*********************************************************
//*********************************************************
#pragma mark - IBActions
//*********************************************************
//*********************************************************


- (IBAction)toggleRecording:(id)sender {
    if(self.session.running && self.recorder.recording) {
        [self stopEverythingWithStatusAnimation:YES];
    } else {
        [self startEverything];
    }
}

- (IBAction)stopEverythingWithStatusAnimation:(BOOL)statusAnimation {
    if (statusAnimation)
        [self showBottomNotification:@"Stopping..."];
    [self stopEverything];
}

- (IBAction)stopEverything {
    NSLog(@"stop everything!");
    //[[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
    // using time interval since now will return negative since self.sessionTime is earlier than the current time
    self.sessionTimeInterval += ([self.sessionTime timeIntervalSinceNow] * -1);
    [self.timer invalidate];
    [self.updateTimer invalidate];
    [self.recorder stop];
    [self.session stopRunning];
    self.session = nil;
    self.camDevice = nil;
    self.camInput  = nil;
    //self.levelLabel.text = @"Not Running";
    self.isRunning = NO;
    [self updateUI];
    UIImage* button_image = [UIImage imageNamed:@"cameraButton.png"];
    [self.cameraButton setBackgroundImage:button_image forState:UIControlStateNormal];
    [self.hideButton setBackgroundImage:button_image forState:UIControlStateNormal];
    [self.clearButton setBackgroundImage:button_image forState:UIControlStateNormal];
}

- (IBAction)startEverything
{
    [self showBottomNotification:@"Running..."];
    self.volumeMax = -5;
    // the camera needs time to warm up so this stops black pictures from being taken
    self.lastTakenTime = [NSDate date];
    [self.recorder record];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:MAIN_TIMER_REPEAT_TIME target:self selector:@selector(levelTimerCallback:) userInfo:nil repeats:YES];
    self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:UPDATE_TIME target:self selector:@selector(monitorVolume) userInfo:nil repeats:YES];
    [self.session startRunning];
    self.isRunning = YES;
    [self updateUI];
    self.sessionTime = [NSDate date];
    UIImage* button_image = [UIImage imageNamed:@"cameraButtonGreen.png"];
    [self.cameraButton setBackgroundImage:button_image forState:UIControlStateNormal];
    [self.hideButton setBackgroundImage:button_image forState:UIControlStateNormal];
    [self.clearButton setBackgroundImage:button_image forState:UIControlStateNormal];
}

- (void)showBottomNotification:(NSString*)msg {
    [self.notifier setText:msg];
    [self.notifierTimer invalidate];
    if (self.notifier.center.y > [KandidUtils screenHeight]) {  // Offscreen.
        int new_y = [KandidUtils screenHeight] - NOTIFIER_HEIGHT/2;
        CGPoint new_center = CGPointMake([KandidUtils screenWidth]/2, new_y);
        [UIView animateWithDuration:0.5 animations:^{
            self.notifier.center = new_center;
        } completion:^(BOOL finished) {
            self.notifierTimer = [NSTimer scheduledTimerWithTimeInterval:0.75 target:self selector:@selector(removeNotifierFromScreen) userInfo:nil repeats:NO];
        }];
    } else {
        self.notifierTimer = [NSTimer scheduledTimerWithTimeInterval:0.75 target:self selector:@selector(removeNotifierFromScreen) userInfo:nil repeats:NO];
    }
}

- (void)removeNotifierFromScreen {
    [UIView animateWithDuration:1 animations:^{
        self.notifier.center = CGPointMake([KandidUtils screenWidth]/2, [KandidUtils screenHeight] + NOTIFIER_HEIGHT/2);
    }];
}

- (IBAction)toggleHide:(id)sender
{
    if(self.hideView.hidden) {
        if(self.isRunning) {
//            NSLog(@"Turing proximity monitor back on");
            //[[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
        }
        [self navigationController].navigationBar.alpha = 0;
        // make it repeat so it is still valid in the body of the selector
        [self showBottomNotification:@"Hiding..."];
        self.hideTimer = [NSTimer scheduledTimerWithTimeInterval:1.2 target:self selector:@selector(hideLabels) userInfo:nil repeats:YES];
        self.hideView.hidden = NO;
    } else {
        [self showHiddenLabels];
        // put the labels back on. no animation since it happens in the background
    }
}

- (void)hideLabels
{
    self.hideView.userInteractionEnabled = NO;
    
    [UIView animateWithDuration:0.5 animations:^{
        self.hideLabel.alpha = 0;
        // TODO -- change these to ZERO
        self.numPixHiddenLabel.alpha = 0.25;
        self.volumeHideLabel.alpha = 0.25;
        self.hideView.alpha = 1;
    } completion:^(BOOL finished) {
        self.hideLabel.hidden = YES;
        if([self.hideTimer isValid]) {
            [self.hideTimer invalidate];
            [[UIScreen mainScreen] setBrightness:0];
        }
        self.hideView.userInteractionEnabled = YES;
        //self.numPixHiddenLabel.hidden = YES;
        //self.volumeHideLabel.hidden = YES;
    }];
}

- (IBAction)showHiddenLabels
{
    if(self.isRunning) {
//        NSLog(@"Turing proximity monitor back on");
        //[[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
    }
    [self navigationController].navigationBar.alpha = 1;
    [self.hideTimer invalidate];
    self.hideView.hidden = YES;
    self.hideView.alpha = 0.9;
    self.numPixHiddenLabel.alpha = 1;
    self.volumeHideLabel.alpha = 1;
    self.hideLabel.alpha = 1;
    self.hideLabel.hidden = NO;
    self.numPixHiddenLabel.hidden = NO;
    self.volumeHideLabel.hidden = NO;
    [[UIScreen mainScreen] setBrightness:self.previousBrightness];
}

- (IBAction)clearFilmRoll:(id)sender
{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:CLEAR_ALERT_TITLE message:@"The image roll will be cleared" delegate:self cancelButtonTitle:@"Nevermind" otherButtonTitles:@"Clear!", nil];
    [alert show];
}

- (IBAction)toggleFlashMode:(id)sender
{
    self.flashMode++;
    switch (self.flashMode) {
        case FLASH_MODE_ON:
            [self.flashButton setImage:[UIImage imageNamed:@"flashOn.png"] forState:UIControlStateNormal];
            break;
        case FLASH_MODE_OFF:
            [self.flashButton setImage:[UIImage imageNamed:@"flashOff.png"] forState:UIControlStateNormal];
            break;
        default:
            [self.flashButton setTitle:@"DEFAULT, WHAT???" forState:UIControlStateNormal];
            break;
    }
}

- (IBAction)showSettings:(id)sender
{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Uh Oh!" message:@"Got lazy and didn't do this part yet" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alert show];
}

// show selection of the images for the user to choose from
- (IBAction)saveImages:(id)sender
{
    /*
    if([self.imageManager count] == 0) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Nothing to save" message:@"Please try again once there are images" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    } else {
        ImageSelectionViewController* isvc = [self.storyboard instantiateViewControllerWithIdentifier:@"selectionView"];
        isvc.imageManager = self.imageManager;
        isvc.delegate = self;
        [isvc loadView];
        [isvc viewDidLoad];
        [ViewController setViewController:isvc Title:@"Images" Font:[UIFont fontWithName:@"Didot-Italic" size:28]];
        [self presentModalViewController:isvc animated:YES];
    }
     */
}



//*********************************************************
//*********************************************************
#pragma mark - Miscellaneous
//*********************************************************
//*********************************************************


//clears the images but keeps the data
//when access images from the manager it
//will recreate deleted images from the data
- (void)didReceiveMemoryWarning
{
    self.table.userInteractionEnabled = NO;
    [self.imageManager conserveMemory];
    [self.table reloadData];
    self.videoConnection = NULL;
    self.table.userInteractionEnabled = YES;
}

- (void)toggleFlash
{
    if(self.camDevice.torchActive) {
        [self changeTorchMode:AVCaptureTorchModeOff];
    } else {
        [self changeTorchMode:AVCaptureTorchModeOn];
    }
}

- (void)changeTorchMode:(AVCaptureTorchMode)mode
{
    [self.session beginConfiguration];
    [self.camDevice lockForConfiguration:nil];
    [self.camDevice setTorchMode:mode];
    [self.camDevice unlockForConfiguration];
    [self.session commitConfiguration];
}

// called when the app is going to terminate to save necessary information
- (void)appWillTerminate
{
    [self showHiddenLabels];
    [self.imageManager writeInfoToFileName:@"kandid"];
}

- (void)shouldPresentTutorial {
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"hasSeenTutorialDev"]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasSeenTutorialDev"];
        [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(showTutorial) userInfo:nil repeats:NO];
    }
}

- (void)showTutorial {
    [self presentModalViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"TutorialVC"] animated:YES];
}

// the message that the overlay should show
// either returns a string that should be passed as the overlay's message
// or nil is returned in which case an empty finish message message should
// be posted and return to the regular status bar
- (NSString*)getStatusBarMessage {
    NSString* msg = nil;
    if(!self.hideView.hidden)
        msg = @"   ";
    if([self.imageManager isSavingImages])
        msg = @"Saving Images...";
    else if(self.isRunning)
        msg = @"Running...";
    return msg;
}

//*********************************************************
//*********************************************************
#pragma mark - Interruption Handling
//*********************************************************
//*********************************************************

- (void)beginInterruption
{
//    NSLog(@"beginInterruption");
    self.shouldResumeAfterInterruption = self.isRunning;
    if(self.isRunning) {
        //[self stopEverythingWithStatusAnimation:NO];
    }
}

- (void)inputIsAvailableChanged:(BOOL)isInputAvailable
{
    if(!isInputAvailable) {
        [self stopEverythingWithStatusAnimation:YES];
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Input Error" message:@"Not available" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

- (void)endInterruption
{
    if(self.shouldResumeAfterInterruption) {
        [self startEverything];
        self.shouldResumeAfterInterruption = NO;
    }
    [self updateUI];
}

//*********************************************************
//*********************************************************
#pragma mark - Misc Delegate
//*********************************************************
//*********************************************************

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if([alertView.title isEqualToString:CLEAR_ALERT_TITLE] && buttonIndex == ClearAlertViewIndexClear) {
        self.sessionTimeInterval = 0;
        [self.imageManager clearImageData];
        [self.table reloadData];
        self.numPictures = 0;
        [TestFlight passCheckpoint:@"Cleared Film Roll"];
    } else if([alertView.title isEqualToString:REVIEW_ALERT_TITLE] && buttonIndex == ReviewAlertIndexYes) {
        NSURL *url = [NSURL URLWithString:KANDID_ITUNES_URL];
        [[UIApplication sharedApplication] openURL:url];
    }
}

- (void)didFinishSelection {
    [self dismissModalViewControllerAnimated:YES];
    [self updateUI];
}



//*********************************************************
//*********************************************************
#pragma mark - Setters/Getters
//*********************************************************
//*********************************************************

- (BOOL)isRunning {
    return [self.recorder isRecording] && [self.session isRunning];
}

- (NSDate*)lastTakenTime
{
    if(!_lastTakenTime) {
        _lastTakenTime = [NSDate date];
    }
    return _lastTakenTime;
}

- (AVCaptureSession*)session
{
    if(!_session) {
        _session = [[AVCaptureSession alloc] init];
        _session.sessionPreset = AVCaptureSessionPresetPhoto;
        [_session addInput:self.camInput];
        [_session addOutput:self.imageCapture];
    }
    return _session;
}

- (AVCaptureStillImageOutput*)imageCapture
{
    if(!_imageCapture) {
        _imageCapture = [[AVCaptureStillImageOutput alloc] init];
        NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG,AVVideoCodecKey,nil];
        [_imageCapture setOutputSettings:outputSettings];
    }
    return _imageCapture;
}

- (AVCaptureDeviceInput*)camInput
{
    if(!_camInput) {
        NSError* error;
        _camInput = [AVCaptureDeviceInput deviceInputWithDevice:self.camDevice error:&error];
        if (error)
            NSLog(@"camINput Error: %@", error);
    }
    return _camInput;
}

- (AVCaptureDevice*)camDevice
{
    if(!_camDevice) {
        _camDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        [_camDevice lockForConfiguration:nil];
        [_camDevice setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
        [_camDevice unlockForConfiguration];
    }
    return _camDevice;
}

- (AVAudioRecorder*)recorder
{
    if(!_recorder) {
        // The next three lines allowed this to run on iOS 7
        // Found at: https://devforums.apple.com/message/858424#858424
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession setActive: YES error: nil];
        [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryRecord error: nil];
        [self setupRecorder];
    }
    return _recorder;
}

- (int)numPictures
{
    if(!_numPictures) {
        _numPictures = 0;
    }
    return _numPictures;
}

- (void)setNumPictures:(int)numPictures
{
    _numPictures = numPictures;
}

- (double)totalPeak
{
    if(!_totalPeak) {
        _totalPeak = 0.0;
    }
    return _totalPeak;
}

- (double)timeIntervals
{
    if(!_timeIntervals) {
        _timeIntervals = 0;
    }
    return _timeIntervals;
}

- (int)volumeMax
{
    if(!_volumeMax) {
        _volumeMax = -5;
    }
    return _volumeMax;
}

- (void)setVolumeMax:(int)volumeMax
{
    if(volumeMax > 0)
        _volumeMax = 0;
    else if(volumeMax < VOLUME_MIN)
        _volumeMax = VOLUME_MIN;
    else
        _volumeMax = volumeMax;
}

- (double)averageUpdatePeak {
    return self.volumeMax - VOLUME_CUSHION;
}

// if the max is VOLUME_CUSHION LESS THAN THE AVERAGE
// than the min should be max - 2*VOLUME_CUSHION
- (int)volumeMin {
    return self.volumeMax - (2 * VOLUME_CUSHION) - 5;
}

- (NSTimer*)timedPicture
{
    if(!_timedPicture) {
        _timedPicture = [[NSTimer alloc] init];
        [_timedPicture invalidate];
    }
    return _timedPicture;
}

- (ImageManager*)imageManager
{
    if(!_imageManager) {
        _imageManager = [ImageManager imageManagerWithFileName:@"kandid"];
        [_imageManager setDelegate:self];
    }
    return _imageManager;
}

// bounds check the flash mode
- (void)setFlashMode:(FLASH_MODE)flashMode
{
    if(flashMode > FLASH_MODE_OFF) {
        _flashMode = FLASH_MODE_ON;
    } else if(flashMode < FLASH_MODE_ON) {
        _flashMode = FLASH_MODE_OFF;
    } else {
        _flashMode = flashMode;
    }
}

- (AVCaptureConnection*)videoConnection {
    if(!_videoConnection) {
        for (AVCaptureConnection *connection in self.imageCapture.connections) {
            for (AVCaptureInputPort *port in [connection inputPorts]) {
                if ([[port mediaType] isEqual:AVMediaTypeVideo]){
                    _videoConnection = connection;
                    break;
                }
            }
            if (_videoConnection) {
                break;
            }
        }
    }
    if(_videoConnection)
        [_videoConnection setVideoOrientation:(AVCaptureVideoOrientation)[[UIDevice currentDevice] orientation]];
    return _videoConnection;
}

- (UILabel*)notifier {
    if (!_notifier) {
        _notifier = [[UILabel alloc] initWithFrame:CGRectMake(0, [KandidUtils screenHeight], [KandidUtils screenWidth], NOTIFIER_HEIGHT)];
        _notifier.backgroundColor = [UIColor colorWithWhite:0 alpha:0.75];
        _notifier.textColor = [UIColor whiteColor];
        _notifier.textAlignment = NSTextAlignmentCenter;
        _notifier.font = [UIFont fontWithName:@"Dosis-SemiBold" size:_notifier.font.pointSize];
        [self.view insertSubview:_notifier aboveSubview:self.hideView];
    }
    return _notifier;
}

- (void)didFinishSavingImages {
    NSLog(@"Saved images");
}

+ (AVCaptureVideoOrientation)getCurrentOrientation {
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    AVCaptureVideoOrientation av_orientaion;
    if (orientation == UIDeviceOrientationPortraitUpsideDown) {
        av_orientaion = AVCaptureVideoOrientationPortraitUpsideDown;
    } else if (orientation == UIDeviceOrientationLandscapeLeft) {
        av_orientaion = AVCaptureVideoOrientationLandscapeLeft;
    } else if (orientation == UIDeviceOrientationLandscapeRight) {
        av_orientaion = AVCaptureVideoOrientationLandscapeRight;
    } else {
        av_orientaion = AVCaptureVideoOrientationPortrait;
    }
    return av_orientaion;
}

@end
