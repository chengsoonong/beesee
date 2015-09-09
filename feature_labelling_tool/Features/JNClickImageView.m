//
//  JNClickImageView.m
//  
//
//  Created by Jakub Nabaglo on 25/08/2015.
//
//

#import "JNClickImageView.h"
#import "JNSelectionLayer.h"

@implementation JNClickImageView {
    CALayer *selectionLayer;
    BOOL engaged;
    NSPoint startPoint, startPointInView;
}
- (instancetype)initWithFrame:(NSRect)frameRect {
    if ([super initWithFrame:frameRect]) {
        self.wantsLayer = YES;
        
        _imageLayer = [[CALayer alloc] init];
        self.imageLayer.frame = self.bounds;
        
        self.imageLayer.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
        self.imageLayer.contentsGravity = kCAGravityResize;
        
        [self.layer addSublayer:self.imageLayer];
        
        selectionLayer = [[JNSelectionLayer alloc] init];
        
    }
    return self;
}

- (NSPoint)eventLocationInImage:(NSEvent *)theEvent {
    NSSize imageSize = ((NSImage *)self.imageLayer.contents).size;
    
    NSPoint clickLocationInView = [self convertPoint:theEvent.locationInWindow fromView:nil];
    NSPoint clickLocationInImage = NSMakePoint(clickLocationInView.x / self.frame.size.width * imageSize.width,
                                               clickLocationInView.y / self.frame.size.height * imageSize.height);
    
    return clickLocationInImage;
}
- (NSPoint)eventLocationInView:(NSEvent *)theEvent {
    return [self convertPoint:theEvent.locationInWindow fromView:nil];
}

- (void)mouseDown:(NSEvent *)theEvent {
    engaged = YES;
    startPoint = [self eventLocationInImage:theEvent];
    startPointInView = [self eventLocationInView:theEvent];
    if (self.mode == JNClickImageViewDragMode) {
        selectionLayer.frame = NSMakeRect(startPointInView.x, startPointInView.y, 0.0, 0.0);
        [self.layer addSublayer:selectionLayer];
    }
    
}
- (void)mouseUp:(NSEvent *)theEvent {
    if (engaged) {
        engaged = NO;
        NSPoint location = [self eventLocationInImage:theEvent];
        
        switch (self.mode) {
            case JNClickImageViewDragMode:
                [self.delegate dragFinishedWithRect:NSMakeRect(MIN(startPoint.x, location.x),
                                                               MIN(startPoint.y, location.y),
                                                               ABS(startPoint.x - location.x),
                                                               ABS(startPoint.y - location.y))];
                [selectionLayer removeFromSuperlayer];
                
                break;
            case JNClickImageViewClickMode:
                [self.delegate clickFinishedWithPoint:location];
                break;
        }
    }
    
}
- (void)mouseDragged:(NSEvent *)theEvent {
    if (self.mode == JNClickImageViewDragMode) {
        NSPoint currentPointInView = [self eventLocationInView:theEvent];
        selectionLayer.frame = NSMakeRect(MIN(currentPointInView.x, startPointInView.x),
                                          MIN(currentPointInView.y, startPointInView.y),
                                          ABS(currentPointInView.x - startPointInView.x),
                                          ABS(currentPointInView.y - startPointInView.y));
    }
}

@end
