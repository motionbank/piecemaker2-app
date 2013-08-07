//
//  AppDelegate.m
//  piecemaker2
//
//  Created by Matthias Kadenbach on 11.07.13.
//  Copyright (c) 2013 motionbank. All rights reserved.
//

#import "AppDelegate.h"
#import "Helper.h"
#import "DeveloperController.h"
#import "ApiController.h"
#import "RecorderController.h"

@implementation AppDelegate
@synthesize progressInd = _progressInd;
@synthesize startingBtn = _startingBtn;
@synthesize path = _path;
@synthesize developerController = _developerController;
@synthesize apiController = _apiController;
@synthesize recorderController = _recorderController;
@synthesize recorderMenuItem = _recorderMenuItem;


// menu item events
// ----------------
- (IBAction)showDownloads:(id)sender {
    if(!_developerController) {
        _developerController = [[DeveloperController alloc] initWithWindowNibName:@"DeveloperController"];
    }
    [_developerController showWindow:self];
}
- (IBAction)showApi:(id)sender {
    if(!_apiController) {
        _apiController = [[ApiController alloc] initWithWindowNibName:@"ApiController"];
    }
    [_apiController showWindow:self];
}
- (IBAction)showRecorder:(id)sender {
    if(!_recorderController) {
        _recorderController = [[RecorderController alloc] initWithWindowNibName:@"RecorderController"];
    }
    [_recorderController showWindow:self];
}


// path selection (and start button) events
// ----------------------------------------
- (IBAction)pathUpdated:(id)sender {
    [_path setURL:[[_path clickedPathComponentCell] URL]];
    [self updateStartButtonState];
}
- (IBAction)startingBtnClicked:(id)sender {
    [_progressInd startAnimation:self];
    [_startingBtn setTitle:@"Starting now"];
    [_startingBtn setEnabled:FALSE];
    [_path setEnabled:FALSE];
    
    [self start];
}
-(void)updateStartButtonState {
    // verify URL ...
    // @todo
    if([_path URL]) {
        [_startingBtn setEnabled:TRUE];
    } else {
        [_startingBtn setEnabled:FALSE];
    }
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    [self updateStartButtonState];
    
    // actually, setEnable would make more sense here, but its not working
    [_recorderMenuItem setHidden:TRUE];
    [_apiMenuItem setHidden:TRUE];
}

- (void)applicationWillTerminate:(NSNotification *)notification {
    [self stop];
}

// api is ready
-(void)ready {
    // actually, setEnable would make more sense here, but its not working
    [_recorderMenuItem setHidden:FALSE];
    [_apiMenuItem setHidden:FALSE];
    
    [_window setIsVisible:FALSE];
    [self showApi:self];
}




// Startup process
// ===============


// start api
-(void)start {
    [self ready];
    return;
    
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
        NSDictionary *result = [Helper runCommand:@"initdb --auth=trust -D local/var/pqsql/data" waitUntilExit:TRUE];
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


// stop api
-(void)stop {
    return;
    
    NSLog(@"Trying to shutdown api");
    [Helper api:@"stop" quitOnError:FALSE];
    
    NSLog(@"Trying to shutdown postgres server");
    [Helper postgresql:@"stop" quitOnError:FALSE];
}


@end
