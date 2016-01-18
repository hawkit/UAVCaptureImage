#import "AVCaptureImagePopoverViewControllerIOS.h"

#if TARGET_OS_IPHONE

#import "AVCaptureStoryboardPopoverSegueIOS.h"
#import "UIApplication+Utilities.h"

@interface AVCaptureImagePopoverViewControllerIOS ()
@property (ARC_PROP_OUTLET) IBOutlet AVCaptureImageModel* outletCaptureVideoImageModel;
@property (ARC_PROP_OUTLET) IBOutlet AVCaptureImageModel* outletCaptureStillImageModel;
@property (ARC_PROP_OUTLET) IBOutlet AVCaptureImageController* outletCaptureImageController;
@end

@implementation AVCaptureImagePopoverViewControllerIOS

ARC_SYNTHESIZEOUTLET(outletCaptureStillImageModel);
ARC_SYNTHESIZEOUTLET(outletCaptureVideoImageModel);
ARC_SYNTHESIZEOUTLET(outletCaptureImageController);

- (instancetype) initWithCoder:(NSCoder *)coder
{
	if ((self=[super initWithCoder:coder])!=nil)
		{
		self.preferredContentSize = [AVCaptureStoryboardPopoverSegueIOS preferredContentSize];
		}
	return self;
}

- (void) dealloc
{
	if (REQUIRED_DEBUG(outletCaptureImageController!=nil) && outletCaptureImageController.captureTeardownNeeded)
		{
		[outletCaptureImageController captureTeardown];
		}
	ARC_SUPERDEALLOC(self);
}

- (void)captureController:(AVCaptureImageControllerBase*)controller outputCaptureImage:(AVCaptureImageModel*)image sampleBuffer:(CMSampleBufferRef)sampleBuffer
{
}

- (void) viewCaptureSetupIfNecessary{
	if (REQUIRED_DEBUG(outletCaptureImageController!=nil))
		if (outletCaptureImageController.captureSetupNeeded)
			{
			[outletCaptureImageController captureSetup];
			}
}

- (void) viewCaptureTeardownIfNecessary{
	if (REQUIRED_DEBUG(outletCaptureImageController!=nil))
		{
		if (outletCaptureImageController.captureTeardownNeeded)
			[outletCaptureImageController captureTeardown];
		}
}

- (void)viewDidLoad {

    [super viewDidLoad];

}

- (void)viewDidAppear:(BOOL)animated {
	[self viewCaptureSetupIfNecessary];
}

- (void)viewWillUnload {
	[self viewCaptureTeardownIfNecessary];
}

-(void) prepareForSegue:(UIStoryboardSegue*)segue sender:(id)sender
{
	NSLOG_METHOD(segue);
}

-(IBAction) actionSnapImageAndDismissController:(id)sender
{
	if (REQUIRED_DEBUG(outletCaptureImageController!=nil))
		[outletCaptureImageController actionCaptureSnapshot:sender];

	if (REQUIRED_DEBUG(self.navigationController!=nil))
		{
		[self viewCaptureTeardownIfNecessary];
		[self.navigationController popViewControllerAnimated:YES];
		}
}

@end

#endif /* TARGET_OS_IPHONE */
