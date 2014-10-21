//
//  ApiController.m
//  piecemaker2
//
//  Created by Mattes on 07.08.13.
//  Copyright (c) 2013 motionbank. All rights reserved.
//

#import "ApiController.h"

#import "Helper.h"

@implementation ApiController

@synthesize apiview = _apiview;
@synthesize recorderController = _recorderController;

NSUserDefaults* defaults;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    [self resetIndexHtml:nil];
}

- (IBAction)resetIndexHtml:(id)sender {
    [[_apiview mainFrame] loadRequest:[NSURLRequest requestWithURL:
                                       [NSURL URLWithString:@"http://0.0.0.0:50726/index.html"]]];
    
}

- (NSURLRequest *)webView:(WebView *)sender resource:(id)identifier willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse fromDataSource:(WebDataSource *)dataSource {
    request = [NSURLRequest requestWithURL : [request URL]
                               cachePolicy : NSURLRequestReloadIgnoringLocalCacheData
                           timeoutInterval : [request timeoutInterval]];
    return request;
}

// return a "nice name" for a JS method
+(NSString*)webScriptNameForSelector:(SEL)sel
{
    if(sel == @selector(jsRecorderMethod:))
        return @"recorder";
    return nil;
}

// allow for JS to call method (by hiding it from WebScript)
+ (BOOL)isSelectorExcludedFromWebScript:(SEL)sel
{
    if(sel == @selector(jsRecorderMethod:))
        return NO;
    return YES;
}

- (NSString*)jsRecorderMethod:(NSString*) action
{
    NSLog(@"jsRecorderMethod: %@", action);
    
    if([action isEqualToString:@"start"]) {
        
        NSLog(@"jsRecorderMethod: triggering starting recorder", nil);
        return [_recorderController startRecorder];
    
    } else if ([action isEqualToString:@"stop"]) {
        
        NSLog(@"jsRecorderMethod: triggering stopping recorder", nil);
        [_recorderController stopRecorder];
        
    } else if ([action isEqualToString:@"isRecording"]) {
    
        NSLog(@"jsRecorderMethod: check is recording");
        return [_recorderController isRecording] ? @"true" : @"false";
    
    } else if ([action isEqualToString:@"fetch"]) {
        
        NSLog(@"jsRecorderMethod: fetching videos", nil);
        
        NSString *dataDir = [[[[defaults URLForKey:@"dataDir"] absoluteString] stringByReplacingOccurrencesOfString:@"file://localhost" withString:@""] stringByReplacingOccurrencesOfString:@"%20" withString:@" "];
        NSString *movDir = [dataDir stringByAppendingString:@"/mov"];
        
        NSFileManager *filemgr;
        NSArray *filelist;
        int count;
        
        filemgr = [NSFileManager defaultManager];
        filelist = [filemgr contentsOfDirectoryAtPath:movDir error: nil];
        
        NSPredicate *mp4Predicate = [NSPredicate predicateWithFormat:@"SELF endswith[c] '.mp4'"];
        NSArray *endsWithMP4 = [filelist filteredArrayUsingPredicate:mp4Predicate];
        
        count = (int)[endsWithMP4 count];
        NSString *returnString = [endsWithMP4 componentsJoinedByString: @";"];
        
        return returnString;
    }
    
    return @"";
}

//- (void)webView:(WebView *)sender runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WebFrame *)frame {
//    NSAlert *alert = [[NSAlert alloc] init];
//    [alert addButtonWithTitle:@"OK"];
//    [alert setMessageText:message];
//    [alert runModal];
//    //[alert release];
//}

//- (BOOL)webView:(WebView *)sender runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WebFrame *)frame {
//    NSInteger result = NSRunInformationalAlertPanel(NSLocalizedString(@"JavaScript", @""),  // title
//                        message,                // message
//                        NSLocalizedString(@"OK", @""),      // default button
//                        NSLocalizedString(@"Cancel", @""),    // alt button
//                        nil);
//    return NSAlertDefaultReturn == result;
//}

- (void)awakeFromNib
{
    //set this class as the web view's frame load delegate
    //we will then be notified when the scripting environment
    //becomes available in the page
    
    [_apiview setFrameLoadDelegate:self];
    
    // TODO: this is a quick hack as for some reason all local storage files
    // listed in the WebKit database get deleted every second time ...
    NSString *sqlCmd = @"DELETE FROM Origins WHERE path LIKE \"%/Library/Piecemaker2/LocalStorage/%\"";
    NSDictionary *result = [Helper runCommand:[NSString stringWithFormat:@"/opt/local/bin/sqlite3 /Users/fjenett/Library/WebKit/LocalStorage/StorageTracker.db '%@'", sqlCmd]
         waitUntilExit:TRUE];
    NSLog(@"Clearing LS.db: %@", [result valueForKey:@"result"]);
    
    //NSString* appBundleID = [[NSBundle mainBundle] bundleIdentifier];
    WebPreferences* prefs = [_apiview preferences];
    [prefs _setLocalStorageDatabasePath:@"~/Library/Piecemaker2/LocalStorage"];
    [prefs setLocalStorageEnabled:YES];
    [prefs setDatabasesEnabled:YES];
    [prefs setDeveloperExtrasEnabled:YES];
    [_apiview setPreferences:prefs];
}

//this is called as soon as the script environment is ready in the webview
- (void)webView:(WebView *)sender didClearWindowObject:(WebScriptObject *)windowScriptObject forFrame:(WebFrame *)frame
{
    //add the controller to the script environment
    //the "Cocoa" object will now be available to JavaScript
    [windowScriptObject setValue:self forKey:@"PiecemakerBridge"];
}

@end
