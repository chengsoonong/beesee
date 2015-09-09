//
//  JNClickImageViewDelegate.h
//  
//
//  Created by Jakub Nabaglo on 26/08/2015.
//
//

#import <Foundation/Foundation.h>

@protocol JNClickImageViewDelegate <NSObject>
- (void)dragFinishedWithRect:(NSRect)rect;
- (void)clickFinishedWithPoint:(NSPoint)point;
@end
