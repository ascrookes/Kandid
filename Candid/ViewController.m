//
//  ViewController.m
//  Candid
//
//  Created by Amadou Crookes on 6/23/12.
//  Copyright (c) 2012 Amadou Crookes. All rights reserved.
//

#import "ViewController.h"

const int secondsBetweenImages = -5;
const int peakDifference = 5;
const int adjustNum = 5;
const int updateTime = 10;
// The cushion above the max to monitor where the max should be
const int maxCushion = 20;
// if the max average is greater than -5 set it too take images on a timer
const int tooLoudTimedShot = 30;

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

@synthesize recorder = _recorder;
@synthesize timer = _timer;

@synthesize imageCapture = _imageCapture;
@synthesize camInput = _camInput;
@synthesize camDevice = _camDevice;
@synthesize session = _session;

@synthesize pictureData = _pictureData;

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
    self.lastTakenTime = [NSDate date];
    self.volumeMax = -5.0;
    self.averageUpdatePeak = self.volumeMax - maxCushion;
    self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:updateTime target:self selector:@selector(monitorVolume) userInfo:nil repeats:YES];

    self.camDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    self.camInput  = [AVCaptureDeviceInput deviceInputWithDevice:self.camDevice error:nil];
    
    [self.session addInput:self.camInput];
    [self.session addOutput:self.imageCapture];
    
    [self.session startRunning];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(levelTimerCallback:) userInfo:nil repeats:YES];
}

     

- (void)viewDidUnload
{
    [self setPicturesTaken:nil];
    [self setCameraButton:nil];
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
    return YES;
}



//*********************************************************
//*********************************************************
#pragma mark - AV Stuff
//*********************************************************
//*********************************************************

- (void)setupRecorder
{
    NSURL *url = [NSURL fileURLWithPath:@"/dev/null"];
    
    NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithFloat: 44100.0],                 AVSampleRateKey,
                              [NSNumber numberWithInt: kAudioFormatAppleLossless], AVFormatIDKey,
                              [NSNumber numberWithInt: 1],                         AVNumberOfChannelsKey,
                              [NSNumber numberWithInt: AVAudioQualityHigh],         AVEncoderAudioQualityKey,
                              nil];
    
    NSError* error;
    
    _recorder = [[AVAudioRecorder alloc] initWithURL:url settings:settings error:&error];
    _recorder.delegate = self;
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
        
        if(!CMSampleBufferIsValid(imageSampleBuffer) || !CMSampleBufferDataIsReady(imageSampleBuffer)) {
            // the buffer is not ready to capture the image and would crash
            // Reset the time so it doesnt wait to take another picture
            self.lastTakenTime = [NSDate distantPast];
            return;
        }
        NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
        UIImageWriteToSavedPhotosAlbum([UIImage imageWithData:imageData], nil, nil, nil);
        self.numPictures++;
        self.picturesTaken.text = [NSString stringWithFormat:@"%i",self.numPictures];
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
	[_recorder updateMeters];
    float peak = [self.recorder peakPowerForChannel:0];
    self.totalPeak += peak;
    self.timeIntervals++;
    if(peak >= self.volumeMax && [self.lastTakenTime timeIntervalSinceNow] < secondsBetweenImages && ![self.timedPicture isValid] && self.session.running && self.recorder.recording) {
        [self captureNow];
    }
}

//Action for self.updateTimer
- (void)monitorVolume
{
    bool update = NO;
    double avgPeak = self.totalPeak/self.timeIntervals;
    if(avgPeak > -5) {
        self.volumeMax = 0;
        if(![self.timedPicture isValid]) {
            self.timedPicture = [NSTimer scheduledTimerWithTimeInterval:tooLoudTimedShot target:self selector:@selector(captureIfTimerIsValid) userInfo:nil repeats:YES];

        }
        [self.updateTimer invalidate];
        self.updateTimer = nil;
    } else if(![self.updateTimer isValid]) {
        [self.timedPicture invalidate];
        if(![self.updateTimer isValid]) {
            self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:updateTime target:self selector:@selector(monitorVolume) userInfo:nil repeats:YES];
        }
    }
    
    
    double peakDiff = self.averageUpdatePeak - avgPeak;
    int diffNum = 0;
    if(peakDiff > peakDifference) {
        diffNum = -1 * adjustNum;
        update = YES;
    } else if(peakDiff < 0) {
        diffNum = adjustNum;
        update = YES;
    }
    self.totalPeak = 0;
    self.timeIntervals = 0;
    
    if(update) {
        [self adjustMetersWithNum:diffNum];
    }
}

- (void)captureIfTimerIsValid
{
    double avgPeak = self.totalPeak/self.timeIntervals;
    if(avgPeak > -5) {
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
    self.totalPeak += diff * self.timeIntervals;
    if([self.updateTimer isValid]) {
        self.volumeMax += diff;
    }
    self.averageUpdatePeak += diff;
}


//*********************************************************
//*********************************************************
#pragma mark - Miscellaneous
//*********************************************************
//*********************************************************


- (IBAction)toggleRecording:(id)sender 
{
    if(_session.running && _recorder.recording) {
        [self stopEverything];
    } else {
        [self startEverything];
    }
}

- (void)stopEverything
{
    [self.timer invalidate];
    [self.updateTimer invalidate];
    [self.recorder stop];
    [self.session stopRunning];
    [self.cameraButton setImage:[UIImage imageNamed:@"begin.png"] forState:UIControlStateNormal];
}

- (void)startEverything
{
    // the camera needs time to warm up so this stops black pictures from being taken
    self.lastTakenTime = [NSDate date];
    [self.recorder record];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(levelTimerCallback:) userInfo:nil repeats:YES];
    self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:updateTime target:self selector:@selector(monitorVolume) userInfo:nil repeats:YES];
    [self.session startRunning];
    [self.cameraButton setImage:[UIImage imageNamed:@"recording.png"] forState:UIControlStateNormal];
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

- (NSMutableArray*)pictureData
{
    if(!_pictureData) {
        _pictureData = [[NSMutableArray alloc] init];
    }
    return _pictureData;
}




@end
