#import "AVCaptureImageControllerBase.h"
#import "AVCaptureImageModel.h"

#pragma mark-

@interface AVCaptureImageControllerBase()<AVCaptureVideoDataOutputSampleBufferDelegate>
@property (ARC_PROP_STRONG,readwrite) AVCaptureVideoDataOutput* captureVideoDataOutput;
@property (ARC_PROP_STRONG,readwrite) AVCaptureStillImageOutput* captureStillImageOutput;
@property (ARC_PROP_STRONG,readwrite) AVCaptureVideoPreviewLayer* capturePreviewLayer;
- (BOOL)captureSetPreviewRootLayer:(CALayer*)previewRootLayer;
@end

@implementation AVCaptureImageControllerBase

@dynamic delegate;

ARC_SYNTHESIZE(captureEffectiveScale,__captureEffectiveScale);
ARC_SYNTHESIZE(captureIsUsingFrontFacingCamera,__captureIsUsingFrontFacingCamera);
ARC_SYNTHESIZE(captureVideoDataOutput,__captureVideoDataOutput);
ARC_SYNTHESIZE(captureStillImageOutput,__captureStillImageOutput);
ARC_SYNTHESIZE(capturePreviewLayer,__capturePreviewLayer);

- (void)dealloc
{
	[self captureTeardown];
	
	ARC_DEALLOC_NIL(self.captureVideoDataOutput);
	ARC_DEALLOC_NIL(self.captureStillImageOutput);
	ARC_DEALLOC_NIL(self.capturePreviewLayer);

	ARC_SUPERDEALLOC(self);
}

- (NSString*)captureSessionPreset
{
	return AVCaptureSessionPresetPhoto;
}

-(AVCaptureConnection*) captureVideoCaptureConnection
{
	return [self.captureVideoDataOutput connectionWithMediaType:AVMediaTypeVideo];
}

#pragma mark -

- (BOOL)captureSetupNeeded
{
	return (__capturePreviewLayer==nil);
}

- (void)captureSetup
{
	NSLOG_METHOD(self);
	[super captureSetup];
	
	__captureIsUsingFrontFacingCamera = NO;
	__captureEffectiveScale = 1.0f;

AVCaptureSession *session = [AVCaptureSession new];
	X_REQUIRED_DEBUG(session!=nil);	
	[session setSessionPreset:self.captureSessionPreset];
AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
	if (REQUIRED_DEBUG(device!=nil))
		{
	NSError* error = nil;
	AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
		[self captureRequirementNilError:error message:NSLocalizedString(@"NO DEVICE",@"NO DEVICE")];
		if (REQUIRED_DEBUG(deviceInput!=nil) && REQUIRED_NSERROR_NIL(error))
			{
			if ( REQUIRED_DEBUG([session canAddInput:deviceInput]) )
				[session addInput:deviceInput];
			
			[self captureSetupSessionOutputForStillImageCapture:session];
			[self captureSetupSessionOutputForVideoCapture:session];
			
			__capturePreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
			if (REQUIRED_DEBUG(self.capturePreviewLayer!=nil) && REQUIRED_DEBUG([self captureSetupPreviewUI]))
				{
				[session startRunning];
				}
			}
		}
	if (!REQUIRED_DEBUG(session.isRunning))
		[self captureTeardown];
	ARC_RELEASE(session);
	NSLog(@"session.isRunning=%u\n", (unsigned)session.isRunning);
}

- (void)captureSetupSessionOutputForStillImageCapture:(AVCaptureSession*)session
{
	if (REQUIRED_DEBUG(session!=nil))
		{
		__captureStillImageOutput = [AVCaptureStillImageOutput new];
		if (REQUIRED_DEBUG(self.captureStillImageOutput!=nil))
			{
			if (REQUIRED_DEBUG([session canAddOutput:self.captureStillImageOutput]))
				[session addOutput:self.captureStillImageOutput];
			}
		}
}

- (NSDictionary*)captureVideoCaptureOutputSettings
{
	// we want BGRA, both CoreGraphics and OpenGL work well with 'BGRA'
NSDictionary* bgraOutputSettings = [NSDictionary dictionaryWithObject: [NSNumber numberWithUnsignedInt:kCMPixelFormat_32BGRA]
										forKey:ARC_BRIDGE(id)kCVPixelBufferPixelFormatTypeKey];
	return bgraOutputSettings;
}

- (void)captureSetupSessionOutputForVideoCapture:(AVCaptureSession*)session
{
	if (REQUIRED_DEBUG(session!=nil))
		{
		__captureVideoDataOutput = [AVCaptureVideoDataOutput new];
		if (REQUIRED_DEBUG(self.captureVideoDataOutput!=nil))
			{
			[self.captureVideoDataOutput setVideoSettings:self.captureVideoCaptureOutputSettings];
			[self.captureVideoDataOutput setAlwaysDiscardsLateVideoFrames:YES]; // discard if the data output queue is blocked (as we process the still image)
			
			// requires a serial dispatch queue used for the sample buffer delegate as well as when a still image is captured
			// a serial dispatch queue must be used to guarantee that video frames will be delivered in order
			// see the header doc for setSampleBufferDelegate:queue: for more information
			if (REQUIRED_DEBUG(self.captureVideoQueue!=NULL))
				[self.captureVideoDataOutput setSampleBufferDelegate:self queue:self.captureVideoQueue];
			
			if ( REQUIRED_DEBUG([session canAddOutput:self.captureVideoDataOutput]))
				[session addOutput:self.captureVideoDataOutput];
				
			}
		}
}

-(CALayer*) capturePreviewRootLayer
{
	return nil;
}

- (BOOL)captureSetPreviewRootLayer:(CALayer*)previewRootLayer
{
BOOL result = NO;
	if (REQUIRED_DEBUG(self.capturePreviewLayer!=nil) && REQUIRED_DEBUG(previewRootLayer!=nil))
		{
		[previewRootLayer setMasksToBounds:YES];
		[self.capturePreviewLayer setFrame:previewRootLayer.bounds];
//		[self.capturePreviewLayer setFrame:previewRootLayer.frame];
		[previewRootLayer addSublayer:self.capturePreviewLayer];
		result = YES;
		}
	return result;
}

- (BOOL)captureSetupPreviewUI
{
	return [self captureSetPreviewRootLayer:[self capturePreviewRootLayer]];
}

#pragma mark -

- (BOOL)captureTeardownNeeded
{
	return (self.captureVideoDataOutput!=nil) || (self.captureStillImageOutput!=nil) || (self.captureVideoQueue!=0) || (self.capturePreviewLayer!=nil);
}

- (void)captureTeardown
{	
	if (self.captureTeardownNeeded)
		{
		if (REQUIRED_DEBUG(self.captureVideoQueue!=NULL))
			dispatch_sync(self.captureVideoQueue,^{});

		if (REQUIRED_DEBUG(self.capturePreviewLayer!=nil))
			{
			[self.capturePreviewLayer removeFromSuperlayer];
			self.capturePreviewLayer = nil;
			}

		self.captureVideoDataOutput = nil;
		self.captureStillImageOutput = nil;
		}
	[super captureTeardown];
}

-(NSDictionary*) captureStillImageOutputSettings
{
	return [NSDictionary dictionaryWithObject:AVVideoCodecJPEG forKey:AVVideoCodecKey];
}

-(void) captureSnapStillPictureFromSampleBuffer:(CMSampleBufferRef)imageDataSampleBuffer
{
	if (REQUIRED_DEBUG(imageDataSampleBuffer!=NULL))
		{
	NSData* imageData = [AVCaptureImageModel copyStillImageDataFromSampleBuffer:imageDataSampleBuffer];
		if (REQUIRED_DEBUG(imageData!=nil))
			{
		CFDictionaryRef sampleBufferAttachmentsOrNull = CMCopyDictionaryOfAttachments(kCFAllocatorDefault,imageDataSampleBuffer,kCMAttachmentMode_ShouldPropagate);
		id imageMetadata = ARC_BRIDGE(id)sampleBufferAttachmentsOrNull;
			if (self.outletCaptureStillModel!=nil)
				[self.outletCaptureStillModel setImageDataWithImageData:imageData imageMetadata:imageMetadata];
			[self captureOutputImageUsingDelegate:self.outletCaptureStillModel sampleBuffer:imageDataSampleBuffer];
			[self captureWriteImageData:imageData imageMetadata:imageMetadata];
			if (sampleBufferAttachmentsOrNull) CFRelease(sampleBufferAttachmentsOrNull);
			}
		}
}

- (IBAction)actionCaptureSwitchFrontAndBackCameras:(id)sender
{
}

- (AVCaptureVideoOrientation)captureOrientationForDeviceOrientation
{
	return AVCaptureVideoOrientationPortrait;
}

// main action method to take a still image -- if face detection has been turned on and a face has been detected
// the square overlay will be composited on top of the captured image and saved to the camera roll
- (IBAction) actionCaptureSnapshot:(id)sender
{
	NSLOG_METHOD(sender);
	if (REQUIRED_DEBUG(self.captureStillImageOutput!=nil))
		{
		// Find out the current orientation and tell the still image output.
	AVCaptureConnection* captureStillImageConnection = [self.captureStillImageOutput connectionWithMediaType:AVMediaTypeVideo];
		if (REQUIRED_DEBUG(captureStillImageConnection!=nil))
			{
			if (REQUIRED_DEBUG([captureStillImageConnection isVideoOrientationSupported]))
				[captureStillImageConnection setVideoOrientation:self.captureOrientationForDeviceOrientation];
#if TARGET_OS_IPHONE
			if (REQUIRED_DEBUG([captureStillImageConnection respondsToSelector:@selector(setVideoScaleAndCropFactor:)]))
				[(id)captureStillImageConnection setVideoScaleAndCropFactor:self.captureEffectiveScale];
#endif
			[self.captureStillImageOutput setOutputSettings:self.captureStillImageOutputSettings];
			[self.captureStillImageOutput captureStillImageAsynchronouslyFromConnection:captureStillImageConnection
				completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError* error) {
					NSLog(@"actionCaptureSnapshot::completionHandler:\n");
					if (REQUIRED_NSERROR_NIL(error))
						[self captureSnapStillPictureFromSampleBuffer:imageDataSampleBuffer];
					else
						[self captureRequirementNilError:error message:NSLocalizedString(@"NO PIC",@"NO PIC")];
					}];
			}
		}
}

#pragma mark -

- (void)captureOutput:(AVCaptureOutput*)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection*)connection
{
	// NSLog(@"captureOutput:%@\n", captureOutput);
//	NSLOG_METHOD(captureOutput);
	if (REQUIRED_DEBUG(sampleBuffer!=NULL))
		{
		if (self.outletCaptureVideoModel!=nil)
			[self.outletCaptureVideoModel setImageDataWithSampleBuffer:sampleBuffer];
		[self captureOutputImageUsingDelegate:self.outletCaptureVideoModel sampleBuffer:sampleBuffer];
		}
}

@end
