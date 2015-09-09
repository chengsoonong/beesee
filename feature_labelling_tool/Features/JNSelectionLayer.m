//
//  JNSelectionLayer.m
//  
//
//  Created by Jakub Nabaglo on 26/08/2015.
//
//

#import "JNSelectionLayer.h"

@implementation JNSelectionLayer
- (instancetype)init {
    if ([super init]) {
        CGColorRef color = CGColorCreateGenericRGB(0.0, 0.0, 1.0, 0.3);
        self.backgroundColor = color;
        CFRelease(color);
        self.delegate = self; // I know, I know
    }
    return self;
}
- (id<CAAction>)actionForLayer:(CALayer *)layer
                                  forKey:(NSString *)key {
    return (id)[NSNull null]; // Disgusting
}
@end
