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
}

+ (void)addImageSessionToDBWithSessionCount:(unsigned int)sessionCount
{
    if(sessionCount == 0) {
        FSNConnection* connection =
        [FSNConnection withUrl:[NSURL URLWithString:@"http://ascrookes.webfactional.com/candid/imageSession"]
                        method:FSNRequestMethodPOST
                       headers:[NSDictionary dictionary]
                    parameters:[NSDictionary dictionaryWithObject:@(sessionCount) forKey:@"sessionCount"]
                    parseBlock:nil
               completionBlock:^(FSNConnection *c) {
                   //NSLog(@"\n  Response: %@\n  ResponseData: %@\n", c.response, [NSString stringWithUTF8String:[c.responseData bytes]]);
               }
                 progressBlock:nil
         ];
        
        [connection start];
    }
}



@end
