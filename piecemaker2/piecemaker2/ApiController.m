//
//  ApiController.m
//  piecemaker2
//
//  Created by Mattes on 07.08.13.
//  Copyright (c) 2013 motionbank. All rights reserved.
//

#import "ApiController.h"

@interface ApiController ()

@end

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
    request = [NSURLRequest requestWithURL:[request URL] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:[request timeoutInterval]];
    return request;
}


//this returns a nice name for the method in the JavaScript environment
+(NSString*)webScriptNameForSelector:(SEL)sel
{
    if(sel == @selector(recorderJavaScriptString:))
        return @"recorder";
    return nil;
}

//this allows JavaScript to call the -logJavaScriptString: method
+ (BOOL)isSelectorExcludedFromWebScript:(SEL)sel
{
    if(sel == @selector(recorderJavaScriptString:))
        return NO;
    return YES;
}

//this is a simple log command
- (NSString*)recorderJavaScriptString:(NSString*) action
{
    NSLog(@"recorderJS: %@", action);
    if([action isEqualToString:@"start"]) {
        NSLog(@"triggering starting recorder", nil);
        [_recorderController startRecorder];
    } else if ([action isEqualToString:@"stop"]) {
        NSLog(@"triggering stopping recorder", nil);
        [_recorderController stopRecorder];
    } else if ([action isEqualToString:@"fetch"]) {
        NSLog(@"fetching videos", nil);
        
        NSString *dataDir = [[[[defaults URLForKey:@"dataDir"] absoluteString] stringByReplacingOccurrencesOfString:@"file://localhost" withString:@""] stringByReplacingOccurrencesOfString:@"%20" withString:@" "];
        NSString *movDir = [dataDir stringByAppendingString:@"/mov"];
        
        NSFileManager *filemgr;
        NSArray *filelist;
        int count;
        int i;
        
        filemgr = [NSFileManager defaultManager];
        filelist = [filemgr contentsOfDirectoryAtPath:movDir error: nil];
        
        count = [filelist count];
        NSString *returnString = @"";
        
        for (i = 0; i < count; i++) {
            returnString = [returnString stringByAppendingString:[filelist objectAtIndex: i]];
            returnString = [returnString stringByAppendingString:@";"];
        }
        
        // [".DS_Store", "1378734727.351129.mov", "1378734779.011412.mov", "1378734848.425225.mov", ""]
        // @todo remove some files like .DS_Store or empty files
        return returnString;
    }
    
    return @"";
}

- (void)awakeFromNib
{
    //set this class as the web view's frame load delegate
    //we will then be notified when the scripting environment
    //becomes available in the page
    [_apiview setFrameLoadDelegate:self];
}

//this is called as soon as the script environment is ready in the webview
- (void)webView:(WebView *)sender didClearWindowObject:(WebScriptObject *)windowScriptObject forFrame:(WebFrame *)frame
{
    //add the controller to the script environment
    //the "Cocoa" object will now be available to JavaScript
    [windowScriptObject setValue:self forKey:@"PiecemakerBridge"];
}

@end
