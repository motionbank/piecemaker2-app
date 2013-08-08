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

NSUserDefaults* defaults;

// menu item events
// ----------------
- (IBAction)showDeveloper:(id)sender {
    if(!_developerController) {
        _developerController = [[DeveloperController alloc] initWithWindowNibName:@"DeveloperController"];
    }
    [_developerController showWindow:self];
    [_developerController setWebView:[_apiController apiview]];
}
- (IBAction)showApi:(id)sender {
    if(!_apiController) {
        _apiController = [[ApiController alloc] initWithWindowNibName:@"ApiController"];
    }
    [_apiController showWindow:self];
    // [_apiController resetIndexHtml:nil];
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
        [defaults setURL:[_path URL] forKey:@"dataDir"];
        
        [_startingBtn setEnabled:TRUE];
    } else {
        [_startingBtn setEnabled:FALSE];
    }
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    [_startingBtn setEnabled:FALSE];
    
    // actually, setEnable would make more sense here, but its not working
    [_recorderMenuItem setHidden:TRUE];
    [_apiMenuItem setHidden:TRUE];
    
    
    defaults = [NSUserDefaults standardUserDefaults];
    [_path setURL:[defaults URLForKey:@"dataDir"]];
    [self updateStartButtonState];
}

- (void)applicationWillTerminate:(NSNotification *)notification {
    [_apiController close];
    [_recorderController close];
    [_developerController close];
    [_window setIsVisible:FALSE];
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
    
    NSString *workingDir = [[NSBundle mainBundle] bundlePath];
    NSString *resourcesDir = [workingDir stringByAppendingString:@"/Contents/Resources"];
    
    NSError *error;
    NSFileManager *fileManager= [NSFileManager defaultManager];
    NSString *dataDir = [[[defaults URLForKey:@"dataDir"] absoluteString] stringByReplacingOccurrencesOfString:@"file://localhost" withString:@""];
    NSString *postgresDataDir = [dataDir stringByAppendingString:@"pqsql"];
    

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
    
    if(![fileManager fileExistsAtPath:postgresDataDir]) {
        // data dir is missing ... create new directory now
        error = nil;
        if(![fileManager createDirectoryAtPath:postgresDataDir withIntermediateDirectories:YES attributes:nil error:&error]) {
            NSLog(@"Failed to create postgres data dir \"%@\". Error: %@", dataDir, error);
            [Helper showAlert:@"PostgreSQL Init Error (100)"
                      message:[NSString stringWithFormat:@"Unable to create postgres data directory in %@", postgresDataDir]
                detailMessage:nil
                         quit:TRUE];
        }
        
        // use this new directory as data dir for postgresql
        NSDictionary *result = [Helper runCommand:[NSString stringWithFormat:@"initdb --auth=trust -D '%@'", postgresDataDir] waitUntilExit:TRUE];
        if([[result valueForKey:@"code"] intValue] > 0) {
            [Helper showAlert:@"PostgreSQL Init Error (101)"
                      message:[NSString stringWithFormat:@"Unable to init postgres data dir in %@", postgresDataDir]
                detailMessage:[result valueForKey:@"result"]
                         quit:TRUE];
        }
        
        // we then need to update postgresql.conf
        [Helper updatePostgresqlConf:[NSString stringWithFormat:@"%@/postgresql.conf", postgresDataDir] quitOnError:TRUE port:@"50725"];
        
        // assuming that this is the first install...
        // run "gem install bundler" once
        // this is kind of a work-around, because of PATH issues
        NSLog(@"gem install bundler - work-around for PATH issues", nil);
        [Helper runCommand:[NSString stringWithFormat:@"gem install bundler", nil] waitUntilExit:TRUE];
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
    
    // start frontend http server
    // --------------------------
    [Helper frontendHttpServer:@"start" quitOnError:TRUE];
    
    
    [self ready];
}


// stop api
-(void)stop {
    
    NSLog(@"Trying to shutdown api");
    [Helper api:@"stop" quitOnError:FALSE];
    
    NSLog(@"Trying to shutdown frontend http server");
    [Helper frontendHttpServer:@"stop" quitOnError:FALSE];
    
    NSLog(@"shutdown postgres server");
    [Helper postgresql:@"stop" quitOnError:FALSE];
}


@end
