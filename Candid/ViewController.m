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
const int maxCushion = 15;

@interface ViewController ()

//*********************************************************
//*********************************************************
#pragma mark - Property Stuff
//*********************************************************
//*********************************************************

@property (nonatomic, strong) AVCaptureStillImageOutput* imageCapture;
@property (nonatomic, strong) AVCaptureInput* vidCapture;
@property (nonatomic, strong) AVCaptureVideoDataOutput* vidOutput;
@property (nonatomic, strong) AVCaptureConnection* connection;
@property (nonatomic, strong) AVCaptureDeviceInput* camInput;
@property (nonatomic, strong) AVCaptureDevice* camDevice;
@property (nonatomic, strong) AVCaptureSession* session;
@property (nonatomic, strong) CIContext* context;
@property (nonatomic, strong) NSDate* lastTakenTime;
@property (nonatomic) int numPictures;

@end


@implementation ViewController

@synthesize recorder = _recorder;
@synthesize image = _image;
@synthesize record = _record;
@synthesize timer = _timer;

@synthesize imageCapture = _imageCapture;
@synthesize vidCapture = _vidCapture;
@synthesize vidOutput = _vidOutput;
@synthesize connection = _connection;
@synthesize camInput = _camInput;
@synthesize camDevice = _camDevice;
@synthesize session = _session;
@synthesize context = _context;

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
@synthesize scrollBar = _scrollBar;


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
        [self.recorder record];
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

    self.scrollBar = [[ScrollBar alloc] initWithSuperView:self.view];
    self.scrollBar.delegate = self;
}

     

- (void)viewDidUnload
{
    [self setImage:nil];
    [self setRecord:nil];
    [self setPicturesTaken:nil];
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
    //Accept all orientations cause the mics are on the bottom
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
    [self.scrollBar rotateToOrientation:interfaceOrientation];
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
    
    [self.imageCapture captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError *error){
        
        NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
        //[_pictureData addObject:imageData];
        [self.scrollBar addImage:imageData];
        //NSLog(@"%i",[self.pictureData count]);
        UIImage* image = [UIImage imageWithData:imageData];
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
        self.image.image = image;
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
    if([_recorder peakPowerForChannel:0] >= self.volumeMax && [self.lastTakenTime timeIntervalSinceNow] < secondsBetweenImages && ![self.timedPicture isValid] && self.session.running && self.recorder.recording) {
        //NSLog(@"TAKING A PICTURE NOW");
        [self captureNow];
    }
}

//Action for self.updateTimer
- (void)monitorVolume
{
    bool update = NO;
    double avgPeak = self.totalPeak/self.timeIntervals;
    if(avgPeak > -5) {
        self.timedPicture = [NSTimer scheduledTimerWithTimeInterval:20 target:self selector:@selector(captureNow) userInfo:nil repeats:YES];
    } else {
        [self.timedPicture invalidate];
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
    
    //NSLog(@"PEAK DIFF: %f",peakDiff);
    if(update) {
        //NSLog(@"Should update");
        [self adjustMetersWithNum:diffNum];
        //NSLog(@"MAX: %i",self.volumeMax);
        //NSLog(@"COMPARE: %f", self.averageUpdatePeak);
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
    self.volumeMax += diff;
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
    [self.session stopRunning];
}

- (void)startEverything
{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(levelTimerCallback:) userInfo:nil repeats:YES];
    self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:updateTime target:self selector:@selector(monitorVolume) userInfo:nil repeats:YES];
    [self.session startRunning];
}

//*********************************************************
//*********************************************************
#pragma mark - Scroll Bar Delegate/Datasource
//*********************************************************
//*********************************************************

- (void)didSelectImage:(NSData *)imageData
{
    NSLog(@"GOLF");
    self.image.image = [UIImage imageWithData:imageData];
}

- (void)stop
{
    [self stopEverything];
}

- (void)start
{
    [self startEverything];
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

-(CIContext*)context
{
    if(!_context) {
        _context = [CIContext contextWithOptions:nil];
    }
    
    return _context;
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

- (AVCaptureConnection*)connection 
{
    if(!_connection) {
        _connection = [[AVCaptureConnection alloc] init];
    }
    
    return _connection;
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
    if(averageUpdatePeak > 0)
        _averageUpdatePeak = 0;
    else
        _averageUpdatePeak = averageUpdatePeak;
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
