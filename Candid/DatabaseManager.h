//
//  DatabaseManager.h
//  Candid
//
//  Created by Amadou Crookes on 1/9/13.
//  Copyright (c) 2013 Amadou Crookes. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DatabaseManager : NSObject

+ (void)addImageToDB;
+ (void)addImageSessionToDBWithSessionCount:(unsigned int)sessionCount length:(unsigned int)length;

@end
