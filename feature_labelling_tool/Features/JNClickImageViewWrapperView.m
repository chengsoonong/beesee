//
//  JNClickImageViewWrapperView.m
//  
//
//  Created by Jakub Nabaglo on 26/08/2015.
//
//

#import "JNClickImageViewWrapperView.h"

@implementation JNClickImageViewWrapperView
- (instancetype)initWithCoder:(NSCoder *)coder {
    if ([super initWithCoder:coder]) {
        _clickImageView = [[JNClickImageView alloc] initWithFrame:NSMakeRect(0.0, 0.0, 0.0, 0.0)];
        [self addSubview:self.clickImageView];
    }
    return self;
}
- (void)setImage:(NSImage *)image {
    if (_image != image) {
        _image = image;
        self.clickImageView.imageLayer.contents = image;
        
        NSSize selfSize = self.bounds.size;
        NSSize imageSize = image.size;
        
        CGFloat selfAspectRatio = selfSize.width / selfSize.height;
        CGFloat imageAspectRatio = imageSize.width / imageSize.height;
        
        if (selfAspectRatio > imageAspectRatio) {
            self.clickImageView.frame = NSMakeRect((selfSize.width-selfSize.height*imageAspectRatio)/2.0,
                                                   0.0,
                                                   selfSize.height*imageAspectRatio,
                                                   selfSize.height);
        } else if (selfAspectRatio < imageAspectRatio) {
            self.clickImageView.frame = NSMakeRect(0.0,
                                                   (selfSize.height-selfSize.width/imageAspectRatio)/2.0,
                                                   selfSize.width,
                                                   selfSize.width/imageAspectRatio);
        } else {
            self.clickImageView.frame = NSMakeRect(0.0, 0.0, selfSize.width, selfSize.height);
        }
    }
}

@end
