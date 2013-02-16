//
//  TutorialViewController.m
//  Candid
//
//  Created by Amadou Crookes on 2/11/13.
//  Copyright (c) 2013 Amadou Crookes. All rights reserved.
//

#import "TutorialViewController.h"
#import "KandidUtils.h"

typedef enum PageNum {
    PageNumWelcome = 0,
    PageNumStartStop,
    PageNumHide,
    PageNumProximitySensor,
    PageNumClear,
    PageNumSave,
} PageNum;

const int NumPages = 6;

@interface TutorialViewController ()


@end

@implementation TutorialViewController

@synthesize pageNum = _pageNum;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.pageNum = 0;
    self.pageCounter.numberOfPages = NumPages;
    self.pageCounter.userInteractionEnabled = NO;
    [self customizeAppearance];
}

- (void)customizeAppearance {
    [self.pageCounter setPageIndicatorTintColor:[KandidUtils kandidPurple]];
    [self.pageTitle setTextColor:[KandidUtils kandidPurple]];
    [self.pageDescription setTextColor:[KandidUtils kandidPurple]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)dismissTutorial:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)nextPage:(id)sender {
    self.pageNum++;
}

- (void)viewDidUnload {
    [self setPageCounter:nil];
    [self setTitle:nil];
    [self setPageDescription:nil];
    [self setImageView:nil];
    [super viewDidUnload];
}

- (void)setPageNum:(int)pageNum {
    _pageNum = pageNum;
    self.pageCounter.currentPage = pageNum;
    self.pageTitle.text   = [TutorialViewController getTitleForPage:pageNum];
    self.pageDescription.text = [TutorialViewController getDescriptionForPage:pageNum];
    self.imageView.image = [TutorialViewController getImageForPage:pageNum];
    switch (pageNum) {
        case PageNumWelcome:
            break;
        case PageNumStartStop:
            break;
        case PageNumHide:
            break;
        case PageNumClear:
            break;
        case PageNumSave:
            break;
        case PageNumProximitySensor:
            break;
        default:
            [self dismissTutorial:nil];
            break;
    }
}

+ (NSString*)getTitleForPage:(PageNum)pageNumber {
    NSString* title = @"N/A";
    switch (pageNumber) {
        case PageNumWelcome:
            title = @"Welcome To Kandid!";
            break;
        case PageNumStartStop:
            title = @"Starting and Stopping";
            break;
        case PageNumClear:
            title = @"Clearing";
            break;
        case PageNumHide:
            title = @"Hiding";
            break;
        case PageNumSave:
            title = @"How do I get the images?";
            break;
        case PageNumProximitySensor:
            title = @"Saving Battery";
            break;
        default:
            break;
    }
    return title;
}

+ (NSString*)getDescriptionForPage:(PageNum)pageNumber {
    NSString* desc = @"N/A";
    switch (pageNumber) {
        case PageNumWelcome:
            desc = @"Kandid aims to capture photos of exciting moments without someone having to stand behind the camera 📷!";
            break;
        case PageNumStartStop:
            desc = @"Click the camera with green to start. Then position the phone so the camera has the best view of what is going on. It will take photos when appropriate. Click the red camera to stop.";
            break;
        case PageNumClear:
            desc = @"Clear gives you a fresh camera roll by removing those currently on the film roll.";
            break;
        case PageNumHide:
            desc = @"Hide makes the screen black and dims the screen to save battery, so others do not know what is going on, and so you can get truly Kandid images 😜.";
            break;
        case PageNumProximitySensor:
            desc = @"When Kandid is running if you cover the proximity sensor (right above the screen) the screen will turn off which saves a lot of battery. Place your finger there now.";
            break;
        case PageNumSave:
            desc = @"Everytime Kandid takes a picture it is shown at the top of film roll and it is also saved to your photo album, so after clearing a film roll you still have all of the photos 😄. Have fun!";
            break;
        default:
            break;
    }
    [[UIDevice currentDevice] setProximityMonitoringEnabled:(pageNumber == PageNumProximitySensor)];
    return desc;
}

+ (UIImage*)getImageForPage:(PageNum)pageNumber {
    return [UIImage imageNamed:@"tutorialImage-0"];
    /*
    UIImage* image;
    switch (pageNumber) {
        case PageNumStartStop:
            image = [UIImage imageNamed:[NSString stringWithFormat:@"tutorialImage-%i", pageNumber]];
        default:
            image = [UIImage imageNamed:@"tutorialImage-0"];
    }
    return image;
     */
}


@end
