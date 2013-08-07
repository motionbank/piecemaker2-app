//
//  DeveloperController.m
//  piecemaker2
//
//  Created by Mattes on 07.08.13.
//  Copyright (c) 2013 motionbank. All rights reserved.
//

#import "DeveloperController.h"

@interface DeveloperController ()

@end

@implementation DeveloperController

@synthesize output = _output;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (IBAction)clearBtn:(id)sender {
}

- (IBAction)getEnvInfoBtn:(id)sender {
}

- (IBAction)runSpecsBtn:(id)sender {
}
@end
