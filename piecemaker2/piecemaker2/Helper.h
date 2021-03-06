//
//  Helper.h
//  piecemaker2
//
//  Created by Mattes on 06.08.13.
//  Copyright (c) 2013 motionbank. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Helper : NSObject

+ (void)postgresql:(NSString *)action quitOnError:(Boolean)quit;

+ (NSDictionary*)runCommand:(NSString*) commandToRun waitUntilExit:(Boolean)waitUntilExit;
+(int)runCommandAndGetExitCode:(NSString*) command;

+(void)showAlert:(NSString *)messageText
         message:(NSString *)informativeText
   detailMessage:(NSString *)detailText
            quit:(Boolean)quit;

+(void)updatePostgresqlConf:(NSString* )filename quitOnError:(Boolean)quit port:(NSString *)port;

+(void)createConfigYml:(NSString*)filename sample:(NSString*)sampleFile user:(NSString*)user port:(NSString *)port quitOnError:(Boolean)quit;

+ (void)createDatabaseIfNotExist:(NSString*) database;

+(void)api:(NSString *)action quitOnError:(Boolean)quit;
+(void)frontendHttpServer:(NSString *)action quitOnError:(Boolean)quit;

@end
