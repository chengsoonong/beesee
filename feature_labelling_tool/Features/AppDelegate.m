//
//  AppDelegate.m
//  Features
//
//  Created by Jakub Nabaglo on 25/08/2015.
//  Copyright (c) 2015 Jakub Nabaglo. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate {
    NSImage *currImage;
    
    NSString *currImagePath;
    NSMutableArray *unlabelledImagePaths;
    NSMutableArray *labelledImageData;
    NSMutableDictionary *currImageData;
    
    NSArray *features;
    NSUInteger currentFeatureIndex;
    
    NSString *basePath;
}
- (void)awakeFromNib {
    [super awakeFromNib];
    self.clickImageViewWrapperView.clickImageView.delegate = self;
    
    features = @[@"head",
                 @"left antenna",
                 @"right antenna",
                 @"thorax",
                 @"abdomen",
                 @"left wing",
                 @"right wing"];
}

- (void)clickFinishedWithPoint:(NSPoint)point {
    if (currImageData) {
        NSSize clickImageViewSize = self.clickImageViewWrapperView.clickImageView.frame.size;
        currImageData[features[currentFeatureIndex]] = @[@(point.x),
                                                         @(point.y)];
        if (currentFeatureIndex < features.count-1) {
            [self displayFeature:currentFeatureIndex+1];
        } else {
            [self pushCurrentImage];
            [self popNewImage];
        }
    }
}
- (void)dragFinishedWithRect:(NSRect)rect {
    @throw [[NSException alloc] init];
}

- (void)displayFeature:(NSUInteger)featureIndex {
    currentFeatureIndex = featureIndex;
    self.label.stringValue = [NSString stringWithFormat:@"Select the %@.\n(feature %lu of %lu)\n(image %lu of %lu)",
                              features[featureIndex],
                              featureIndex+1, features.count,
                              labelledImageData.count+1, labelledImageData.count+unlabelledImagePaths.count];
    self.button.title = [NSString stringWithFormat:@"Not visible"]; // TODO: fix
    self.button.enabled = YES;
    self.resetButton.enabled = YES;
    self.difficultCheckbox.enabled = YES;
}

- (void)pushCurrentImage {
    [labelledImageData addObject:currImageData];
    currImagePath = nil;
    currImageData = nil;
    [unlabelledImagePaths removeObjectAtIndex:0];
}
- (void)popNewImage {
    if (unlabelledImagePaths.count) {
        currImagePath = unlabelledImagePaths[0];
        NSString *absolutePath = [[basePath stringByAppendingPathComponent:currImagePath] stringByExpandingTildeInPath];
        currImage = [[NSImage alloc] initWithContentsOfFile:absolutePath];
        self.clickImageViewWrapperView.image = currImage;
        self.clickImageViewWrapperView.clickImageView.mode = JNClickImageViewClickMode;
        
        currImageData = [NSMutableDictionary dictionaryWithDictionary:@{@"path":currImagePath,
                                                                        @"size":@[@(currImage.size.width), @(currImage.size.height)],
                                                                        @"difficult":@NO}];
        
        [self displayFeature:0];
        self.difficultCheckbox.state = NSOffState;
    } else {
        self.clickImageViewWrapperView.image = nil;
        self.label.stringValue = @"Done! Don't forget to save.";
        self.button.title = @"";
        self.button.enabled = NO;
        self.resetButton.enabled = NO;
        self.difficultCheckbox.state = NSOffState;
        self.difficultCheckbox.enabled = NO;
    }
}

- (IBAction)buttonPressed:(id)sender {
    if (currImageData) {
        currImageData[features[currentFeatureIndex]] = [NSNull null];
        if (currentFeatureIndex < features.count-1) {
            [self displayFeature:currentFeatureIndex+1];
        } else {
            [self pushCurrentImage];
            [self popNewImage];
        }
    }
}

- (IBAction)newFile:(id)sender {
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    panel.canChooseFiles = YES;
    panel.canChooseDirectories = NO;
    panel.resolvesAliases = YES;
    panel.allowsMultipleSelection = NO;
    panel.message = @"Select the list of image files.";
    void (^handler)(NSInteger) = ^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton) {
            NSString *fileContents = [NSString stringWithContentsOfURL:panel.URLs[0]
                                                              encoding:NSUTF8StringEncoding
                                                                 error:nil];
            NSArray *lines = [fileContents componentsSeparatedByCharactersInSet: [NSCharacterSet newlineCharacterSet]];
            BOOL (^block)(NSString *, NSDictionary *) = ^BOOL (NSString *evaluatedObject, NSDictionary *bindings) {
                return ![evaluatedObject isEqualToString:@""];
            };
            NSPredicate *predicate = [NSPredicate predicateWithBlock:block];
            NSArray *nonemptyLines = [lines filteredArrayUsingPredicate:predicate];
            
            NSArray <NSString *> *basePathComponents = [[panel.URLs[0] path] pathComponents];
            basePath = [NSString pathWithComponents:[basePathComponents subarrayWithRange:NSMakeRange(0, basePathComponents.count-1)]];
            NSLog(@"basePath: %@", basePath);
            
            [self resume:@{ @"unlabelled" : [NSMutableArray arrayWithArray:nonemptyLines],
                            @"labelled"   : [NSMutableArray array]}];
        }
    };
    [panel beginSheetModalForWindow:self.window completionHandler:handler];
}

- (IBAction)openFile:(id)sender {
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    panel.canChooseFiles = YES;
    panel.canChooseDirectories = NO;
    panel.resolvesAliases = YES;
    panel.allowsMultipleSelection = NO;
    panel.message = @"Select the saved label file.";
    [panel beginSheetModalForWindow:self.window
                  completionHandler:^(NSInteger result) {
                      switch (result) {
                          case NSFileHandlingPanelOKButton:
                          {
                              NSData *fileData = [NSData dataWithContentsOfURL:panel.URLs[0]];
                              NSDictionary *JSONObject = [NSJSONSerialization JSONObjectWithData:fileData
                                                                                         options:NSJSONReadingMutableContainers
                                                                                           error:NULL];
                              
                              NSArray <NSString *> *basePathComponents = [[panel.URLs[0] path] pathComponents];
                              basePath = [NSString pathWithComponents:[basePathComponents subarrayWithRange:NSMakeRange(0, basePathComponents.count-1)]];
                              NSLog(@"basePath: %@", basePath);
                              
                              [self resume:JSONObject];
                          }
                              break;
                          case NSFileHandlingPanelCancelButton:
                              break;
                          default:
                              @throw [[NSException alloc] init];
                      }
                  }];
}
- (IBAction)saveFile:(id)sender {
    NSSavePanel *panel = [NSSavePanel savePanel];
    panel.canCreateDirectories = YES;
    panel.message = @"Choose a directory to save the label file.";
    [panel beginSheetModalForWindow:self.window
                  completionHandler:^(NSInteger result) {
                      switch (result) {
                          case NSFileHandlingPanelOKButton:
                          {
                              NSData *fileData = [NSJSONSerialization dataWithJSONObject:@{@"labelled"  :labelledImageData,
                                                                                           @"unlabelled":unlabelledImagePaths}
                                                                                 options:NSJSONWritingPrettyPrinted
                                                                                   error:NULL];
                              [fileData writeToURL:panel.URL atomically:YES];
                          }
                              break;
                          case NSFileHandlingPanelCancelButton:
                              break;
                          default:
                              @throw [[NSException alloc] init];
                      }

                  }];
}

- (void)resume:(NSDictionary *)JSONData {
    labelledImageData = JSONData[@"labelled"];
    unlabelledImagePaths = JSONData[@"unlabelled"];
    [self popNewImage];
}
- (IBAction)resetCurrentImage:(NSButton *)sender {
    currImageData = [NSMutableDictionary dictionaryWithDictionary:@{@"path":currImagePath,
                                                                    @"size":@[@(currImage.size.width), @(currImage.size.height)]}];
    
    [self displayFeature:0];
}
- (IBAction)difficultyChanged:(NSButton *)sender {
    currImageData[@"difficult"] = sender.state == NSOnState ? @YES : @NO;
}
@end
