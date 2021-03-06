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
    self = [super initWithWindow : window];
    if (self) {
        _isRecording = FALSE;
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
    
    // print out capture devices, more here:
    // http://www.subfurther.com/blog/2007/12/04/capturing-from-multiple-devices-with-qtkit/
    
    NSArray* devicesWithMediaType = [QTCaptureDevice inputDevicesWithMediaType:QTMediaTypeVideo];
    NSArray* devicesWithMuxType = [QTCaptureDevice inputDevicesWithMediaType:QTMediaTypeMuxed];
    NSMutableSet* devicesSet = [NSMutableSet setWithArray: devicesWithMediaType];
    [devicesSet addObjectsFromArray: devicesWithMuxType];
    NSEnumerator *enumerator = [devicesSet objectEnumerator];
    id value;
    QTCaptureDevice *videoDevice;
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *deviceUniqueId = [prefs stringForKey:@"recorder.device.id"];
    
    while ((value = [enumerator nextObject]))
    {
        QTCaptureDevice *device = (QTCaptureDevice*) value;
        NSLog(@"Found device: %@", [device localizedDisplayName]);
        
        if ( [deviceUniqueId isEqualToString:[device uniqueID]] ) {
            videoDevice = device;
        }
    }

    if ( videoDevice == nil ) {
        videoDevice = [QTCaptureDevice defaultInputDeviceWithMediaType:QTMediaTypeVideo];
    }
    success = [videoDevice open:&error];
    
    if (!success) {
        videoDevice = [QTCaptureDevice defaultInputDeviceWithMediaType:QTMediaTypeMuxed];
        success = [videoDevice open:&error];
    }
    
    if (!success) {
        videoDevice = nil;
    }
    
    if (videoDevice)
    {
        [prefs setValue:[videoDevice uniqueID] forKey:@"recorder.device.id"];
        
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

-(NSString*)startRecorder
{
    NSLog(@"Start Recorder", nil);
    
    if ( !_isRecording ) {
        
        NSString *dataDir = [[[[defaults URLForKey:@"dataDir"] absoluteString]
                                    stringByReplacingOccurrencesOfString:@"file://localhost"
                                    withString:@""]
                                            stringByReplacingOccurrencesOfString:@"%20"
                                            withString:@" "];
        
        NSString *movDir = [dataDir stringByAppendingString:@"mov"];
        
        NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
        NSNumber *timeStampObj = [NSNumber numberWithDouble: timeStamp];
        
        NSString *filename = [timeStampObj stringValue];
        filename = [filename stringByAppendingString:@".mp4"];
        
        currentFileName = [NSString stringWithString:filename];
        
        NSString *filePath = [[movDir stringByAppendingString:@"/"] stringByAppendingString:filename];
        
        NSLog(@"Recording to: %s", [filePath UTF8String]);
        [mCaptureMovieFileOutput recordToOutputFileURL:[NSURL fileURLWithPath:filePath]];
        
        // FFmpeg VP8 Encoding Options
        // http://wiki.webmproject.org/ffmpeg
        
        // ffmpeg -i /Users/mattes/piecemaker2_dat/mov/1378734848.425225.mov -ab 96k   -vcodec libx264   -level 21 -refs 2 -b 345k -bt 345k   -threads 0 -s 640x360 /Users/mattes/piecemaker2_dat/mov/1378734848.425225.mp4
        
        [[self window] setTitle:@"[•] Recorder"];
        
        _isRecording = TRUE;
        
    } else {
        NSLog( @"... recording is already recording to file %s", [currentFileName UTF8String] );
    }
    
    return currentFileName;
}

-(BOOL)isRecording
{
    return _isRecording;
}

-(void)stopRecorder
{
    currentFileName = nil;
    _isRecording = FALSE;
    
    NSLog(@"Stop Recorder", nil);
    [mCaptureMovieFileOutput recordToOutputFileURL:nil];
    
    [[self window] setTitle:@"Recorder"];
}


/*
- (void)captureOutput:(QTCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL forConnections:(NSArray *)connections dueToError:(NSError *)error
{
    NSLog(@"I finished recording ...", nil);
    [[NSWorkspace sharedWorkspace] openURL:outputFileURL];
}
*/


@end
