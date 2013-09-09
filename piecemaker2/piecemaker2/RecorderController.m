//
//  RecorderController.m
//  piecemaker2
//
//  Created by Mattes on 07.08.13.
//  Copyright (c) 2013 motionbank. All rights reserved.
//

#import "RecorderController.h"

@interface RecorderController ()

@end

@implementation RecorderController

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
}

- (void)awakeFromNib
{
    mCaptureSession = [[QTCaptureSession alloc] init];
    BOOL success = NO;
    NSError *error;

    QTCaptureDevice *device = [QTCaptureDevice defaultInputDeviceWithMediaType:QTMediaTypeVideo];
    if (device) {
        success = [device open:&error];
        if (!success) {
        }
        mCaptureDeviceInput = [[QTCaptureDeviceInput alloc] initWithDevice:device];
        success = [mCaptureSession addInput:mCaptureDeviceInput error:&error];
        if (!success) {
            // Handle error
        }
        
        mCaptureMovieFileOutput = [[QTCaptureMovieFileOutput alloc] init];
        success = [mCaptureSession addOutput:mCaptureMovieFileOutput error:&error];
        if (!success) {
        }
        [mCaptureMovieFileOutput setDelegate:self];
        
        NSEnumerator *connectionEnumerator = [[mCaptureMovieFileOutput connections] objectEnumerator];
        QTCaptureConnection *connection;
        
        while ((connection = [connectionEnumerator nextObject])) {
            NSString *mediaType = [connection mediaType];
            QTCompressionOptions *compressionOptions = nil;
            if ([mediaType isEqualToString:QTMediaTypeVideo]) {
                compressionOptions = [QTCompressionOptions compressionOptionsWithIdentifier:@"QTCompressionOptions240SizeH264Video"];
            } else if ([mediaType isEqualToString:QTMediaTypeSound]) {
                compressionOptions = [QTCompressionOptions compressionOptionsWithIdentifier:@"QTCompressionOptionsHighQualityAACAudio"];
            }
            
            [mCaptureMovieFileOutput setCompressionOptions:compressionOptions forConnection:connection];
            
            [mCaptureView setCaptureSession:mCaptureSession];
        }
        [mCaptureSession startRunning];
    }
}

- (void)windowWillClose:(NSNotification *)notification
{
    [mCaptureSession stopRunning];
    [[mCaptureDeviceInput device] close];
}



- (IBAction)startRecording:(id)sender
{
      [mCaptureMovieFileOutput recordToOutputFileURL:[NSURL fileURLWithPath:@"/Users/Shared/My Recorded Movie.mov"]];
}
- (IBAction)stopRecording:(id)sender
{
     [mCaptureMovieFileOutput recordToOutputFileURL:nil];
}

- (void)captureOutput:(QTCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL forConnections:(NSArray *)connections dueToError:(NSError *)error
{
    [[NSWorkspace sharedWorkspace] openURL:outputFileURL];
}


@end
