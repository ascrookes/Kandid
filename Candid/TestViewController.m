//
//  TestViewController.m
//  Candid
//
//  Created by Amadou Crookes on 6/27/12.
//  Copyright (c) 2012 Amadou Crookes. All rights reserved.
//

#import "TestViewController.h"

@interface TestViewController ()

@end

@implementation TestViewController

@synthesize session = _session;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    _session = [[AVAudioSession alloc] init];
    NSError* error;
    [_session setCategory:AVAudioSessionCategoryRecord error:&error];
    [_session setMode:AVAudioSessionModeMeasurement error:&error];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
