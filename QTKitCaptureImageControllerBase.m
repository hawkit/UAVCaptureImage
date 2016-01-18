#import "QTKitCaptureImageControllerBase.h"
#import "CMCaptureImageModelCIImage.h"

@interface QTKitCaptureImageControllerBase()
@property (assign) CVImageBufferRef imageBufferRef;
@property (ARC_PROP_STRONG,readwrite) QTCaptureSession*				captureSession;
@property (ARC_PROP_STRONG,readwrite) QTCaptureDeviceInput*			captureVideoDeviceInput;
@property (ARC_PROP_STRONG,readwrite) QTCaptureDecompressedVideoOutput*	captureVideoOutput;
- (BOOL)captureSetupSessionOutputForVideoCapture:(QTCaptureSession*)session;
@end

@implementation QTKitCaptureImageControllerBase

@dynamic delegate;
@dynamic outletCapturePreviewView;

ARC_SYNTHESIZE(imageBufferRef,__imageBufferRef);
ARC_SYNTHESIZE(captureSession,__captureSession);
ARC_SYNTHESIZE(captureVideoDeviceInput,__captureVideoDeviceInput);
ARC_SYNTHESIZE(captureVideoOutput,__captureVideoOutput);

- (void)dealloc
{
	[self captureTeardown];
	
	self.imageBufferRef = NULL;

	ARC_DEALLOC_NIL(self.captureVideoOutput);
	ARC_DEALLOC_NIL(self.captureVideoDeviceInput);
	ARC_DEALLOC_NIL(self.captureSession);

	ARC_SUPERDEALLOC(self);
}

#pragma mark -

- (BOOL)captureSetupNeeded
{
	return (self.captureSession==nil);
}

- (void)captureSetup
{
	[super captureSetup];

QTCaptureSession* session = [[QTCaptureSession alloc] init];
	if (REQUIRED_DEBUG(session!=nil))
		{
		if (REQUIRED_DEBUG([self captureSetupSessionOutputForVideoCapture:session]))
			{
			self.captureSession = session;
			[self captureSetupPreviewUI];
			[self.captureSession startRunning];
			}
		ARC_RELEASE(session);
		}
    
	if (!REQUIRED_DEBUG(self.captureSession.isRunning))
		[self captureTeardown];

	NSLOG_METHOD(self.captureSession);
}

#pragma mark -

+(NSDictionary*) defaultIOSurfaceProperties
{
	return [NSDictionary dictionary];
}

+(NSDictionary*) defaultCaptureVideoPixelBufferFormat
{
	return [NSDictionary dictionaryWithObjectsAndKeys:
			[NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA], kCVPixelBufferPixelFormatTypeKey, /* iSight native */
//			[NSNumber numberWithUnsignedInt:k2vuyPixelFormat], kCVPixelBufferPixelFormatTypeKey, /* iSight native */
//			[NSNumber numberWithUnsignedInt:kCVPixelFormatType_422YpCbCr8], (id)kCVPixelBufferPixelFormatTypeKey, /* iSight native? */
			[self defaultIOSurfaceProperties], kCVPixelBufferIOSurfacePropertiesKey,
			nil];
}

+(NSDictionary*) defaultCaptureVideoPixelBufferAttributes
{
	return [self defaultCaptureVideoPixelBufferFormat];
}

+(NSDictionary*) defaultCaptureVideoPixelBufferAttributesWithFrameSize:(CGSize)videoFrameSize
{
NSMutableDictionary* format = [[self defaultCaptureVideoPixelBufferFormat] mutableCopy];
	[format setObject:[NSNumber numberWithDouble:videoFrameSize.width] forKey:(id)kCVPixelBufferWidthKey];
	[format setObject:[NSNumber numberWithDouble:videoFrameSize.height] forKey:(id)kCVPixelBufferHeightKey];
	return [NSDictionary dictionaryWithDictionary:format];
}

-(NSDictionary*) captureVideoPixelBufferAttributes
{
	return [[self class] defaultCaptureVideoPixelBufferAttributes];
}

#pragma mark -

- (BOOL)captureSetupSessionOutputForVideoCapture:(QTCaptureSession*)session
{
BOOL result = NO;
	if (REQUIRED_DEBUG(session!=nil))
		{
	NSError *error = nil;
	QTCaptureDevice* videoDevice = [QTCaptureDevice defaultInputDeviceWithMediaType:QTMediaTypeVideo];
		if (REQUIRED_DEBUG(videoDevice!=nil) && REQUIRED_DEBUG([videoDevice open:&error]) && REQUIRED_NSERROR_NIL(error))
			{
			self.captureVideoDeviceInput = [[QTCaptureDeviceInput alloc] initWithDevice:videoDevice];
			if (REQUIRED_DEBUG(self.captureVideoDeviceInput!=nil))
				{
				if (REQUIRED_DEBUG([session addInput:self.captureVideoDeviceInput error:&error]) && REQUIRED_NSERROR_NIL(error))
					{
				QTCaptureDecompressedVideoOutput* captureVideoOutput = [[QTCaptureDecompressedVideoOutput alloc] init];
					if (REQUIRED_DEBUG(captureVideoOutput!=nil))
						{
						self.captureVideoOutput = captureVideoOutput;
						self.captureVideoOutput.automaticallyDropsLateVideoFrames = YES;
						[self.captureVideoOutput setPixelBufferAttributes:self.captureVideoPixelBufferAttributes];
						[self.captureVideoOutput setDelegate:self];
						result = REQUIRED_DEBUG([session addOutput:self.captureVideoOutput error:&error]) && REQUIRED_NSERROR_NIL(error);
						ARC_RELEASE(captureVideoOutput);
						}
					}
				ARC_RELEASE(self.captureVideoDeviceInput);
				}
			}
        }
	return result;
}

- (BOOL)captureSetupPreviewUI
{
BOOL result = NO;
	if (REQUIRED_DEBUG(self.outletCapturePreviewView!=nil) && REQUIRED_DEBUG(self.captureSession!=nil))
		{
		[self.outletCapturePreviewView setCaptureSession:self.captureSession];
		result = YES;
		}
	return result;
}

#pragma mark -

- (BOOL)captureTeardownNeeded
{
	return (self.captureSession!=nil);
}

- (void)captureTeardown
{	
	if (self.captureTeardownNeeded)
		{
		if (REQUIRED_DEBUG(self.captureVideoQueue!=NULL))
			dispatch_sync(self.captureVideoQueue,^{});

		if (REQUIRED_DEBUG(self.captureSession.isRunning))
			{
			[self.captureSession stopRunning];
			}
    
		if ([[self.captureVideoDeviceInput device] isOpen])
			[[self.captureVideoDeviceInput device] close];
    
		self.captureVideoOutput = nil;
		self.captureVideoDeviceInput = nil;
		self.captureSession = nil;
		}
	[super captureTeardown];
}

-(void) setImageBuffer:(CVImageBufferRef)imageBufferRef
{
	@synchronized(self)
		{
		if (self.imageBufferRef!=NULL) CVBufferRelease(self.imageBufferRef);
		self.imageBufferRef = imageBufferRef;
		CVBufferRetain(self.imageBufferRef);
		}
}

-(CVImageBufferRef) imageBuffer
{
	@synchronized(self)
		{
		return self.imageBufferRef;
		}
}

-(CVImageBufferRef) imageBufferCopy
{
CVImageBufferRef copyImageBuffer = NULL;
	if (self.imageBufferRef!=NULL) @synchronized(self)
		{
		CVBufferRetain(self.imageBufferRef);
		copyImageBuffer = self.imageBufferRef;
		}
	return copyImageBuffer;
}

-(void) captureSnapStillPictureFromImageBuffer:(CVImageBufferRef)imageBuffer
{
	if (REQUIRED_DEBUG(imageBuffer!=NULL))
		{
	NSData* imageData = [CMCaptureImageModelCIImage copyStillImageDataFromImageBuffer:imageBuffer];
		if (REQUIRED_DEBUG(imageData!=nil))
			{
		id imageMetadata = nil;
			if (self.outletCaptureStillModel!=nil)
				[self.outletCaptureStillModel setImageDataWithImageData:imageData imageMetadata:imageMetadata];
			[self captureOutputImageUsingDelegate:self.outletCaptureStillModel imageBuffer:imageBuffer];

			[self captureWriteImageData:imageData imageMetadata:imageMetadata];

			ARC_RELEASE(imageData);
			}
		}
}

// main action method to take a still image -- if face detection has been turned on and a face has been detected
// the square overlay will be composited on top of the captured image and saved to the camera roll
- (IBAction) actionCaptureSnapshot:(id)sender
{
	NSLOG_METHOD(sender);

CVImageBufferRef imageBuffer = [self imageBufferCopy];
	if (REQUIRED_DEBUG(imageBuffer!=NULL))
		{
		[self captureSnapStillPictureFromImageBuffer:imageBuffer];
		CVBufferRelease(imageBuffer);
		}
}

#pragma mark -

- (void)captureOutput:(QTCaptureOutput *)captureOutput didOutputVideoFrame:(CVImageBufferRef)videoFrame withSampleBuffer:(QTSampleBuffer *)sampleBuffer fromConnection:(QTCaptureConnection *)connection
{
//	NSLOG_METHOD(captureOutput);
	REQUIRED_DEBUG(videoFrame!=NULL);
	[self setImageBuffer:videoFrame];
}

@end
