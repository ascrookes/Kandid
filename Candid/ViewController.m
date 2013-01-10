//
//  ViewController.m
//  Candid
//
//  Created by Amadou Crookes on 6/23/12.
//  Copyright (c) 2012 Amadou Crookes. All rights reserved.
//

#import "ViewController.h"
#import "ImageSelectionViewController.h"
#import "MTStatusBarOverlay.h"
#import "DatabaseManager.h"


//*********************************************************
//*********************************************************
#pragma mark - Camera Related constants
//*********************************************************
//*********************************************************

const int SECONDS_BETWEEN_IMAGES = -3;
const int PEAK_DIFFERENCE = 5;
const int ADJUST_NUM = 5;
const int UPDATE_TIME = 5;
const int MINUTE = 60/UPDATE_TIME;
const int MAIN_TIMER_REPEAT_TIME = 0.1;
// The cushion above the max to monitor where the max should be
const int VOLUME_CUSHION = 15;
// if the max average is greater than -5 set it too take images on a timer
const int TOO_LOUD_TIMED_SHOT = 10;
const double TIMED_SHOT_LEVEL = -5.5;
const int MAX_PICTURES_PER_MINUTE = 8;
const int VOLUME_MIN = -60; // the minimum the volume limit can get
const int MAX_IMAGES_IN_TABLE = 25;

//*********************************************************
//*********************************************************
#pragma mark - Enums
//*********************************************************
//*********************************************************

// if this changes, also change the setFlashMode function
// so that it bounds check correctly
typedef enum FLASH_MODE {
    FLASH_MODE_ON   = 0,
    FLASH_MODE_OFF  = 1, 
    /*FLASH_MODE_AUTO = 2*/
} FLASH_MODE;

typedef enum ClearAlertViewIndex {
    ClearAlertViewIndexNevermind,
    ClearAlertViewIndexClear
} ClearAlertViewIndex;


@interface ViewController () <UIAlertViewDelegate>

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
@property (nonatomic) FLASH_MODE /*change this to the enum*/ flashMode;
@property (nonatomic) BOOL isRunning;
@property (nonatomic) BOOL shouldResumeAfterInterruption;

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
@synthesize picturesTaken = _picturesTaken;

@synthesize lastTakenTime = _lastTakenTime;
@synthesize numPictures = _numPictures;
@synthesize totalPeak = _totalPeak;
@synthesize timeIntervals = _timeIntervals;
@synthesize averageUpdatePeak = _averageUpdatePeak;
@synthesize updateTimer = _updateTimer;
@synthesize timedPicture = _timedPicture;
@synthesize cameraButton = _cameraButton;
@synthesize table = _table;
@synthesize updateTimerActionCount;
@synthesize hideView = _hideView;
@synthesize picturesTakenThisMinute;
@synthesize startButton = _startButton;
@synthesize hideButton = _hideButton;
@synthesize hideLabel = _hideLabel;
@synthesize numPixHiddenLabel = _numPixHiddenLabel;
@synthesize volumeHideLabel = _volumeHideLabel;
@synthesize hideTimer = _hideTimer;


//*********************************************************
//*********************************************************
#pragma mark - Standard Stuff
//*********************************************************
//*********************************************************

- (void)viewDidLoad
{
    [super viewDidLoad];
    if(!self.recorder.recording) {
        [self.recorder prepareToRecord];
        self.recorder.meteringEnabled = YES;
    }
    
    self.volumeMax = -10.0;
    self.averageUpdatePeak = self.volumeMax - VOLUME_CUSHION;
    self.table.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"FilmRoll.png"]];
    self.table.separatorColor  = [UIColor blackColor];
    self.flashMode = FLASH_MODE_OFF;
    self.isRunning = NO;
    self.shouldResumeAfterInterruption = NO;
    self.orientationArrow.title = @"";
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationNotification) name:UIDeviceOrientationDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopEverything) name:@"stopEverything" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(beginInterruption) name:@"beginInterruption" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(endInterruption) name:@"endInterruption" object:nil];
}

// since the UI does not rotate show something to indicate
// that the camera can face any direction
- (void)deviceOrientationNotification
{
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    switch (orientation) {
        case UIDeviceOrientationPortrait:
            [self.orientationArrow setImage:[UIImage imageNamed:@"up.png"]];
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            [self.orientationArrow setImage:[UIImage imageNamed:@"down.png"]];
            break;
        case UIDeviceOrientationLandscapeLeft:
            [self.orientationArrow setImage:[UIImage imageNamed:@"right.png"]];
            break;
        case UIDeviceOrientationLandscapeRight:
            [self.orientationArrow setImage:[UIImage imageNamed:@"left.png"]];
            break;
        /*
        case UIDeviceOrientationFaceDown:
            NSLog(@"face down");
            break;
        case UIDeviceOrientationFaceUp:
            // maybe turn the camera off if the camera is facing down
            NSLog(@"face up");
            break;
         */
        default:
            break;
    }
}

- (void)viewDidUnload
{
    [self setPicturesTaken:nil];
    [self setCameraButton:nil];
    [self setTable:nil];
    [self setLevelLabel:nil];
    [self setHideView:nil];
    [self setStartButton:nil];
    [self setHideButton:nil];
    [self setFlashButton:nil];
    [self setHideLabel:nil];
    [self setNumPixHiddenLabel:nil];
    [self setVolumeHideLabel:nil];
    [self setNumPixBarButton:nil];
    [self setOrientationArrow:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
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
                              [NSNumber numberWithFloat: 24000.0],                 AVSampleRateKey,
                              [NSNumber numberWithInt: kAudioFormatAppleLossless], AVFormatIDKey,
                              [NSNumber numberWithInt: 1],                         AVNumberOfChannelsKey,
                              [NSNumber numberWithInt: AVAudioQualityHigh],        AVEncoderAudioQualityKey,
                              nil];
    NSError* error;
    self.recorder = [[AVAudioRecorder alloc] initWithURL:url settings:settings error:&error];
    self.recorder.delegate = self;
}


// Captures an image, adds that image to the table in view, and saves it to the library
- (void)captureNow
{
    BOOL useFlash = (self.flashMode == FLASH_MODE_ON);
    if(useFlash) {
        [self changeTorchMode:AVCaptureTorchModeOn];
        sleep(1.0); // TODO -- get rid of this somehow, it delays the taking of the picture
                    // which is not wanted
    }
    self.lastTakenTime = [NSDate date];
    
    [self.imageCapture captureStillImageAsynchronouslyFromConnection:self.videoConnection
                                                   completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError *error) {
        
        if(!CMSampleBufferIsValid(imageSampleBuffer) || !CMSampleBufferDataIsReady(imageSampleBuffer)) {
            // the buffer is not ready to capture the image and would crash
            // Reset the time so it doesnt wait to take another picture
            self.lastTakenTime = [NSDate distantPast];
            return;
        }

        NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
        
        [self.imageManager addImageData:imageData save:YES];
        self.numPictures++;
        self.picturesTakenThisMinute++;
        dispatch_async(dispatch_get_main_queue(), ^{
            //[self.table reloadRowsAtIndexPaths:[self.table visibleCells] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.table reloadData];
            self.picturesTaken.text = [NSString stringWithFormat:@"%i", self.numPictures];
            [self changeTorchMode:AVCaptureTorchModeOff];
        });
        NSLog(@"CAPTURING: %i",self.numPictures);
    }];
    [DatabaseManager addImageToDB];
}


//*********************************************************
//*********************************************************
#pragma mark - Timer
//*********************************************************
//*********************************************************


// Called by self.timer and checks if it is loud enough for a picture to be taken
// Takes the function to take a picture if that is the case
- (void)levelTimerCallback:(NSTimer *)timer
{
	[self.recorder updateMeters];
    float peak = [self.recorder peakPowerForChannel:0];
    self.totalPeak += peak;
    self.timeIntervals++;
    self.levelLabel.text = [NSString stringWithFormat:@"Level: %f Max: %i", peak, self.volumeMax];
    if([self allowedToCapturePeak:peak]) {
        [self captureNow];
    }
}

// Given the current volume peak it says if a picture should be taken
- (BOOL)allowedToCapturePeak:(float)peak
{
    return     peak >= self.volumeMax /*|| peak <= self.volumeMin -- add this to capture images when the volume decresses a lot*/
            && [self.lastTakenTime timeIntervalSinceNow] < SECONDS_BETWEEN_IMAGES
            && ![self.timedPicture isValid]
            && self.session.running
            && self.recorder.recording;
            //&& self.picturesTakenThisMinute <= MAX_PICTURES_PER_MINUTE;
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
            self.timedPicture = [NSTimer scheduledTimerWithTimeInterval:TOO_LOUD_TIMED_SHOT target:self selector:@selector(captureIfTimerIsValid) userInfo:nil repeats:YES];
        }
    // Else stop the timed shot timer
    } else {
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
        self.picturesTakenThisMinute = 0;
        self.updateTimerActionCount = 0;
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
        self.averageUpdatePeak += diff;
    }
}

//*********************************************************
//*********************************************************
#pragma mark - Table View Delegate/Datasource
//*********************************************************
//*********************************************************


- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* cellID = @"Image Cell Polaroid";
    ImageCell* cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if(cell == nil) {
        cell = [[ImageCell alloc] init];
    }
    // add the images to the table in reverse order and limit to 10
    // hopefully that will stop the app from crashing as much
    [cell addImage:[self.imageManager getImageAtIndex:[self.imageManager count] - indexPath.row - 1]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int count = [self.imageManager count];
    return (count < MAX_IMAGES_IN_TABLE) ? count : MAX_IMAGES_IN_TABLE;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // DONT DO SHIT
}

//*********************************************************
//*********************************************************
#pragma mark - IBActions
//*********************************************************
//*********************************************************


- (IBAction)toggleRecording:(id)sender 
{
    if(self.session.running && self.recorder.recording) {
        [self stopEverythingWithStatusAnimation:YES];
    } else {
        [self startEverything];
    }
}

- (IBAction)stopEverythingWithStatusAnimation:(BOOL)statusAnimation
{
    [self stopEverything];
    NSString* finishMsg = (statusAnimation) ? @"Stopping..." : @" ";
    MTStatusBarOverlay *overlay = [MTStatusBarOverlay sharedInstance];
    [overlay postImmediateFinishMessage:finishMsg duration:1.5 animated:YES];
    overlay.progress = 1.0;
}

- (IBAction)stopEverything
{
    [self.timer invalidate];
    [self.updateTimer invalidate];
    [self.recorder stop];
    [self.session stopRunning];
    self.camDevice = nil;
    self.camInput  = nil;
    [self.startButton setImage:[UIImage imageNamed:@"cameraStart.png"] forState:UIControlStateNormal];
    self.levelLabel.text = @"Not Running";
    self.isRunning = NO;

}

- (IBAction)startEverything
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"test-observer" object:nil];
    // the camera needs time to warm up so this stops black pictures from being taken
    self.lastTakenTime = [NSDate date];
    [self.recorder record];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:MAIN_TIMER_REPEAT_TIME target:self selector:@selector(levelTimerCallback:) userInfo:nil repeats:YES];
    self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:UPDATE_TIME target:self selector:@selector(monitorVolume) userInfo:nil repeats:YES];
    [self.session startRunning];
    [self.startButton setImage:[UIImage imageNamed:@"cameraStop.png"] forState:UIControlStateNormal];
    self.isRunning = YES;
    MTStatusBarOverlay *overlay = [MTStatusBarOverlay sharedInstance];
    overlay.hidesActivity = YES;
    overlay.animation = MTStatusBarOverlayAnimationFallDown;
    overlay.detailViewMode = MTDetailViewModeHistory;
    [overlay postMessage:@"Running..."];
}

- (IBAction)toggleHide:(id)sender
{
    if(self.hideView.hidden) {
        [self navigationController].navigationBar.alpha = 0;
        self.hideTimer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(hideLabels) userInfo:nil repeats:NO];
        self.hideView.hidden = NO;
        
        // fade the labels on the view
    } else {
        [self navigationController].navigationBar.alpha = 1;
        [self.hideTimer invalidate];
        self.hideView.hidden = YES;
        [self showHiddenLabels];
        // put the labels back on. no animation since it happens in the background
    }
}

- (void)hideLabels
{
    [UIView animateWithDuration:1.25 animations:^{
        self.hideLabel.alpha = 0;
        // TODO -- change these to ZERO
        self.numPixHiddenLabel.alpha = 0.25;
        self.volumeHideLabel.alpha = 0.25;
        self.hideView.alpha = 1;
    } completion:^(BOOL finished) {
        self.hideLabel.hidden = YES;
        //self.numPixHiddenLabel.hidden = YES;
        //self.volumeHideLabel.hidden = YES;
    }];
}

- (void)showHiddenLabels
{
    self.hideView.alpha = 0.9;
    self.numPixHiddenLabel.alpha = 1;
    self.volumeHideLabel.alpha = 1;
    self.hideLabel.alpha = 1;
    self.hideLabel.hidden = NO;
    self.numPixHiddenLabel.hidden = NO;
    self.volumeHideLabel.hidden = NO;
}

- (IBAction)clearFilmRoll:(id)sender
{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Are You Sure?" message:@"Images will disappear but have already been saved" delegate:self cancelButtonTitle:@"Nevermind" otherButtonTitles:@"Clear!", nil];
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
    NSLog(@"Should show the settings");
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Uh Oh!" message:@"Got lazy and didn't do this part yet" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alert show];
}

- (IBAction)showSelction:(id)sender
{
    if([self.imageManager count] == 0) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"No images" message:@"Please try again once there are images" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    } else {
        ImageSelectionViewController* isvc = [self.storyboard instantiateViewControllerWithIdentifier:@"selectionView"];
        isvc.imageManager = self.imageManager;
        [self presentModalViewController:isvc animated:YES];
    }
    
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
    NSLog(@"Memory warning :(");
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

//*********************************************************
//*********************************************************
#pragma mark - AVAudioSessionDelegate
//*********************************************************
//*********************************************************

- (void)beginInterruption
{
    self.shouldResumeAfterInterruption = self.isRunning;
    if(self.isRunning) {
        [self stopEverythingWithStatusAnimation:NO];
    }
}

- (void)inputIsAvailableChanged:(BOOL)isInputAvailable
{
    NSLog(@"Input Is Available Changed: %d", isInputAvailable);
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
}

//*********************************************************
//*********************************************************
#pragma mark - Alert View Delegate
//*********************************************************
//*********************************************************

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == ClearAlertViewIndexClear) {
        [DatabaseManager addImageSessionToDBWithSessionCount:self.numPictures];
        [self.imageManager clearImageData];
        [self.table reloadData];
        self.numPictures = 0;
        self.picturesTaken.text = [NSString stringWithFormat:@"%i", self.numPictures];
    }
}



//*********************************************************
//*********************************************************
#pragma mark - Setters
//*********************************************************
//*********************************************************

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
        _camInput = [AVCaptureDeviceInput deviceInputWithDevice:self.camDevice error:nil];
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
        [self setupRecorder];
    }
    
    return _recorder;
}

- (int)numPictures
{
    if(!_numPictures) {
        _numPictures = 0;
    }
    if(_numPictures == 5) {
        [self didReceiveMemoryWarning];
    }
    self.numPixBarButton.title = [NSString stringWithFormat:@"# Pix: %i", _numPictures];
    return _numPictures;
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

- (double)averageUpdatePeak
{
    if(!_averageUpdatePeak) {
        _averageUpdatePeak = 0;
    }
    return _averageUpdatePeak;
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

// if the max is VOLUME_CUSHION LESS THAN THE AVERAGE
// than the min should be max - 2*VOLUME_CUSHION
- (int)volumeMin
{
    return self.volumeMax - (2 * VOLUME_CUSHION) - 5;
}

- (void)setAverageUpdatePeak:(double)averageUpdatePeak
{
    _averageUpdatePeak = (averageUpdatePeak > 0) ? 0 : averageUpdatePeak;
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
        _imageManager = [[ImageManager alloc] init];
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
        [_videoConnection setVideoOrientation:[[UIDevice currentDevice] orientation]];
    
    return _videoConnection;
}


@end
