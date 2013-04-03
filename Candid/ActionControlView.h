//
//  ActionControlView.h
//  Candid
//
//  Created by Amadou Crookes on 4/1/13.
//  Copyright (c) 2013 Amadou Crookes. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ActionControlDelegate <NSObject>

- (void)toggleRecording;
- (void)shouldHide;
- (void)shouldClear;

@end

@interface ActionControlView : UIView

@property (nonatomic, strong) UIImageView* camera;
@property (nonatomic, strong) id <ActionControlDelegate> delegate;

+ (ActionControlView*)actionControl:(id <ActionControlDelegate>)del;
- (void)setRecording:(BOOL)recording;

@end
