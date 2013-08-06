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
    NSFileManager *fileManager= [NSFileManager defaultManager];
    NSError *error = nil;
    
    NSString *pgsqlDataDir = [resourcesDir stringByAppendingString:@"/local/var/pqsql/data"];

    // delete data dir for debug purposes
    // dont forget to comment-out the following line
    [fileManager removeItemAtPath:pgsqlDataDir error:&error];
    
    // data dir exists already?
    if(![ fileManager fileExistsAtPath:pgsqlDataDir]) {
         
        // no ... create it
        if(![fileManager createDirectoryAtPath:pgsqlDataDir withIntermediateDirectories:YES attributes:nil error:&error]) {
            // An error has occurred, do something to handle it
            NSLog(@"Failed to create directory \"%@\". Error: %@", pgsqlDataDir, error);
            
            // show dialog
            NSAlert *alert = [NSAlert alertWithMessageText:@"PostgreSQL Init Error (100)" defaultButton:@"Quit" alternateButton:nil otherButton:nil informativeTextWithFormat:@"Unable to create data directory in %@", pgsqlDataDir];        

            if ([alert runModal] == NSAlertDefaultReturn) {
                [NSApp terminate:self];
            }
        }
        
        // now init db
        NSTask *task;
        task = [[NSTask alloc] init];
        [task setLaunchPath: initdb];
        NSArray *arguments;
        arguments = [NSArray arrayWithObjects:@"-D", pgsqlDataDir, nil];
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
        NSLog (@"initdb returned:\n%@", taskOutput);
        
        int status = [task terminationStatus];
        if(status >= 0) {
            // show dialog
            NSAlert *alert = [NSAlert alertWithMessageText:@"PostgreSQL Init Error (101)" defaultButton:@"Quit" alternateButton:nil otherButton:nil informativeTextWithFormat:@"Unable to init database in %@", pgsqlDataDir];
            if ([alert runModal] == NSAlertDefaultReturn) {
                [NSApp terminate:self];
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
