//
//  DeveloperController.m
//  piecemaker2
//
//  Created by Mattes on 07.08.13.
//  Copyright (c) 2013 motionbank. All rights reserved.
//

#import "DeveloperController.h"
#import "Helper.h"

@interface DeveloperController ()

@end

@implementation DeveloperController

@synthesize output = _output;


- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
        //NSLog(@"%@", [Helper runCommand:@"which rake" waitUntilExit:TRUE]);
        //NSLog(@"%@", [Helper runCommand:@"cd app/api && bundle show pg" waitUntilExit:TRUE]);
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (IBAction)sendCommand:(NSTextField*)sender {
    
    NSDictionary *result = [Helper runCommand:[sender stringValue] waitUntilExit:TRUE];
    [sender setStringValue:@""];
    
    [_output insertText:[result valueForKey:@"result"]];

    // [result value
}

- (IBAction)clearBtn:(id)sender {

}

- (IBAction)getEnvInfoBtn:(id)sender {
    [_output insertText:@"ENV"];
}

- (IBAction)runSpecsBtn:(id)sender {
    [_output insertText:@"specs"];
}
@end
