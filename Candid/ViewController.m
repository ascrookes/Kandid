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

const int SECONDS_BETWEEN_IMAGES = -5;
const int PEAK_DIFFERENCE = 5;
const int ADJUST_NUM = 5;
const int UPDATE_TIME = 5;
const int MINUTE = 60/UPDATE_TIME;
const int MAIN_TIMER_REPEAT_TIME = 0.1;
// The cushion above the max to monitor where the max should be
const int MAX_CUSHION = 15;
// if the max average is greater than -5 set it too take images on a timer
const int TOO_LOUD_TIMED_SHOT = 10;
const int TIMED_SHOT_LEVEL = -5;
const int MAX_PICTURES_PER_MINUTE = 8;
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

    [self.startButton setImage:[UIImage imageNamed:@"start.png"] forState:UIControlStateNormal];
    [self.hideButton  setImage:[UIImage imageNamed:@"clear.png"]  forState:UIControlStateNormal];
    
    if(!self.recorder.recording) {
        [self.recorder prepareToRecord];
        self.recorder.meteringEnabled = YES;
    }    
    self.volumeMax = -10.0;
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
    
    [self.imageCapture captureStillImageAsynchronouslyFromConnection:videoConnection
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
        });
        NSLog(@"CAPTURING: %i",self.numPictures);
    }];
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
    return     peak >= self.volumeMax
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

// Only capture if the average volume is greater than what is designated as too loud (TIMED_SHOT_LEVEL)
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
    return (count < 25) ? count : 25;
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
    [self.startButton setImage:[UIImage imageNamed:@"start.png"] forState:UIControlStateNormal];
    [self.hideButton setImage:[UIImage imageNamed:@"clear.png"] forState:UIControlStateNormal];
    [self.hideButton removeTarget:self action:@selector(toggleHide:) forControlEvents:UIControlEventTouchUpInside];
    [self.hideButton addTarget:self action:@selector(clearFilmRoll:) forControlEvents:UIControlEventTouchUpInside];
    self.levelLabel.text = @"Not Running";
}

- (IBAction)startEverything
{
    // the camera needs time to warm up so this stops black pictures from being taken
    self.lastTakenTime = [NSDate date];
    [self.recorder record];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:MAIN_TIMER_REPEAT_TIME target:self selector:@selector(levelTimerCallback:) userInfo:nil repeats:YES];
    self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:UPDATE_TIME target:self selector:@selector(monitorVolume) userInfo:nil repeats:YES];
    [self.session startRunning];
    [self.startButton setImage:[UIImage imageNamed:@"stop.png"] forState:UIControlStateNormal];
    [self.hideButton setImage:[UIImage imageNamed:@"hide.png"] forState:UIControlStateNormal];
    [self.hideButton removeTarget:self action:@selector(clearFilmRoll:) forControlEvents:UIControlEventTouchUpInside];
    [self.hideButton addTarget:self action:@selector(toggleHide:) forControlEvents:UIControlEventTouchUpInside];

}

- (IBAction)toggleHide:(id)sender {
    self.hideView.hidden = !self.hideView.hidden;
}

- (IBAction)clearFilmRoll:(id)sender {
    [self.imageManager clearImageData];
    [self.table reloadData];
    self.numPictures = 0;
    self.picturesTaken.text = [NSString stringWithFormat:@"%i", self.numPictures];
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
    self.table.userInteractionEnabled = YES;
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
