//
//  Helper.m
//  piecemaker2
//
//  Created by Mattes on 06.08.13.
//  Copyright (c) 2013 motionbank. All rights reserved.
//

#import "Helper.h"

@implementation Helper


+ (NSDictionary*)runCommand:(NSString*) commandToRun {
    NSString *workingDir = [[NSBundle mainBundle] bundlePath];
    NSString *resourcesDir = [workingDir stringByAppendingString:@"/Contents/Resources"];
    NSString *bin = [resourcesDir stringByAppendingString:@"/local/bin"];
    
    NSMutableDictionary *env = [[NSMutableDictionary alloc] init];
    [env setObject:[bin stringByAppendingString:@":/usr/bin:/usr/sbin:/bin"] forKey:@"PATH"];

    
    NSTask *task;
    task = [[NSTask alloc] init];
    [task setLaunchPath: @"/bin/bash"];
    
    NSArray *arguments = [NSArray arrayWithObjects:
                          @"-c" ,
                          [NSString stringWithFormat:@"%@", commandToRun],
                          nil];
    [task setArguments: arguments];
    [task setCurrentDirectoryPath:resourcesDir];
    [task setEnvironment:env];
    
    NSLog(@"run command: %@", commandToRun);
    
    [task waitUntilExit];
    
    NSPipe *pipe;
    pipe = [NSPipe pipe];
    [task setStandardOutput: pipe];
    
    NSFileHandle *file;
    file = [pipe fileHandleForReading];
    
    [task launch];
    
    NSData *data;
    data = [file readDataToEndOfFile];
    
    NSString *output;
    output = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
    
    [task terminate];
    
    NSNumber *exitCode = [NSNumber numberWithInt:[task terminationStatus]];
    NSNumber *pid = [NSNumber numberWithInt:[task processIdentifier]];
    
    NSLog(@"command exit code: %@", exitCode);
    NSLog(@"command result:\n%@", output);

    NSArray *keys = [NSArray arrayWithObjects:@"code", @"result", @"pid", @"env", @"pwd", nil];
    NSArray *objects = [NSArray arrayWithObjects:exitCode, output, pid, env, resourcesDir,  nil];
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    
    return dictionary;
}




+ (Boolean)postgresql:(NSString *)action {
    NSString *workingDir = [[NSBundle mainBundle] bundlePath];
    NSString *resourcesDir = [workingDir stringByAppendingString:@"/Contents/Resources"];
    NSString *bin = [resourcesDir stringByAppendingString:@"/local/bin"];
    NSString *pg_ctl = [bin stringByAppendingString:@"/pg_ctl"];
    NSString *pgsqlDataDir = [resourcesDir stringByAppendingString:@"/local/var/pqsql/data"];
    NSString *pgsqlLogFile = [resourcesDir stringByAppendingString:@"/local/var/pqsql/log.log"];
    

    // start postgres server and create databases
    NSTask *postgresTask = [[NSTask alloc] init];
    [postgresTask setLaunchPath: pg_ctl];
    
    if([action isEqual: @"start"]) {
        [postgresTask setArguments: [NSArray arrayWithObjects:@"start", @"-D", pgsqlDataDir, @"-l", pgsqlLogFile, nil]];
    } else if ([action isEqual: @"stop"]) {
        [postgresTask setArguments: [NSArray arrayWithObjects:@"stop", @"-D", pgsqlDataDir, @"-l", pgsqlLogFile, nil]];
    }
    
    // [postgresTask waitUntilExit];
    
    NSPipe *pipe = [NSPipe pipe];
    [postgresTask setStandardOutput: pipe];
    NSFileHandle *file = [pipe fileHandleForReading];
    [postgresTask launch];
    NSData *data = [file readDataToEndOfFile];
    NSString *taskOutput = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
    NSLog (@"pg_ctl returned:\n%@", taskOutput);
    int status = [postgresTask terminationStatus];
    
    if(status > 0) {
        return false;
    }
    else {
        return true;
    }
}




+(void)updatePostgresqlConf:(NSString* )filename quitOnError:(Boolean)quit port:(NSString *)port {
    NSString *workingDir = [[NSBundle mainBundle] bundlePath];
    NSString *resourcesDir = [workingDir stringByAppendingString:@"/Contents/Resources"];
    
    NSString *stringFromFile;
    NSString *stringFilepath = [resourcesDir stringByAppendingString:filename];
    NSError *error;
    stringFromFile = [[NSString alloc] initWithContentsOfFile:stringFilepath encoding:NSUTF8StringEncoding error:&error];
    if(error) {
        NSLog(@"Error reading file:\n%@", error);
        [Helper showAlert:@"PostgreSQL Init Error (150)"
                  message:[NSString stringWithFormat:@"Unable to open configuration file in %@.", stringFilepath]
            detailMessage:[error localizedDescription]
                     quit:quit];
    }
    
    // replace strings
    stringFromFile = [stringFromFile stringByReplacingOccurrencesOfString:@"#port = 5432"
                                                               withString:[NSString stringWithFormat:@"port = %@", port]];
    
    stringFromFile = [stringFromFile stringByReplacingOccurrencesOfString:@"#listen_addresses = 'localhost'"
                                                               withString:@"listen_addresses = 'localhost'"];
    
    // write file back
    error = nil;
    [stringFromFile writeToFile:stringFilepath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if(error) {
        NSLog(@"Error writing file:\n%@", error);
        [Helper showAlert:@"PostgreSQL Init Error (151)"
                  message:[NSString stringWithFormat:@"Unable to update configuration file in %@.", stringFilepath]
            detailMessage:[error localizedDescription]
                     quit:quit];
    }
}




+(void)showAlert:(NSString *)messageText
         message:(NSString *)informativeText
   detailMessage:(NSString *)detailText
            quit:(Boolean)quit {
    
    NSString *defaultButtonString = quit ? @"Quit" : @"OK";
    NSString *alternateButtonString = detailText ? @"Details" : nil;
    
        
    
    NSAlert *alert = [NSAlert alertWithMessageText:messageText defaultButton:defaultButtonString alternateButton:alternateButtonString otherButton:nil informativeTextWithFormat:informativeText, nil];
    NSInteger returnedButton = [alert runModal];
    
    if (returnedButton == NSAlertDefaultReturn) {
        if(quit) [NSApp terminate:self];
    }
    
    if (returnedButton == NSAlertAlternateReturn) {
        // show details alert
        NSAlert *detailsAlert = [NSAlert alertWithMessageText:messageText defaultButton:defaultButtonString alternateButton:nil otherButton:nil informativeTextWithFormat:@""];
        
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
        [theTextView insertText:detailText];
        [theTextView setEditable:NO];
        
        [accessory setDocumentView:theTextView];
        [detailsAlert setAccessoryView:accessory];
        
        if ([detailsAlert runModal] == NSAlertDefaultReturn) {
            if(quit) [NSApp terminate:self];
        }
    }
}


@end
