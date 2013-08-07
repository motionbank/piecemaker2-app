//
//  AppDelegate.h
//  piecemaker2
//
//  Created by Matthias Kadenbach on 11.07.13.
//  Copyright (c) 2013 motionbank. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class DeveloperController;
@class ApiController;
@class RecorderController;

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;

@property (assign) IBOutlet NSProgressIndicator *progressInd;
@property (assign) IBOutlet NSButton *startingBtn;
@property (assign) IBOutlet NSPathControl *path;

@property (assign) IBOutlet NSMenuItem *recorderMenuItem;

@property (assign) IBOutlet NSMenuItem *developerMenuItem;

@property (assign) IBOutlet NSMenuItem *apiMenuItem;


@property DeveloperController *developerController;
@property ApiController *apiController;
@property RecorderController *recorderController;





@end
