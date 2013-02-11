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
    [self.description setTextColor:[KandidUtils kandidPurple]];
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
    [self setDescription:nil];
    [super viewDidUnload];
}

- (void)setPageNum:(int)pageNum {
    _pageNum = pageNum;
    self.pageCounter.currentPage = pageNum;
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
            
        default:
            [self dismissTutorial:nil];
            break;
    }
}


@end
