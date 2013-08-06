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
    if(1==1) {
        error = nil;
        [fileManager removeItemAtPath:[resourcesDir stringByAppendingString:@"/local/var/pqsql"] error:&error];
        if(error) {
            NSLog(@"removing data dir failed:\n%@", error);
        }
    }
    // ------------------------------------------------
    
    
    
    // first, make sure the connection settings in config.yml are correct
    // config.yml exists?
    NSString *configYml = [resourcesDir stringByAppendingString:@"/app/api/config/config.yml"];
    NSString *configSampleYml = [resourcesDir stringByAppendingString:@"/app/api/config/config.sample.yml"];
    if(![fileManager fileExistsAtPath:configYml]) {
        // no ... create from sample config file
        [Helper createConfigYml:configYml sample:configSampleYml user:NSUserName() port:@"50725" quitOnError:TRUE];
    }
    
    
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
    
    
    // see if tables exist? ... and create if not
    // ------------------------------------------
    [Helper createDatabaseIfNotExist:@"prod"];
    [Helper createDatabaseIfNotExist:@"test"];
    [Helper createDatabaseIfNotExist:@"dev"];
    
    
    // ------------------------------------------------------------------------
    
    
    
    // start api
    // ---------
    [Helper api:@"start" quitOnError:TRUE];
    
}



- (void)applicationWillTerminate:(NSNotification *)notification {
    NSLog(@"Trying to shutdown api");
    [Helper api:@"stop" quitOnError:FALSE];
    
    NSLog(@"Trying to shutdown postgres server");
    [Helper postgresql:@"stop" quitOnError:FALSE];
}



/*


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
