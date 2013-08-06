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
    [env setObject:[resourcesDir stringByAppendingString:@""] forKey:@"HOME"];

    
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
    
    
    // workaround for error:
    // [NSConcreteTask terminationStatus]: task still running
    // https://developer.apple.com/library/mac/#documentation/cocoa/Reference/Foundation/Classes/NSTask_Class/Reference/Reference.html
    // "It is not always possible to terminate the receiver because it might be ignoring the terminate signal. terminate sends SIGTERM."
    // BUT: "waitUntilExit: This method first checks to see if the receiver is still running using isRunning. Then it polls the current run loop using NSDefaultRunLoopMode until the task completes."
    // ... strange!
    
    [NSThread sleepForTimeInterval:1.0];
    if([task isRunning]) {
        [NSThread sleepForTimeInterval:5.0];
    }
    
    // should the error still appear in the logs: restart the app!
    
    
    NSNumber *exitCode = [NSNumber numberWithInt:[task terminationStatus]];
    NSNumber *pid = [NSNumber numberWithInt:[task processIdentifier]];
    
    NSLog(@"command exit code: %@", exitCode);
    NSLog(@"command result:\n%@", output);

    NSArray *keys = [NSArray arrayWithObjects:@"code", @"result", @"pid", @"env", @"pwd", nil];
    NSArray *objects = [NSArray arrayWithObjects:exitCode, output, pid, env, resourcesDir,  nil];
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    
    return dictionary;
}



+ (void)createDatabaseIfNotExist:(NSString*) database {
    NSDictionary *result = [Helper runCommand:[NSString stringWithFormat:@"psql --port=50725 --list | grep piecemaker2_%@", database]];
    if([[result valueForKey:@"code"] intValue] == 0 && [[result valueForKey:@"result"] length] > 0) {
        // database exist
        NSLog(@"database 'piecemaker2_%@' exists", database);        
    } else {
        // create database
        NSLog(@"database 'piecemaker2_%@' does not exist", database);
        NSDictionary *result = [Helper runCommand:[NSString stringWithFormat:@"createdb --port=50725 piecemaker2_%@", database]];
        if([[result valueForKey:@"code"] intValue] > 0) {
            [Helper showAlert:@"PostgreSQL Error (502)"
                      message:[NSString stringWithFormat:@"Unable to create database 'piecemaker2_%@'.", database]
                detailMessage:[result valueForKey:@"result"]
                         quit:TRUE];
        }
        
        // init database
        result = [Helper runCommand:[NSString stringWithFormat:@"cd app/api && rake db:migrate[%@]", database]];
        if([[result valueForKey:@"code"] intValue] > 0) {
            [Helper showAlert:@"PostgreSQL Error (503)"
                      message:[NSString stringWithFormat:@"Unable to init database 'piecemaker2_%@'.", database]
                detailMessage:[result valueForKey:@"result"]
                         quit:TRUE];
        }
    }
}

+(void)api:(NSString *)action quitOnError:(Boolean)quit {
    NSString *command = nil;
    
    if([action isEqual: @"start"]) {
        command = [NSString stringWithFormat:@"cd app/api && rake daemon[start]", nil];
        NSDictionary *result = [Helper runCommand:command];
        
    } else if ([action isEqual: @"stop"]) {
        command = [NSString stringWithFormat:@"cd app/api && rake daemon[stop]", nil];
        NSDictionary *result = [Helper runCommand:command];
    }
    

}

+ (Boolean)postgresql:(NSString *)action quitOnError:(Boolean)quit {
    NSString *workingDir = [[NSBundle mainBundle] bundlePath];
    NSString *resourcesDir = [workingDir stringByAppendingString:@"/Contents/Resources"];
    NSString *dataDir = [resourcesDir stringByAppendingString:@"/local/var/pqsql/data"];
    NSString *logFile = [resourcesDir stringByAppendingString:@"/local/var/pqsql/log.log"];
    
    NSString *command = nil;
    
    if([action isEqual: @"start"]) {
        command = [NSString stringWithFormat:@"pg_ctl start -l '%@' -D '%@'", logFile, dataDir];
    } else if ([action isEqual: @"stop"]) {
        command = [NSString stringWithFormat:@"pg_ctl stop -l '%@' -D '%@'", logFile, dataDir];
    }
    
    if(command) {
        NSDictionary *result = [Helper runCommand:command];
        if([[result valueForKey:@"code"] intValue] > 0) {
            [Helper showAlert:@"PostgreSQL Error (500)"
                      message:[NSString stringWithFormat:@"Unable to %@ PostgreSQL.", action]
                detailMessage:[result valueForKey:@"result"]
                         quit:quit];
            return false;
        } else {
            
            // be sure, the server is running ...
            if([action isEqual: @"start"]) {
                command = [NSString stringWithFormat:@"pg_ctl status -l '%@' -D '%@'", logFile, dataDir];
                NSDictionary *result = [Helper runCommand:command];
                if([[result valueForKey:@"code"] intValue] > 0) {
                    // try to start again
                    [NSThread sleepForTimeInterval:10.0];
                    [Helper postgresql:@"start" quitOnError:quit];
                } else {
                    return true;
                }
            } else {
                return true;
            }
        }
    } else {
        return false;
    }
    return false;
}

+(void)createConfigYml:(NSString*)filename sample:(NSString*)sampleFile user:(NSString*)user port:(NSString *)port quitOnError:(Boolean)quit {
    
    NSLog(@"Creating config.yml file.", nil);
    
    NSError *error;
    NSString *stringFromFile;
    stringFromFile = [[NSString alloc] initWithContentsOfFile:sampleFile encoding:NSUTF8StringEncoding error:&error];
    if(error) {
        NSLog(@"Error reading file:\n%@", error);
        [Helper showAlert:@"API Config Error (700)"
                  message:[NSString stringWithFormat:@"Unable to open configuration file in %@.", sampleFile]
            detailMessage:[error localizedDescription]
                     quit:quit];
    }
    
    // replace strings
    stringFromFile = [stringFromFile stringByReplacingOccurrencesOfString:@"port      : 5432"
                                    withString:[NSString stringWithFormat:@"port      : %@", port]];
    
    stringFromFile = [stringFromFile stringByReplacingOccurrencesOfString:@"username  : XXX"
                                    withString:[NSString stringWithFormat:@"username  : %@", user]];
    
    
    stringFromFile = [stringFromFile stringByReplacingOccurrencesOfString:@"password  : XXX"
                                    withString:[NSString stringWithFormat:@"password  : ", nil]];
    
    // write file back
    error = nil;
    [stringFromFile writeToFile:filename atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if(error) {
        NSLog(@"Error writing file:\n%@", error);
        [Helper showAlert:@"API Config Error (701)"
                  message:[NSString stringWithFormat:@"Unable to update configuration file in %@.", filename]
            detailMessage:[error localizedDescription]
                     quit:quit];
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
    NSString *alternateButtonString = [detailText length] > 0 ? @"Details" : nil;
    
        
    
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
