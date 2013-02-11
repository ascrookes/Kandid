//
//  TutorialViewController.h
//  Candid
//
//  Created by Amadou Crookes on 2/11/13.
//  Copyright (c) 2013 Amadou Crookes. All rights reserved.
//

#import "ViewController.h"

@interface TutorialViewController : ViewController

@property (nonatomic) int pageNum;
@property (weak, nonatomic) IBOutlet UIPageControl *pageCounter;
@property (weak, nonatomic) IBOutlet UILabel *pageTitle;
@property (weak, nonatomic) IBOutlet UITextView *pageDescription;

@end
