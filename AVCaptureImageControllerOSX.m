#import "AVCaptureImageControllerOSX.h"
#import "AVCaptureImageModel.h"

#if !TARGET_OS_IPHONE

@interface AVCaptureImageControllerOSX()
@end

@implementation AVCaptureImageControllerOSX

- (void)dealloc
{
	ARC_SUPERDEALLOC(self);
}

- (void)captureDisplayErrorOnMainQueue:(NSError *)error messageTitle:(NSString *)messageTitle
{
	dispatch_async(dispatch_get_main_queue(), ^(void) {
		NSLOG_METHOD(error);
	});
}

- (void)captureSetup
{
	__captureIsUsingFrontFacingCamera = YES;
	[super captureSetup];
}

- (CALayer*)capturePreviewRootLayer
{
NSView* capturePreviewView = (NSView*)self.outletCapturePreviewView;
	REQUIRED_DEBUG(self.outletCapturePreviewView!=nil) && REQUIRED_DEBUG(capturePreviewView.layer!=nil);
	return (capturePreviewView.layer);
}

- (void)captureSetupSessionOutputForVideoCapture:(AVCaptureSession*)session
{
	[super captureSetupSessionOutputForVideoCapture:session];
	[[self.captureVideoDataOutput connectionWithMediaType:AVMediaTypeVideo] setEnabled:NO];
}

- (void)captureTeardown
{
	[super captureTeardown];
}

-(void) captureWriteImageData:(NSData*)imageData imageMetadata:(id)imageMetadata
{
#if 0
	NSLOG_METHOD(imageData);
	if (REQUIRED_DEBUG(imageData!=nil))
		{
		ARC_RETAIN(imageData);
		dispatch_async(dispatch_get_main_queue(),^{
		NSImage* image = [[NSImage alloc] initWithData:imageData];
			if (REQUIRED_DEBUG(image!=nil))
				{
				if (REQUIRED_DEBUG(self.outletImageView!=nil))
					[self.outletImageView setImage:image];
				ARC_RELEASE(image);
				}
			ARC_RELEASE(imageData);
			});
		}
#endif
}

- (IBAction)actionCaptureSwitchFrontAndBackCameras:(id)sender
{
}

@end

#endif /* !TARGET_OS_IPHONE */
