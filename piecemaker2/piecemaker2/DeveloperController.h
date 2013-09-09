//
//  DeveloperController.h
//  piecemaker2
//
//  Created by Mattes on 07.08.13.
//  Copyright (c) 2013 motionbank. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Webkit/WebKit.h>
#import "RecorderController.h"

@interface DeveloperController : NSWindowController

@property (unsafe_unretained) IBOutlet NSTextView *output;

- (IBAction)resetIndex:(id)sender;

- (IBAction)sendCommand:(id)sender;
- (IBAction)clearBtn:(id)sender;
- (IBAction)getEnvInfoBtn:(id)sender;
- (IBAction)runSpecsBtn:(id)sender;
- (IBAction)pullApi:(id)sender;
- (IBAction)pullFrontend:(id)sender;
- (IBAction)startRecording:(id)sender;
- (IBAction)stopRecording:(id)sender;
- (IBAction)createSuperAdmin:(id)sender;


@property (assign) WebView *webView;
@property (assign) RecorderController *recorderController;

@end
