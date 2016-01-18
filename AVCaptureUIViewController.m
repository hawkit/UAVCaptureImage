#import "AVCaptureUIViewController.h"

#if TARGET_OS_IPHONE

#pragma mark -

@implementation AVCaptureUIViewController

@synthesize outletCaptureImageController;

- (void)dealloc
{
	[outletCaptureImageController captureTeardown];
	
	ARC_SUPERDEALLOC(self);
}

#pragma mark -

- (void)captureController:(AVCaptureImageController*)controller outputCaptureImage:(CMCaptureImageModel*)image sampleBuffer:(CMSampleBufferRef)sampleBuffer
{
//	NSLOG_METHOD(image);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	[outletCaptureImageController captureSetup];
}

- (void)viewDidUnload
{
	[outletCaptureImageController captureTeardown];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end

#endif /* TARGET_OS_IPHONE */