//
//  ApiController.h
//  piecemaker2
//
//  Created by Mattes on 07.08.13.
//  Copyright (c) 2013 motionbank. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Webkit/WebKit.h>
#import "RecorderController.h"

@interface ApiController : NSWindowController

@property (assign) IBOutlet WebView *apiview;
- (IBAction)resetIndexHtml:(id)sender;


@property (assign) RecorderController *recorderController;
@end
