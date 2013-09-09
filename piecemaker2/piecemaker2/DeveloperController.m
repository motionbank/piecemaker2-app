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
@synthesize recorderController = _recorderController;

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
    
    [_output setEditable:TRUE];
    [_output insertText:[NSString stringWithFormat:@"$ %@\n%@\n", [sender stringValue], [result valueForKey:@"result"]]];
    [_output setEditable:FALSE];
}

- (IBAction)clearBtn:(id)sender {
    [_output setEditable:TRUE];
    [_output setString:@""];
    [_output setEditable:FALSE];
}

- (IBAction)getEnvInfoBtn:(id)sender {
    [_output setEditable:TRUE];

    NSDictionary *result = [Helper runCommand:@"pwd" waitUntilExit:TRUE];
    [_output insertText:[NSString stringWithFormat:@"$ pwd\n%@\n", [result valueForKey:@"result"]]];
  
    result = [Helper runCommand:@"which ruby" waitUntilExit:TRUE];
    [_output insertText:[NSString stringWithFormat:@"$ which ruby\n%@\n", [result valueForKey:@"result"]]];
    
    result = [Helper runCommand:@"ruby -v" waitUntilExit:TRUE];
    [_output insertText:[NSString stringWithFormat:@"$ ruby -v\n%@\n", [result valueForKey:@"result"]]];
    
    result = [Helper runCommand:@"which rake" waitUntilExit:TRUE];
    [_output insertText:[NSString stringWithFormat:@"$ which rake\n%@\n", [result valueForKey:@"result"]]];
    
    result = [Helper runCommand:@"which bundle" waitUntilExit:TRUE];
    [_output insertText:[NSString stringWithFormat:@"$ which bundle\n%@\n", [result valueForKey:@"result"]]];

    result = [Helper runCommand:@"cd app/api && bundle show pg" waitUntilExit:TRUE];
    [_output insertText:[NSString stringWithFormat:@"$ cd app/api && bundle show pg\n%@\n",
                         [result valueForKey:@"result"]]];
    
    result = [Helper runCommand:@"gem env" waitUntilExit:TRUE];
    [_output insertText:[NSString stringWithFormat:@"$ gem env\n%@\n", [result valueForKey:@"result"]]];
    
    [_output setEditable:FALSE];
}

- (IBAction)runSpecsBtn:(id)sender {
    NSDictionary *result = [Helper runCommand:@"cd app/api && rake spec:now" waitUntilExit:TRUE];
    
    [_output setEditable:TRUE];
    [_output setString:[result valueForKey:@"result"]];
    [_output setEditable:FALSE];
}

- (IBAction)pullApi:(id)sender {
    NSDictionary *result = [Helper runCommand:@"cd app/api && git pull" waitUntilExit:TRUE];
    
    [_output setEditable:TRUE];
    [_output setString:[result valueForKey:@"result"]];
    [_output setEditable:FALSE];
}

- (IBAction)pullFrontend:(id)sender {
    NSDictionary *result = [Helper runCommand:@"cd app/frontend && git pull" waitUntilExit:TRUE];
    
    [_output setEditable:TRUE];
    [_output setString:[result valueForKey:@"result"]];
    [_output setEditable:FALSE];
}
- (IBAction)createSuperAdmin:(id)sender {
    [_output setEditable:TRUE];
    
    NSDictionary *result = [Helper runCommand:@"cd app/api && rake db:create_super_admin[prod]" waitUntilExit:TRUE];
    [_output insertText:[NSString stringWithFormat:@"%@\n", [result valueForKey:@"result"]]];
 
    [_output setEditable:FALSE];
}

- (IBAction)startRecording:(id)sender {
    [_recorderController startRecorder];
}

- (IBAction)stopRecording:(id)sender {
    [_recorderController stopRecorder];
}


@end
