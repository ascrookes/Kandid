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
    PageNumStartStop = 0,
    PageNumHide,
    PageNumClear,
    PageNumSave,
} PageNum;

@interface TutorialViewController ()


@end

@implementation TutorialViewController

@synthesize pageNum = _pageNum;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.pageNum = 0;
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
        case PageNumStartStop:
            //
            break;
        case PageNumHide:
            //
            break;
        case PageNumClear:
            //
            break;
        case PageNumSave:
            //
            break;
            
        default:
            [self dismissTutorial:nil];
            break;
    }
}

+ (NSString*)getTitleForPage:(PageNum)pageNumber {
    NSString* title = @"N/A";
    switch (pageNumber) {
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
            title = @"Saving Images";
            break;
        default:
            break;
    }
    return title;
}

+ (NSString*)getDescriptionForPage:(PageNum)pageNumber {
    NSString* desc = @"N/A";
    switch (pageNumber) {
        case PageNumStartStop:
            desc = @"Click this button to start. Then put the phone where the camera has the best view of what is going on. When the button is red click it to stop and look at all the pictures :).";
            break;
        case PageNumClear:
            desc = @"This will delete all images currently on the film roll.";
            break;
        case PageNumHide:
            desc = @"Makes the screen black and dims the screen to save battery, and so others do not know what is going on 😜.";
            break;
        case PageNumSave:
            desc = @"Click this button to select the images you want to be saved.";
            break;
        default:
            break;
    }
    return desc;
}

+ (UIImage*)getImageForPage:(PageNum)pageNumber {
    UIImage* image;
    switch (pageNumber) {
        case PageNumStartStop:
            image = [UIImage imageNamed:[NSString stringWithFormat:@"tutorialImage-%i", pageNumber]];
        default:
            image = [UIImage imageNamed:@"tutorialImage-0"];
    }
    return image;
}


@end
