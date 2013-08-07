//
//  DeveloperController.h
//  piecemaker2
//
//  Created by Mattes on 07.08.13.
//  Copyright (c) 2013 motionbank. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface DeveloperController : NSWindowController

@property (assign) IBOutlet NSScrollView *output;

- (IBAction)sendCommand:(id)sender;
- (IBAction)clearBtn:(id)sender;
- (IBAction)getEnvInfoBtn:(id)sender;
- (IBAction)runSpecsBtn:(id)sender;
@end
