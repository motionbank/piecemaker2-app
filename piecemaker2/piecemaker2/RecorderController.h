//
//  RecorderController.h
//  piecemaker2
//
//  Created by Mattes on 07.08.13.
//  Copyright (c) 2013 motionbank. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QTKit/QTKit.h>

@interface RecorderController : NSWindowController {
    IBOutlet QTCaptureView *mCaptureView;
    
    QTCaptureSession            *mCaptureSession;
    QTCaptureMovieFileOutput    *mCaptureMovieFileOutput;
    QTCaptureDeviceInput        *mCaptureDeviceInput;
}

- (IBAction)startRecording:(id)sender;
- (IBAction)stopRecording:(id)sender;

@end
