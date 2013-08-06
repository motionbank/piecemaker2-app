//
//  AppDelegate.m
//  piecemaker2
//
//  Created by Matthias Kadenbach on 11.07.13.
//  Copyright (c) 2013 motionbank. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate
@synthesize testButton = _testButton;
@synthesize textField = _textField;

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    NSString *workingDir = [[NSBundle mainBundle] bundlePath];
    NSString *resourcesDir = [workingDir stringByAppendingString:@"/Contents/Resources"];
    NSString *bin = [resourcesDir stringByAppendingString:@"/local/bin"];
    NSString *initdb = [bin stringByAppendingString:@"/initdb"];
        
    // setup postgres databases, if local/var/pgsql/data does not exist
    // ----------------------------------------------------------------
    NSFileManager *fileManager= [NSFileManager defaultManager];
    NSError *error = nil;
    NSString *pgsqlDataDir = [resourcesDir stringByAppendingString:@"/local/var/pqsql/data"];

    
    // delete data dir for debug purposes
    // dont forget to comment-out the following line
    [fileManager removeItemAtPath:pgsqlDataDir error:&error];
    //// !!! comment-out line above!
    
    
    // data dir exists already?
    if(![ fileManager fileExistsAtPath:pgsqlDataDir]) {
         
        // no ... create it
        if(![fileManager createDirectoryAtPath:pgsqlDataDir withIntermediateDirectories:YES attributes:nil error:&error]) {
            NSLog(@"Failed to create directory \"%@\". Error: %@", pgsqlDataDir, error);
            
            // show dialog and quit
            NSAlert *alert = [NSAlert alertWithMessageText:@"PostgreSQL Init Error (100)" defaultButton:@"Quit" alternateButton:nil otherButton:nil informativeTextWithFormat:@"Unable to create data directory in %@", pgsqlDataDir];        
            if ([alert runModal] == NSAlertDefaultReturn) {
                [NSApp terminate:self];
            }
        }
        
        // now init db
        NSTask *task = [[NSTask alloc] init];
        [task setLaunchPath: initdb];
        [task setArguments: [NSArray arrayWithObjects:@"-D", pgsqlDataDir, nil]];
        
        NSPipe *pipe = [NSPipe pipe];
        [task setStandardOutput: pipe];
        NSFileHandle *file = [pipe fileHandleForReading];
        [task launch];
        NSData *data = [file readDataToEndOfFile];
        NSString *taskOutput = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
        NSLog (@"initdb returned:\n%@", taskOutput);
        
        int status = [task terminationStatus];
        if(status >= 0) {
            // show dialog and quit
            NSAlert *alert = [NSAlert alertWithMessageText:@"PostgreSQL Init Error (101)" defaultButton:@"Quit" alternateButton:@"Details" otherButton:nil informativeTextWithFormat:@"Unable to init database in %@", pgsqlDataDir];
            NSInteger returnedButton = [alert runModal];
            if (returnedButton == NSAlertDefaultReturn) {
                [NSApp terminate:self];
            }
            if (returnedButton == NSAlertAlternateReturn) {
                // show details alert and quit
                NSAlert *detailsAlert = [NSAlert alertWithMessageText:@"PostgreSQL Init Error (101)" defaultButton:@"Quit" alternateButton:nil otherButton:nil informativeTextWithFormat:@""];
                
                NSScrollView *accessory = [[NSScrollView alloc] initWithFrame:NSMakeRect(0, 0, 600, 300)];
                NSSize contentSize = [accessory contentSize];
                [accessory setBorderType:NSNoBorder];
                [accessory setHasVerticalScroller:YES];
                [accessory setHasHorizontalScroller:NO];
                [accessory setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
                
                NSTextView *theTextView = [[NSTextView alloc] initWithFrame:NSMakeRect(0, 0, contentSize.width, contentSize.height)];
                
                [theTextView setMinSize:NSMakeSize(0.0, contentSize.height)];
                [theTextView setMaxSize:NSMakeSize(FLT_MAX, FLT_MAX)];
                [theTextView setVerticallyResizable:YES];
                [theTextView setHorizontallyResizable:NO];
                [theTextView setAutoresizingMask:NSViewWidthSizable];
                [theTextView setBackgroundColor:[NSColor windowBackgroundColor]];
                [[theTextView textContainer]
                 setContainerSize:NSMakeSize(contentSize.width, FLT_MAX)];
                [[theTextView textContainer] setWidthTracksTextView:YES];
            
                [theTextView setFont:[NSFont fontWithName:@"Menlo" size:11]];
                [theTextView insertText:taskOutput];
                [theTextView setEditable:NO];
                
                [accessory setDocumentView:theTextView];
                [detailsAlert setAccessoryView:accessory];
                
                if ([detailsAlert runModal] == NSAlertDefaultReturn) {
                    [NSApp terminate:self];
                }
            }
        }
    }
}


-(IBAction)testButton:(id)sender {
    NSString *workingDir = [[NSBundle mainBundle] bundlePath];
    NSString *resourcesDir = [workingDir stringByAppendingString:@"/Contents/Resources"];
    // NSString *bin = [resourcesDir stringByAppendingString:@"/local/bin"];
    
    NSString *ruby = [resourcesDir stringByAppendingString:@"/local/bin/ruby"];
    
    // NSString *node = [NSString stringWithFormat:@"cd %@ && ./local/bin/node", resourcesDir];
    
    _textField.stringValue = [NSString stringWithFormat:@"workingDir:\n%@\n\nwhich ruby:\n%@\n\nstdout:\n%@", workingDir, ruby, @"waiting..."];
    
    NSTask *task;
    task = [[NSTask alloc] init];
    [task setLaunchPath: ruby];

    NSArray *arguments;
    arguments = [NSArray arrayWithObjects: [resourcesDir stringByAppendingString:@"/app/test.rb"], nil];
    [task setArguments: arguments];
    
    NSPipe *pipe;
    pipe = [NSPipe pipe];
    [task setStandardOutput: pipe];
    
    NSFileHandle *file;
    file = [pipe fileHandleForReading];
    
    [task launch];
    
    NSData *data;
    data = [file readDataToEndOfFile];
    
    NSString *taskOutput;
    taskOutput = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
    NSLog (@"task returned:\n%@", taskOutput);
    
    _textField.stringValue = [NSString stringWithFormat:@"workingDir:\n%@\n\nwhich ruby:\n%@\n\nstdout:\n%@", workingDir, ruby, taskOutput];
}

@end
