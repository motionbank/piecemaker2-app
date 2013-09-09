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
}

- (void)awakeFromNib
{
    mCaptureSession = [[QTCaptureSession alloc] init];
    BOOL success = NO;
    NSError *error;

    QTCaptureDevice *videoDevice = [QTCaptureDevice defaultInputDeviceWithMediaType:QTMediaTypeVideo];
    success = [videoDevice open:&error];
    if (!success) {
        videoDevice = [QTCaptureDevice defaultInputDeviceWithMediaType:QTMediaTypeMuxed];
        success = [videoDevice open:&error];
    }
    if (!success) {
        videoDevice = nil;
    }
    if (videoDevice) {
        mCaptureVideoDeviceInput = [[QTCaptureDeviceInput alloc] initWithDevice:videoDevice];
        success = [mCaptureSession addInput:mCaptureVideoDeviceInput error:&error];
        if (!success) {
        }
             
        if (![videoDevice hasMediaType:QTMediaTypeSound] && ![videoDevice hasMediaType:QTMediaTypeMuxed]) {
                 
            QTCaptureDevice *audioDevice = [QTCaptureDevice defaultInputDeviceWithMediaType:QTMediaTypeSound];
            success = [audioDevice open:&error];
                 
            if (!success) {
                audioDevice = nil;
            }
                 
            if (audioDevice) {
                mCaptureAudioDeviceInput = [[QTCaptureDeviceInput alloc] initWithDevice:audioDevice];
                     
                success = [mCaptureSession addInput:mCaptureAudioDeviceInput error:&error];
                if (!success) {
                }
            }
        }
        mCaptureMovieFileOutput = [[QTCaptureMovieFileOutput alloc] init];
        success = [mCaptureSession addOutput:mCaptureMovieFileOutput error:&error];
        if (!success) {
        }
        [mCaptureView setCaptureSession:mCaptureSession];
        
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
        }
        
        [mCaptureSession startRunning];
    }
         
}


- (void)windowWillClose:(NSNotification *)notification
{
    [mCaptureSession stopRunning];
    if ([[mCaptureVideoDeviceInput device] isOpen])
        [[mCaptureVideoDeviceInput device] close];
    if ([[mCaptureAudioDeviceInput device] isOpen])
        [[mCaptureAudioDeviceInput device] close];
}

-(void)startRecorder
{
    NSLog(@"Start Recorder", nil);
    NSString *dataDir = [[[[defaults URLForKey:@"dataDir"] absoluteString] stringByReplacingOccurrencesOfString:@"file://localhost" withString:@""] stringByReplacingOccurrencesOfString:@"%20" withString:@" "];
    NSString *movDir = [dataDir stringByAppendingString:@"mov"];
    
    NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
    NSNumber *timeStampObj = [NSNumber numberWithDouble: timeStamp];
    
    NSString *filename = [movDir stringByAppendingString:@"/"];
    filename = [filename stringByAppendingString:[timeStampObj stringValue]];
    filename = [filename stringByAppendingString:@".mov"];
    
    [mCaptureMovieFileOutput recordToOutputFileURL:[NSURL fileURLWithPath:filename]];
    
    // FFmpeg VP8 Encoding Options
    // http://wiki.webmproject.org/ffmpeg
    
    // ffmpeg -i /Users/mattes/piecemaker2_dat/mov/1378734848.425225.mov -ab 96k   -vcodec libx264   -level 21 -refs 2 -b 345k -bt 345k   -threads 0 -s 640x360 /Users/mattes/piecemaker2_dat/mov/1378734848.425225.mp4
}

-(void)stopRecorder
{
    NSLog(@"Stop Recorder", nil);
    [mCaptureMovieFileOutput recordToOutputFileURL:nil];
}


/*
- (void)captureOutput:(QTCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL forConnections:(NSArray *)connections dueToError:(NSError *)error
{
    NSLog(@"I finished recording ...", nil);
    [[NSWorkspace sharedWorkspace] openURL:outputFileURL];
}
*/


@end
