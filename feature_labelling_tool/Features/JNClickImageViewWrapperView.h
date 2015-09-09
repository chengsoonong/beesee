//
//  JNClickImageViewWrapperView.h
//  
//
//  Created by Jakub Nabaglo on 26/08/2015.
//
//

#import <Cocoa/Cocoa.h>
#import "JNClickImageView.h"

@interface JNClickImageViewWrapperView : NSView
@property(nonatomic) NSImage *image;
@property(readonly) JNClickImageView *clickImageView;
@end
