//
//  ApiController.m
//  piecemaker2
//
//  Created by Mattes on 07.08.13.
//  Copyright (c) 2013 motionbank. All rights reserved.
//

#import "ApiController.h"

@interface ApiController ()

@end

@implementation ApiController

@synthesize apiview = _apiview;

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
    [[_apiview mainFrame] loadRequest:[NSURLRequest requestWithURL:
                                       [NSURL URLWithString:@"http://0.0.0.0:50726/index.html"]]];
}

@end
