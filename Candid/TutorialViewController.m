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
    //PageNumProximitySensor,
    PageNumClear,
    PageNumSave,
} PageNum;

const int NumPages = 5;

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
        default:
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasSeenTutorial"];
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
            desc = @"Clear gives you a fresh camera roll by deleting those currently on the film roll. These images are permanently deleted.";
            break;
        case PageNumHide:
            desc = @"Hide makes the screen black and dims the screen to save battery, so others do not know what is going on, and so you can get truly Kandid images 😜.";
            break;
        case PageNumSave:
            desc = @"Everytime Kandid takes a picture it is shown at the top of film roll. To save it swipe the image to the right. If you would like to delete it, swipe it to the left.";
            break;
        default:
            break;
    }
    return desc;
}

+ (UIImage*)getImageForPage:(PageNum)pageNumber {
    return [UIImage imageNamed:@"tutorialImage-0"];
}


@end
