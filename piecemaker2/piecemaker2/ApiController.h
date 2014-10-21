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

// add private web preferences
@interface WebPreferences (WebPrivate)

- (BOOL)webGLEnabled;
- (void)setWebGLEnabled:(BOOL)enabled;

- (BOOL)localStorageEnabled;
- (void)setLocalStorageEnabled:(BOOL)localStorageEnabled;

- (NSString *)_localStorageDatabasePath;
- (void)_setLocalStorageDatabasePath:(NSString *)path;

- (void)setDatabasesEnabled:(BOOL)enabled;
- (void)setDeveloperExtrasEnabled:(BOOL)enabled;
@end
