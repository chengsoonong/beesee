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
}
- (void)awakeFromNib {
    NSLog(@"-[AppDelegate awakeFromNib]");
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
    NSLog(@"-[AppDelegate clickFinishedWithPoint:]");
    if (currImageData) {
        NSSize clickImageViewSize = self.clickImageViewWrapperView.clickImageView.frame.size;
        currImageData[features[currentFeatureIndex]] = @[@(point.x / clickImageViewSize.width * currImage.size.width),
                                                         @(point.y / clickImageViewSize.height * currImage.size.height)];
        if (currentFeatureIndex < features.count-1) {
            [self displayFeature:currentFeatureIndex+1];
        } else {
            [self pushCurrentImage];
            [self popNewImage];
        }
    }
}
- (void)dragFinishedWithRect:(NSRect)rect {
    NSLog(@"-[AppDelegate dragFinishedWithRect:]");
    @throw [[NSException alloc] init];
}

- (void)displayFeature:(NSUInteger)featureIndex {
    NSLog(@"-[AppDelegate displayFeature:]");
    currentFeatureIndex = featureIndex;
    self.label.stringValue = [NSString stringWithFormat:@"Select the %@.", features[featureIndex]];
    self.button.title = [NSString stringWithFormat:@"Not visible"]; // TODO: fix
    self.button.enabled = YES;
}

- (void)pushCurrentImage {
    NSLog(@"-[AppDelegate pushCurrentImage]");
    [labelledImageData addObject:currImageData];
    currImagePath = nil;
    currImageData = nil;
    [unlabelledImagePaths removeObjectAtIndex:0];
}
- (void)popNewImage {
    NSLog(@"-[AppDelegate popNewImage]");
    if (unlabelledImagePaths.count) {
        currImagePath = unlabelledImagePaths[0];
        currImage = [[NSImage alloc] initWithContentsOfFile:[currImagePath stringByExpandingTildeInPath]];
        self.clickImageViewWrapperView.image = currImage;
        self.clickImageViewWrapperView.clickImageView.mode = JNClickImageViewClickMode;
        
        currImageData = [NSMutableDictionary dictionaryWithDictionary:@{@"path":currImagePath,
                                                                        @"size":@[@(currImage.size.width), @(currImage.size.height)]}];
        
        [self displayFeature:0];
    } else {
        self.clickImageViewWrapperView.image = nil;
        self.label.stringValue = @"Done! Don't forget to save.";
        self.button.title = @"";
        self.button.enabled = NO;
    }
}

- (IBAction)buttonPressed:(id)sender {
    NSLog(@"-[AppDelegate buttonPressed:]");
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
    NSLog(@"-[AppDelegate newFile:]");
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    panel.canChooseFiles = YES;
    panel.canChooseDirectories = NO;
    panel.resolvesAliases = YES;
    panel.allowsMultipleSelection = NO;
    panel.message = @"Select the list of image files.";
    [panel beginSheetModalForWindow:self.window
                  completionHandler:^(NSInteger result) {
                      switch (result) {
                          case NSFileHandlingPanelOKButton:
                          {
                              // http://stackoverflow.com/questions/1044334/objective-c-reading-a-file-line-by-line
                              NSString *fileContents = [NSString stringWithContentsOfURL:panel.URLs[0]
                                                                                encoding:NSUTF8StringEncoding
                                                                                   error:nil];
                              NSArray *allLinedStrings = [fileContents componentsSeparatedByCharactersInSet: [NSCharacterSet newlineCharacterSet]];
                              NSArray *nonemptyLines = [allLinedStrings filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSString *evaluatedObject, NSDictionary *bindings) {
                                  return ![evaluatedObject isEqualToString:@""];
                              }]];
                              
                              [self resume:@{ @"unlabelled" : [NSMutableArray arrayWithArray:nonemptyLines],
                                              @"labelled"   : [NSMutableArray array]}];
                          }
                              break;
                          case NSFileHandlingPanelCancelButton:
                              break;
                          default:
                              @throw [[NSException alloc] init];
                      }
                  }];
}

- (IBAction)openFile:(id)sender {
    NSLog(@"-[AppDelegate openFile:]");
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

- (void)resume:(NSDictionary *)JSONData {
    NSLog(@"-[AppDelegate resume:]");
    labelledImageData = JSONData[@"labelled"];
    unlabelledImagePaths = JSONData[@"unlabelled"];
    [self popNewImage];
}
- (IBAction)saveFile:(id)sender {
    NSLog(@"-[AppDelegate saveFile:]");
    NSSavePanel *panel = [NSSavePanel savePanel];
    panel.canCreateDirectories = YES;
    panel.message = @"Choose a directory to save the label file.";
    [panel beginSheetModalForWindow:self.window
                  completionHandler:^(NSInteger result) {
                      switch (result) {
                          case NSFileHandlingPanelOKButton:
                          {
                              NSData *fileData = [NSJSONSerialization dataWithJSONObject:@{ @"labelled"   : labelledImageData,
                                                                                            @"unlabelled" : unlabelledImagePaths}
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
@end
