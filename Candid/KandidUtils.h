//
//  KandidUtils.h
//  Candid
//
//  Created by Amadou Crookes on 1/14/13.
//  Copyright (c) 2013 Amadou Crookes. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KandidUtils : NSObject

+ (void)setViewController:(UIViewController*)vc Title:(NSString*)title Font:(UIFont*)font;
+ (UIColor*)kandidPurple;
+ (void)increaseSavedImagesCount;
+ (NSInteger)getSavedCount;
+ (NSString*)savedCountKey;

@end
