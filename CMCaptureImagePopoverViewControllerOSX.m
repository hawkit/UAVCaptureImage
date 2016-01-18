#import "CMCaptureImagePopoverViewControllerOSX.h"
#import "CMCaptureImageModelCIImage.h"

#if !TARGET_OS_IPHONE

@interface CMCaptureImagePopoverViewControllerOSX ()<CMCaptureImageControllerDelegate,NSPopoverDelegate>
@property (ARC_PROP_STRONG) NSData* imageData;
@property (ARC_PROP_OUTLET) IBOutlet CMCaptureImageControllerBase* outletCaptureController;
@property (ARC_PROP_STRONG) NSPopover* popover;
@end

@implementation CMCaptureImagePopoverViewControllerOSX

ARC_SYNTHESIZEOUTLET(outletPopover);
ARC_SYNTHESIZEOUTLET(outletCaptureStillImage);
ARC_SYNTHESIZEOUTLET(outletCaptureVideoImage);
ARC_SYNTHESIZEOUTLET(outletCaptureController);
ARC_SYNTHESIZE(imageData,__imageData);
ARC_SYNTHESIZE(currentImage,__currentImage);
ARC_SYNTHESIZE(popover,__popover);

- (void) dealloc {

	if (REQUIRED_DEBUG(outletCaptureController!=nil))
		[outletCaptureController captureTeardown];

	ARC_DEALLOC_NIL(self.imageData);
	ARC_DEALLOC_NIL(self.currentImageData);
	ARC_DEALLOC_NIL(self.popover);
	ARC_SUPERDEALLOC(self);
}

- (BOOL) xibInternalConsistency
{
	return	REQUIRED_DEBUG(outletCaptureStillImage!=nil) &&
			REQUIRED_DEBUG(outletCaptureVideoImage!=nil) &&
			REQUIRED_DEBUG(outletCaptureController!=nil);
}

- (void)awakeFromNib
{
	/* enclosing nib should set these */
	/* if no popover on the outlet, allocate one */
	if (outletPopover==nil)
		{
	NSPopover* popover = [[NSPopover alloc] init];
		if (REQUIRED_DEBUG(popover!=nil))
			{
			popover.contentViewController=self;
			popover.animates = YES;
			popover.delegate = self;
			self.popover = popover;
			outletPopover = popover;
			ARC_RELEASE(popover);
			}
		}
	REQUIRED_DEBUG(outletPopover!=nil);
}

#pragma mark -

-(IBAction) actionPopoverDisplayWithPositioningViewSender:(NSView*)positioningView
{
	if (REQUIRED_DEBUG(outletPopover!=nil) && REQUIRED_DEBUG(positioningView!=nil))
		{
		if ([outletPopover isShown])
			[outletPopover performClose:positioningView];
		else
			{
			if (REQUIRED_DEBUG([positioningView respondsToSelector:@selector(bounds)]))
				{
				outletPopover.behavior = NSPopoverBehaviorSemitransient;
				outletPopover.delegate = self;
		NSInteger preferredEdge = CGRectMinYEdge;
				[outletPopover showRelativeToRect:positioningView.bounds 
									ofView:positioningView
									preferredEdge:preferredEdge];
				}
			}
		}
}

#pragma mark -

+(NSSet*) keyPathsForValuesAffectingCurrentImage
{
	return [NSSet setWithObjects:@"imageData",@"currentImageData",nil];
}

+(NSSet*) keyPathsForValuesAffectingCurrentImageData
{
	return [NSSet setWithObject:@"imageData"];
}

-(NSData*) currentImageData
{
	return self.imageData;
}

-(void) setCurrentImageData:(NSData*)imageData
{
	self.currentImage = nil;
	self.imageData = imageData;
	if (REQUIRED_DEBUG(self.imageData!=nil))
		{
		@try {
			self.currentImage = [[NSImage alloc] initWithData:self.imageData];
			ARC_RELEASE(self.currentImage);
			}
		@catch (NSException* x){
			NSLOG_METHOD(x);
			}
		}
}

- (void)captureController:(CMCaptureImageControllerBase*)controller outputCaptureImage:(CMCaptureImageModel*)image sampleBuffer:(CMSampleBufferRef)sampleBuffer
{
	NSLOG_METHOD(image);
	if (![image isKindOfClass:[CMCaptureImageModelCIImage class]])
		{
		self.currentImageData = (NSData*)image.imageData;
		}
}

- (void)captureController:(CMCaptureImageControllerBase*)controller outputCaptureImage:(CMCaptureImageModel*)image imageBuffer:(CVImageBufferRef)imageBuffer
{
	NSLOG_METHOD(image);
	if (REQUIRED_DEBUG(imageBuffer!=NULL))
		{
		self.currentImageData = [CMCaptureImageModelCIImage copyStillImageDataFromImageBuffer:imageBuffer];
		}
}

#pragma mark -

- (BOOL)popoverShouldClose:(NSPopover *)popover
{
	return YES;
}

- (BOOL)popoverShouldDetach:(NSPopover *)popover
{
	return NO;
}

- (void)popoverDidShow:(NSNotification *)notification
{
//	NSLOG_METHOD(notification);
	if (REQUIRED_DEBUG(outletCaptureController!=nil))
		{
		if (outletCaptureController.captureSetupNeeded)
			[outletCaptureController captureSetup];
		outletCaptureController.delegate = self;
		}
}

- (void)popoverDidClose:(NSNotification *)notification
{
	NSLOG_METHOD(notification);
	if (REQUIRED_DEBUG(outletCaptureController!=nil))
		if (outletCaptureController.captureTeardownNeeded)
			[outletCaptureController captureTeardown];
}

#pragma mark -

- (void)viewDidLoad {
	NSLOG_METHOD(self);
	REQUIRED_DEBUG(self.xibInternalConsistency);
	REQUIRED_DEBUG(self.outletCaptureController) && REQUIRED_DEBUG(self.outletCaptureController.delegate==self);
}

@end

#endif /* TARGET_OS_IPHONE */
