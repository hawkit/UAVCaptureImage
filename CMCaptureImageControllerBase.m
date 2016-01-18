#import "CMCaptureImageControllerBase.h"

@interface CMCaptureImageControllerBase()
@end

@implementation CMCaptureImageControllerBase

ARC_SYNTHESIZEOUTLET(delegate);
ARC_SYNTHESIZEOUTLET(outletCaptureStillModel);
ARC_SYNTHESIZEOUTLET(outletCaptureVideoModel);
ARC_SYNTHESIZEOUTLET(outletCapturePreviewView);
ARC_SYNTHESIZE(captureVideoQueue,__captureVideoQueue);

- (instancetype) init
{
	if ((self=[super init])!=nil)
		{
		__captureVideoQueue = dispatch_queue_create("CMCaptureImageControllerBase.captureVideoQueue", DISPATCH_QUEUE_SERIAL);
		REQUIRED_DEBUG(__captureVideoQueue);
		}
	return self;
}

- (void)dealloc
{
	/* ideally, we want the subclasses to teardown */
	if (REQUIRED_DEBUG(!self.captureTeardownNeeded))
		[self captureTeardown];
	
	if (self.captureVideoQueue!=0)
		{
		/* make sure queue is empty */
		dispatch_sync(self.captureVideoQueue,^{});
		ARC_DISPATCH_RELEASE(__captureVideoQueue);
		__captureVideoQueue = 0;
		}

	ARC_SUPERDEALLOC(self);
}

- (void)captureDisplayErrorOnMainQueue:(NSError *)error messageTitle:(NSString *)messageTitle
{
}

- (BOOL)captureRequirementNilError:(NSError*)error message:(NSString*)message
{
BOOL result = REQUIRED_NSERROR_NIL(error);
	if (result==NO)	
		{
		[self captureDisplayErrorOnMainQueue:error messageTitle:message];
		}
	return result;
}

-(dispatch_queue_t) captureSavingQueue
{
	return dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW,0L);
}

- (BOOL)captureSetupNeeded
{
	return YES;
}

- (void)captureSetup
{
	NSLOG_METHOD(self);
}

#pragma mark -

- (BOOL)captureTeardownNeeded
{
	return YES;
}

- (void)captureTeardown
{
	NSLOG_METHOD(self);
}

- (NSString*)captureStillPictureFileName {
NSURL* defaultFolderURL = [[[NSFileManager defaultManager] URLsForDirectory:NSPicturesDirectory inDomains:NSUserDomainMask] objectAtIndex:0];
NSString* defaultFolderPath = [[defaultFolderURL filePathURL] path];
NSString* classFileName = NSStringFromClass([self class]);
	return [[defaultFolderPath stringByAppendingPathComponent:classFileName] stringByAppendingPathExtension:@"JPG"];
}

-(void) captureWriteImageData:(NSData*)imageData imageMetadata:(id)imageMetadata
{
	if (REQUIRED_DEBUG(imageData!=nil))
		{
		ARC_RETAIN(imageData);
		dispatch_async(self.captureSavingQueue,^{
			[imageData writeToFile:self.captureStillPictureFileName atomically:YES];
			ARC_RELEASE(imageData);
			});
		}
}

-(void) captureSnapStillPictureFromSampleBuffer:(CMSampleBufferRef)imageDataSampleBuffer
{
	NSLOG_METHOD(self);
}

- (IBAction) actionCaptureSnapshot:(id)sender
{
	NSLOG_METHOD(sender);
}

#pragma mark -

- (void)captureOutputImageUsingDelegate:(CMCaptureImageModel*)model imageBuffer:(CVImageBufferRef)imageBuffer
{
	if (delegate!=nil)
		{
		if (REQUIRED_DEBUG([(id)delegate respondsToSelector:@selector(captureController:outputCaptureImage:imageBuffer:)]))
			{
			[delegate captureController:self outputCaptureImage:model imageBuffer:imageBuffer];
			}
		}
}

- (void)captureOutputImageUsingDelegate:(CMCaptureImageModel*)model sampleBuffer:(CMSampleBufferRef)sampleBuffer
{
	if (delegate!=nil)
		{
		if (REQUIRED_DEBUG([(id)delegate respondsToSelector:@selector(captureController:outputCaptureImage:sampleBuffer:)]))
			{
			[delegate captureController:self outputCaptureImage:model sampleBuffer:sampleBuffer];
			}
		}
}

@end
