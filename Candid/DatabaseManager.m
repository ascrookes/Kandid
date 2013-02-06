//
//  DatabaseManager.m
//  Candid
//
//  Created by Amadou Crookes on 1/9/13.
//  Copyright (c) 2013 Amadou Crookes. All rights reserved.
//

#import "DatabaseManager.h"
#import "FSNConnection.h"

@implementation DatabaseManager


// the image basically just keeps count of number of images taken
// when that changes also give more information
+ (void)addImageToDB
{
    FSNConnection* connection =
    [FSNConnection withUrl:[NSURL URLWithString:@"http://ascrookes.webfactional.com/candid/image"]
                    method:FSNRequestMethodPOST
                   headers:[NSDictionary dictionary]
                parameters:[NSDictionary dictionary]
                parseBlock:nil
           completionBlock:^(FSNConnection *c) {
               //NSLog(@"\n  Response: %@\n  ResponseData: %@\n", c.response, [NSString stringWithUTF8String:[c.responseData bytes]]);
           }
             progressBlock:nil
     ];
    
    [connection start];
    [TestFlight passCheckpoint:@"CAPTURE_IMAGE"];
}

+ (void)addImageSessionToDBWithSessionCount:(unsigned int)sessionCount length:(unsigned int)length
{
    FSNConnection* connection =
    [FSNConnection withUrl:[NSURL URLWithString:@"http://ascrookes.webfactional.com/candid/imageSession"]
                    method:FSNRequestMethodPOST
                   headers:[NSDictionary dictionary]
                parameters:[NSDictionary dictionaryWithObjectsAndKeys:@(sessionCount), @"sessionCount",
                                                                      @(length), @"sessionLength", nil]
                parseBlock:nil
           completionBlock:^(FSNConnection *c) {
               //NSLog(@"\n  Response: %@\n  ResponseData: %@\n", c.response, [NSString stringWithUTF8String:[c.responseData bytes]]);
           }
             progressBlock:nil
     ];
    
    [connection start];
}

+ (void)addSavedImageToDB
{
    FSNConnection* connection =
    [FSNConnection withUrl:[NSURL URLWithString:@"http://ascrookes.webfactional.com/candid/savedImage"]
                    method:FSNRequestMethodPOST
                   headers:[NSDictionary dictionary]
                parameters:[NSDictionary dictionary]
                parseBlock:nil
           completionBlock:^(FSNConnection *c) {
               //NSLog(@"\n  Response: %@\n  ResponseData: %@\n", c.response, [NSString stringWithUTF8String:[c.responseData bytes]]);
           }
             progressBlock:nil
     ];
    
    [connection start];
    [TestFlight passCheckpoint:@"SAVED_IMAGE"];
}

@end
