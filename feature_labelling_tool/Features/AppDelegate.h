//
//  AppDelegate.h
//  Features
//
//  Created by Jakub Nabaglo on 25/08/2015.
//  Copyright (c) 2015 Jakub Nabaglo. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "JNClickImageViewWrapperView.h"

@interface AppDelegate : NSObject <NSApplicationDelegate, JNClickImageViewDelegate>
@property IBOutlet JNClickImageViewWrapperView *clickImageViewWrapperView;
@property IBOutlet NSTextField *label;
@property IBOutlet NSButton *button;
//- (IBAction)a:(id)sender;
//- (void)startImage:(NSImage *)image name:(NSString *)name;
- (IBAction)newFile:(id)sender;
@end
