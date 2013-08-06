//
//  AppDelegate.m
//  piecemaker2
//
//  Created by Matthias Kadenbach on 11.07.13.
//  Copyright (c) 2013 motionbank. All rights reserved.
//

#import "AppDelegate.h"
#import "Helper.h"

@implementation AppDelegate
//@synthesize testButton = _testButton;
//@synthesize textField = _textField;


- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    NSString *workingDir = [[NSBundle mainBundle] bundlePath];
    NSString *resourcesDir = [workingDir stringByAppendingString:@"/Contents/Resources"];
    
    NSError *error;
    NSFileManager *fileManager= [NSFileManager defaultManager];
    NSString *dataDir = [resourcesDir stringByAppendingString:@"/local/var/pqsql/data"];
    
    
    // debugging area
    // (dont forget to comment-out the following lines)
    // ------------------------------------------------
    if(1==2) {
        error = nil;
        [fileManager removeItemAtPath:[resourcesDir stringByAppendingString:@"/local/var/pqsql"] error:&error];
        if(error) {
            NSLog(@"removing data dir failed:\n%@", error);
        }
    }
    // ------------------------------------------------
    
    
    
    
    // data dir exists?
    // ----------------

    if(![fileManager fileExistsAtPath:dataDir]) {
        // data dir is missing ... create new directory now
        error = nil;
        if(![fileManager createDirectoryAtPath:dataDir withIntermediateDirectories:YES attributes:nil error:&error]) {
            NSLog(@"Failed to create data dir \"%@\". Error: %@", dataDir, error);
            [Helper showAlert:@"PostgreSQL Init Error (100)"
                      message:[NSString stringWithFormat:@"Unable to create data directory in %@", dataDir]
                detailMessage:nil
                         quit:TRUE];
        }
        
        // use this new directory as data dir for postgresql
        NSDictionary *result = [Helper runCommand:@"initdb --auth=trust -D local/var/pqsql/data"];
        if([[result valueForKey:@"code"] intValue] > 0) {
            [Helper showAlert:@"PostgreSQL Init Error (101)"
                      message:[NSString stringWithFormat:@"Unable to init data dir in %@", dataDir]
                detailMessage:[result valueForKey:@"result"]
                         quit:TRUE];
        }
        
        // we then need to update postgresql.conf
        [Helper updatePostgresqlConf:@"/local/var/pqsql/data/postgresql.conf" quitOnError:TRUE port:@"50725"];
    }
    
    
    // lets start the postgres server now
    // ----------------------------------
    [Helper postgresql:@"start" quitOnError:TRUE];
    
    
    // see if tables exist?
    // -------------------
    
    
    
}



- (void)applicationWillTerminate:(NSNotification *)notification {
    NSLog(@"Trying to shutdown postgres server");
    [Helper postgresql:@"stop" quitOnError:FALSE];
}

/*

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    NSString *workingDir = [[NSBundle mainBundle] bundlePath];
    NSString *resourcesDir = [workingDir stringByAppendingString:@"/Contents/Resources"];
    NSString *bin = [resourcesDir stringByAppendingString:@"/local/bin"];
    NSString *initdb = [bin stringByAppendingString:@"/initdb"];
    NSString *rake = [bin stringByAppendingString:@"/rake"];
    NSString *rakeFile = [resourcesDir stringByAppendingString:@"/local/app/api/Rakefile"];
    NSString *createdb = [bin stringByAppendingString:@"/createdb"];
    
    
    // setup postgres databases, if local/var/pgsql/data does not exist
    // ----------------------------------------------------------------
    NSFileManager *fileManager= [NSFileManager defaultManager];
    NSError *error = nil;
    NSString *pgsqlDataDir = [resourcesDir stringByAppendingString:@"/local/var/pqsql/data"];

    
    // delete data dir for debug purposes
    // dont forget to comment-out the following line
    [fileManager removeItemAtPath:pgsqlDataDir error:&error];
    if(error)
        NSLog(@"remove data dir:\n%@", error);
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
        
        if(status > 0) {
            // show dialog and quit

            [self showAlert:@"PostgreSQL Init Error (101)" message:[NSString stringWithFormat:@"Unable to init database in %@", pgsqlDataDir] detailMessage:taskOutput quit:TRUE];
            
        } else {
            // init db worked ...
            
            // we need to update postgresql.conf
            NSError *error;
            NSString *stringFromFile;
            NSString *stringFilepath = [resourcesDir stringByAppendingString:@"/local/var/pqsql/data/postgresql.conf"];
            stringFromFile = [[NSString alloc] initWithContentsOfFile:stringFilepath encoding:NSUTF8StringEncoding error:&error];
            
            if(error) {
                NSLog(@"error %@", error);
                
                // show dialog and quit
                NSAlert *alert = [NSAlert alertWithMessageText:@"PostgreSQL Init Error (102)" defaultButton:@"Quit" alternateButton:nil otherButton:nil informativeTextWithFormat:@"Unable to read configuration in %@.\n\n %@", stringFilepath, [error localizedDescription]];
                if ([alert runModal] == NSAlertDefaultReturn) {
                    [NSApp terminate:self];
                }
            }
            
            // replace strings
            stringFromFile = [stringFromFile stringByReplacingOccurrencesOfString:@"#port = 5432"
                                                               withString:@"port = 50725"];
            
            stringFromFile = [stringFromFile stringByReplacingOccurrencesOfString:@"#listen_addresses = 'localhost'"
                                                                       withString:@"listen_addresses = 'localhost'"];
            
            // write file back
            [stringFromFile writeToFile:stringFilepath atomically:YES encoding:NSUTF8StringEncoding error:&error];
            // NSLog (@"replacement in %@:\n%@", stringFilepath, stringFromFile);
            
            if(error) {
                NSLog(@"error %@", error);
                
                // show dialog and quit
                NSAlert *alert = [NSAlert alertWithMessageText:@"PostgreSQL Init Error (103)" defaultButton:@"Quit" alternateButton:nil otherButton:nil informativeTextWithFormat:@"Unable to update configuration in %@.\n\n %@", stringFilepath, [error localizedDescription]];
                if ([alert runModal] == NSAlertDefaultReturn) {
                    [NSApp terminate:self];
                }
            }
            
            // start postgres server and create databases
            Boolean success = [self postgresql:@"start"];
            
            if(!success) {
                // show dialog and quit
                [self showAlert:@"PostgreSQL Init Error (104)" message:[NSString stringWithFormat:@"Unable to start PostgreSQL for database creation."] detailMessage:@"" quit:TRUE];
            }
            else {
                // create databases
                NSTask *task = [[NSTask alloc] init];
                [task setLaunchPath: createdb];
                [task setArguments:
                 [NSArray arrayWithObjects:@"--host=localhost", @"--port=50725", @"piecemaker2_test", nil]];
                [task waitUntilExit];
                NSPipe *pipe = [NSPipe pipe];
                [task setStandardOutput: pipe];
                NSFileHandle *file = [pipe fileHandleForReading];
                [task launch];
                NSData *data = [file readDataToEndOfFile];
                NSString *taskOutput = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
                NSLog (@"createdb returned:\n%@", taskOutput);
                int status = [task terminationStatus];
                //if(status > 0) {
                    // show dialog and quit
                 //   [self showAlert:@"PostgreSQL Init Error (105)" message:[NSString stringWithFormat:@"Unable to create database 'piecemaker2_test'", nil] detailMessage:taskOutput quit:TRUE];
                //}
                
                
                task = [[NSTask alloc] init];
                [task setLaunchPath: createdb];
                [task setArguments:
                 [NSArray arrayWithObjects:@"--host=localhost", @"--port=50725", @"piecemaker2_prod", nil]];
                [task waitUntilExit];
                pipe = [NSPipe pipe];
                [task setStandardOutput: pipe];
                file = [pipe fileHandleForReading];
                [task launch];
                data = [file readDataToEndOfFile];
                taskOutput = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
                NSLog (@"createdb returned:\n%@", taskOutput);
                status = [task terminationStatus];
                //if(status > 0) {
                    // show dialog and quit
                 //   [self showAlert:@"PostgreSQL Init Error (106)" message:[NSString stringWithFormat:@"Unable to create database 'piecemaker2_prod'", nil] detailMessage:taskOutput quit:TRUE];
                //}
                
                task = [[NSTask alloc] init];
                [task setLaunchPath: createdb];
                [task setArguments:
                 [NSArray arrayWithObjects:@"--host=localhost", @"--port=50725", @"piecemaker2_dev", nil]];
                [task waitUntilExit];
                pipe = [NSPipe pipe];
                [task setStandardOutput: pipe];
                file = [pipe fileHandleForReading];
                [task launch];
                data = [file readDataToEndOfFile];
                taskOutput = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
                NSLog (@"createdb returned:\n%@", taskOutput);
                status = [task terminationStatus];
                //if(status > 0) {
                    // show dialog and quit
                  //  [self showAlert:@"PostgreSQL Init Error (107)" message:[NSString stringWithFormat:@"Unable to create database 'piecemaker2_dev'", nil] detailMessage:taskOutput quit:TRUE];
                //}
                
                // init databases
                // --------------
                task = [[NSTask alloc] init];
                [task setLaunchPath: rake];
                [task setArguments:
                 [NSArray arrayWithObjects:@"-f", rakeFile, @"db:migrate[test]", nil]];
                [task waitUntilExit];
                pipe = [NSPipe pipe];
                [task setStandardOutput: pipe];
                file = [pipe fileHandleForReading];
                [task launch];
                data = [file readDataToEndOfFile];
                taskOutput = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
                NSLog (@"rake returned:\n%@", taskOutput);
                status = [task terminationStatus];
                //if(status > 0) {
                // show dialog and quit
                //    [self showAlert:@"API Init Error (100)" message:[NSString stringWithFormat:@"Unable to create tables in database 'piecemaker2_test'", nil] detailMessage:taskOutput quit:TRUE];
                //}
                
                
                task = [[NSTask alloc] init];
                [task setLaunchPath: rake];
                [task setArguments:
                 [NSArray arrayWithObjects:@"-f", rakeFile, @"db:migrate[prod]", nil]];
                [task waitUntilExit];
                pipe = [NSPipe pipe];
                [task setStandardOutput: pipe];
                file = [pipe fileHandleForReading];
                [task launch];
                data = [file readDataToEndOfFile];
                taskOutput = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
                NSLog (@"rake returned:\n%@", taskOutput);
                status = [task terminationStatus];
                //if(status > 0) {
                // show dialog and quit
                //    [self showAlert:@"API Init Error (101)" message:[NSString stringWithFormat:@"Unable to create tables in database 'piecemaker2_prod'", nil] detailMessage:taskOutput quit:TRUE];
                //}
                
                
                task = [[NSTask alloc] init];
                [task setLaunchPath: rake];
                [task setArguments:
                 [NSArray arrayWithObjects:@"-f", rakeFile, @"db:migrate[dev]", nil]];
                [task waitUntilExit];
                pipe = [NSPipe pipe];
                [task setStandardOutput: pipe];
                file = [pipe fileHandleForReading];
                [task launch];
                data = [file readDataToEndOfFile];
                taskOutput = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
                NSLog (@"rake returned:\n%@", taskOutput);
                status = [task terminationStatus];
                //if(status > 0) {
                // show dialog and quit
                //    [self showAlert:@"API Init Error (102)" message:[NSString stringWithFormat:@"Unable to create tables in database 'piecemaker2_dev'", nil] detailMessage:taskOutput quit:TRUE];
                //}
            }
        
                        
            // stop postgres server again
            success = [self postgresql:@"stop"];
            
            if(!success) {
                // show dialog and quit
                [self showAlert:@"PostgreSQL Init Error (108)" message:[NSString stringWithFormat:@"Unable to stop PostgreSQL after database creation."] detailMessage:@"" quit:TRUE];
            }
            
        }
        
    }
    
    // start postgres server
    Boolean success = [self postgresql:@"start"];
    
    if(!success) {
        // show dialog and quit
        [self showAlert:@"PostgreSQL Error (100)" message:[NSString stringWithFormat:@"Unable to start PostgreSQL server."] detailMessage:@"" quit:TRUE];
    }
    
    // start api
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath: createdb];
    [task setArguments:
     [NSArray arrayWithObjects:@"--host=localhost", @"--port=50725", @"piecemaker2_test", nil]];
    
    NSPipe *pipe = [NSPipe pipe];
    [task setStandardOutput: pipe];
    NSFileHandle *file = [pipe fileHandleForReading];
    [task launch];
    NSData *data = [file readDataToEndOfFile];
    NSString *taskOutput = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
    NSLog (@"createdb returned:\n%@", taskOutput);
    int status = [task terminationStatus];
    if(status > 0) {
        // show dialog and quit
        [self showAlert:@"PostgreSQL Init Error (105)" message:[NSString stringWithFormat:@"Unable to create database 'piecemaker2_test'", nil] detailMessage:taskOutput quit:TRUE];
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
*/

@end
