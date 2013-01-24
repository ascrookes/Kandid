//
//  KandidUtils.m
//  Candid
//
//  Created by Amadou Crookes on 1/14/13.
//  Copyright (c) 2013 Amadou Crookes. All rights reserved.
//
//  This is a collection of random functions that would be useful
//  throughout thos project

#import "KandidUtils.h"
#import "DatabaseManager.h"

@implementation KandidUtils

+ (void)setViewController:(UIViewController*)vc Title:(NSString*)title Font:(UIFont*)font
{
    UIButton *titleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [titleButton setFrame:CGRectMake(0, 0, 170, 35)];
    [titleButton setTitle:title forState:UIControlStateNormal];
    titleButton.titleLabel.font = font;
    titleButton.titleLabel.textColor = [KandidUtils kandidPurple];
    titleButton.userInteractionEnabled = NO;
    // make interactions possible and add an action here if wanted
    vc.navigationItem.titleView = titleButton;
}

+ (UIColor*)kandidPurple {
    return [UIColor colorWithRed:122/255.0 green:0 blue:1 alpha:1];
}

// increase the count of images taken on this device for asking users to rate
// once they hit a certain number they will be asked to rate
// also increases amount of images saved for all users to keep stats on the app
+ (void)increaseSavedImagesCount {
    NSString* key = [KandidUtils savedCountKey];
    NSInteger savedCount = [[NSUserDefaults standardUserDefaults] integerForKey:key];
    [[NSUserDefaults standardUserDefaults] setInteger:savedCount + 1 forKey:key];
    [DatabaseManager addSavedImageToDB];
}

+ (NSInteger)getSavedCount {
    return [[NSUserDefaults standardUserDefaults] integerForKey:[KandidUtils savedCountKey]];
}

+ (NSString*)savedCountKey {
    return @"numberOfSavedImages";
}

@end
