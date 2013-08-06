//
//  Helper.h
//  piecemaker2
//
//  Created by Mattes on 06.08.13.
//  Copyright (c) 2013 motionbank. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Helper : NSObject

+ (Boolean)postgresql:(NSString *)action quitOnError:(Boolean)quit;

+ (NSDictionary*)runCommand:(NSString*) commandToRun;

+(void)showAlert:(NSString *)messageText
         message:(NSString *)informativeText
   detailMessage:(NSString *)detailText
            quit:(Boolean)quit;

+(void)updatePostgresqlConf:(NSString* )filename quitOnError:(Boolean)quit port:(NSString *)port;

+ (void)createDatabaseIfNotExist:(NSString*) database;

@end
