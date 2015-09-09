//
//  JNClickImageView.h
//  
//
//  Created by Jakub Nabaglo on 25/08/2015.
//
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>
#import "JNClickImageViewDelegate.h"

typedef enum {
    JNClickImageViewDragMode,
    JNClickImageViewClickMode,
} JNClickImageViewMode;

@interface JNClickImageView : NSView
@property(readonly) CALayer *imageLayer;
@property JNClickImageViewMode mode;
@property(weak) id<JNClickImageViewDelegate> delegate;
@end
