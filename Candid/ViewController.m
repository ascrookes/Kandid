//
//  ViewController.m
//  Candid
//
//  Created by Amadou Crookes on 6/23/12.
//  Copyright (c) 2012 Amadou Crookes. All rights reserved.
//

#import "ViewController.h"


//*********************************************************
//*********************************************************
#pragma mark - Camera constants
//*********************************************************
//*********************************************************
const int SECONDS_BETWEEN_IMAGES = -8;
const int PEAK_DIFFERENCE = 5;
const int ADJUST_NUM = 5;
const int UPDATE_TIME = 5;
const int MINUTE = 60/UPDATE_TIME;
// The cushion above the max to monitor where the max should be
const int MAX_CUSHION = 15;
// if the max average is greater than -5 set it too take images on a timer
const int TOO_LOUD_TIMED_SHOT = 30;
const int TIMED_SHOT_LEVEL = -7;
const int MAX_PICTURES_PER_MINUTE = 5;
const int BUTTON_WIDTH = 160;


//*********************************************************
//*********************************************************
#pragma mark - UI constants
//*********************************************************
//*********************************************************
const int TABLE_WIDTH   = 300;
const int TABLE_DELTA_X = 10;
const int START_BUTTON_HEIGHT = 65;

@interface ViewController ()

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
@property (nonatomic) int numPictures;

@end


@implementation ViewController
@synthesize levelLabel = _levelLabel;

@synthesize recorder = _recorder;
@synthesize timer = _timer;

@synthesize imageCapture = _imageCapture;
@synthesize camInput = _camInput;
@synthesize camDevice = _camDevice;
@synthesize session = _session;

@synthesize imageManager = _imageManager;

@synthesize volumeMax = _volumeMax;
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


//*********************************************************
//*********************************************************
#pragma mark - Standard Stuff
//*********************************************************
//*********************************************************

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.startButton setImage:[UIImage imageNamed:@"startButton.png"] forState:UIControlStateNormal];
    [self.hideButton  setImage:[UIImage imageNamed:@"hideButton.png"]  forState:UIControlStateNormal];
    
    if(!self.recorder.recording) {
        [self.recorder prepareToRecord];
        self.recorder.meteringEnabled = YES;
    }    
    self.volumeMax = -5.0;
    self.averageUpdatePeak = self.volumeMax - MAX_CUSHION;
    self.table.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"FilmRoll.png"]];
    self.table.separatorColor  = [UIColor blackColor];
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

/*
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [UIView setAnimationsEnabled:YES];
}




- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    // This is set to rotate against the screens rotation
    // Thus giving the appereance of whatever this is applied does not move
    CGAffineTransform antiRotate;
    switch (toInterfaceOrientation) {
        case UIInterfaceOrientationLandscapeLeft:
            antiRotate = CGAffineTransformMakeRotation(M_PI_2); // 90 degress
            break;
        case UIInterfaceOrientationLandscapeRight:
            antiRotate = CGAffineTransformMakeRotation(M_PI + M_PI_2); // 270 degrees
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            antiRotate = CGAffineTransformMakeRotation(M_PI); // 180 degrees
            break;
        default:
            antiRotate = CGAffineTransformMakeRotation(0.0);
            break;
    }
    self.cameraButton.transform  = antiRotate;
    self.table.transform         = antiRotate;
    self.hideView.transform      = antiRotate;
    self.startButton.transform   = antiRotate;
}


//Moves the items on screen (silently
- (void)setUIBasedOnOrientation:(UIInterfaceOrientation)orientation
{
    CGRect tableFrame;
    CGRect hideViewFrame;
    CGRect startButton;
    switch (orientation) {
        case UIInterfaceOrientationLandscapeRight:
            tableFrame = CGRectMake(0, TABLE_DELTA_X, 480-START_BUTTON_HEIGHT, TABLE_WIDTH);
            hideViewFrame = CGRectMake(0, 0, 480, 320);
            startButton = CGRectMake(480-START_BUTTON_HEIGHT, 0, START_BUTTON_HEIGHT, 320);
            break;
        case UIInterfaceOrientationLandscapeLeft:
            tableFrame = CGRectMake(START_BUTTON_HEIGHT, TABLE_DELTA_X, 480-START_BUTTON_HEIGHT, TABLE_WIDTH);
            hideViewFrame = CGRectMake(0, 0, 480, 320);
            startButton = CGRectMake(0, 0, START_BUTTON_HEIGHT, 320);
            break;
        case UIInterfaceOrientationPortrait:
            tableFrame = CGRectMake(TABLE_DELTA_X, 0, TABLE_WIDTH, 480-START_BUTTON_HEIGHT);
            hideViewFrame = CGRectMake(0, 0, 320, 480);
            startButton = CGRectMake(0, 480-START_BUTTON_HEIGHT, 320, START_BUTTON_HEIGHT);
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            tableFrame = CGRectMake(TABLE_DELTA_X, START_BUTTON_HEIGHT, TABLE_WIDTH, 480-START_BUTTON_HEIGHT);
            hideViewFrame = CGRectMake(0, 0, 320, 480);
            startButton = CGRectMake(0, 0, 320, START_BUTTON_HEIGHT);
            break;
        default:
            NSLog(@"WTF MAN!!!!!!!!!!!");
            break;
    }
    self.table.frame = tableFrame;
    self.hideView.frame = hideViewFrame;
    self.startButton.frame = startButton;
}
*/



//*********************************************************
//*********************************************************
#pragma mark - AV Stuff
//*********************************************************
//*********************************************************

- (void)setupRecorder
{
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


- (void)captureNow
{
    self.lastTakenTime = [NSDate date];
    AVCaptureConnection *videoConnection = nil;
    for (AVCaptureConnection *connection in self.imageCapture.connections){
        for (AVCaptureInputPort *port in [connection inputPorts]){
            
            if ([[port mediaType] isEqual:AVMediaTypeVideo]){
                
                videoConnection = connection;
                break;
            }
        }
        if (videoConnection) { 
            break; 
        }
    }
    if(videoConnection) {
        [videoConnection setVideoOrientation:[[UIDevice currentDevice] orientation]];
    }
    [self.imageCapture captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError *error) {
        //NSLog(@"CAPTURING");
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
            [self.table reloadData];
            self.picturesTaken.text = [NSString stringWithFormat:@"%i", self.numPictures];
        });
    }];
}


//*********************************************************
//*********************************************************
#pragma mark - Timer
//*********************************************************
//*********************************************************

//Action for self.timer
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

- (BOOL)allowedToCapturePeak:(float)peak
{
    return  peak >= self.volumeMax &&
            [self.lastTakenTime timeIntervalSinceNow] < SECONDS_BETWEEN_IMAGES &&
            ![self.timedPicture isValid]
            && self.session.running
            && self.recorder.recording
            && self.picturesTakenThisMinute < MAX_PICTURES_PER_MINUTE;
}

//Action for self.updateTimer
- (void)monitorVolume
{
    bool update = YES;
    double avgPeak = self.totalPeak/self.timeIntervals;
    // If the average volume is very close to 0 set up a timer for a timed shot and stop he regular timer
    if(avgPeak > TIMED_SHOT_LEVEL) {
        self.volumeMax = -5;
        [self.updateTimer invalidate];
        if(![self.timedPicture isValid]) {
            self.timedPicture = [NSTimer scheduledTimerWithTimeInterval:TOO_LOUD_TIMED_SHOT target:self selector:@selector(captureIfTimerIsValid) userInfo:nil repeats:YES];
        }
    // Else if the other timer is invalid start it again
    } else if(![self.updateTimer isValid]) {
        [self.timedPicture invalidate];
        if([self.updateTimer isValid]) {
            self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:UPDATE_TIME target:self selector:@selector(monitorVolume) userInfo:nil repeats:YES];
        }
    }
    
    // If the average is too far away decrease the thresholds
    // If the average is louder than the cushion from the threshold increase the thresholds
    double peakDiff = self.averageUpdatePeak - avgPeak;
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
    self.updateTimerActionCount++;
    if(self.updateTimerActionCount >= MINUTE) {
        self.picturesTakenThisMinute = 0;
        self.updateTimerActionCount = 0;
    }
}

- (void)captureIfTimerIsValid
{
    double avgPeak = self.totalPeak/self.timeIntervals;
    if(avgPeak > TIMED_SHOT_LEVEL) {
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
    [cell addImage:[self.imageManager getImageAtIndex:indexPath.row]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.imageManager count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // DONT DO SHIT
}

 

//*********************************************************
//*********************************************************
#pragma mark - Miscellaneous
//*********************************************************
//*********************************************************

- (void)didReceiveMemoryWarning
{
    //clears the images but keeps the data
    //when access images from the manager it
    //will recreate deleted images from the data
    [self.imageManager conserveMemory];
}

- (IBAction)toggleRecording:(id)sender 
{
    if(self.session.running && self.recorder.recording) {
        [self stopEverything];
    } else {
        [self startEverything];
    }
}

- (IBAction)stopEverything
{
    [self.timer invalidate];
    [self.updateTimer invalidate];
    [self.recorder stop];
    [self.session stopRunning];
    [self.startButton setTitle:@"Start!" forState:UIControlStateNormal];
    [self.startButton setImage:[UIImage imageNamed:@"startButton.png"] forState:UIControlStateNormal];
}

- (IBAction)startEverything
{
    // the camera needs time to warm up so this stops black pictures from being taken
    self.lastTakenTime = [NSDate date];
    [self.recorder record];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(levelTimerCallback:) userInfo:nil repeats:YES];
    self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:UPDATE_TIME target:self selector:@selector(monitorVolume) userInfo:nil repeats:YES];
    [self.session startRunning];
    [self.startButton setTitle:@"Stop!" forState:UIControlStateNormal];
    [self.startButton setImage:[UIImage imageNamed:@"stopButton.png"] forState:UIControlStateNormal];
}

- (IBAction)toggleHide:(id)sender
{
    self.hideView.hidden = (self.hideView.hidden) ? NO : YES;
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
    else if(volumeMax < -50)
        _volumeMax = -50;
    else
        _volumeMax = volumeMax;
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


@end
