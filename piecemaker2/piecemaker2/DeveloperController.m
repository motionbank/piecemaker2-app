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
@synthesize webView = _webView;

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

- (IBAction)resetIndex:(id)sender {
    [[_webView mainFrame] loadRequest:[NSURLRequest requestWithURL:
                                       [NSURL URLWithString:@"http://0.0.0.0:50726/index.html"]]];
}

- (IBAction)sendCommand:(id)sender {
    NSDictionary *result = [Helper runCommand:[sender stringValue] waitUntilExit:TRUE];
    [_output setString:[result valueForKey:@"result"]];
}

- (IBAction)clearBtn:(id)sender {
    [_output setString:@""];
}

- (IBAction)getEnvInfoBtn:(id)sender {


    NSDictionary *result = [Helper runCommand:@"pwd" waitUntilExit:TRUE];
    [_output insertText:[NSString stringWithFormat:@"$ pwd returned:\n%@\n\n", [result valueForKey:@"result"]]];
  
    result = [Helper runCommand:@"which ruby" waitUntilExit:TRUE];
    [_output insertText:[NSString stringWithFormat:@"$ which ruby returned:\n%@\n\n", [result valueForKey:@"result"]]];
    
    result = [Helper runCommand:@"ruby -v" waitUntilExit:TRUE];
    [_output insertText:[NSString stringWithFormat:@"$ ruby -v returned:\n%@\n\n", [result valueForKey:@"result"]]];
    
    result = [Helper runCommand:@"which rake" waitUntilExit:TRUE];
    [_output insertText:[NSString stringWithFormat:@"$ which rake returned:\n%@\n\n", [result valueForKey:@"result"]]];

    result = [Helper runCommand:@"cd app/api && bundle show pg" waitUntilExit:TRUE];
    [_output insertText:[NSString stringWithFormat:@"$ cd app/api && bundle show pg returned:\n%@\n\n", [result valueForKey:@"result"]]];
    
}

- (IBAction)runSpecsBtn:(id)sender {
    NSDictionary *result = [Helper runCommand:@"cd app/api && rake spec:now" waitUntilExit:TRUE];
    [_output setString:[result valueForKey:@"result"]];
}
@end
