#import "QTKitCaptureImagePopoverMenuControllerOSX.h"
#import "CMCaptureImageModelCIImage.h"

#if !TARGET_OS_IPHONE

@interface QTKitCaptureImagePopoverMenuControllerOSX()<NSMenuDelegate,CMCaptureImageControllerDelegate>
@property (ARC_PROP_STRONG) NSData* imageData;
@property (ARC_PROP_OUTLET) IBOutlet NSView* outletPopoverMenuView;
@property (ARC_PROP_OUTLET) IBOutlet CMCaptureImageControllerBase* outletCaptureController;
@end

@implementation QTKitCaptureImagePopoverMenuControllerOSX

/* inner */
ARC_SYNTHESIZEOUTLET(outletCaptureController);
ARC_SYNTHESIZEOUTLET(outletPopoverMenuView);
ARC_SYNTHESIZE(imageData,__imageData);
ARC_SYNTHESIZE(currentImage,__currentImage);

- (void) dealloc {
	ARC_SUPERDEALLOC(self);
}

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

- (void)captureController:(CMCaptureImageControllerBase*)controller outputCaptureImage:(CMCaptureImageModel*)image imageBuffer:(CVImageBufferRef)imageBuffer
{
	NSLOG_METHOD(image);
	if (REQUIRED_DEBUG(imageBuffer!=NULL))
		{
		self.currentImageData = [CMCaptureImageModelCIImage copyStillImageDataFromImageBuffer:imageBuffer];
		}
}

- (void) captureSetup:(id)sender
{
	if (REQUIRED_DEBUG(outletCaptureController!=nil))
		{
		if (outletCaptureController.captureSetupNeeded)
			[outletCaptureController captureSetup];
		outletCaptureController.delegate = self;
		}
}

- (void) captureTeardown
{
	if (REQUIRED_DEBUG(outletCaptureController!=nil))
		if (outletCaptureController.captureTeardownNeeded)
			[outletCaptureController captureTeardown];
}

#if 0
- (NSRect)confinementRectForMenu:(NSMenu*)menu onScreen:(NSScreen*)screen {
	NSLOG_METHOD(menu);
NSRect confinementScreen = NSZeroRect;
	if (REQUIRED_DEBUG(self.outletViewHolder!=nil))
		{
	NSRect viewHolderFrame = [self.outletViewHolder frame];
	NSRect menuViewFrame = self.outletPopoverMenuView.frame;
		confinementScreen.origin = viewHolderFrame.origin;
		confinementScreen.origin.x -= menuViewFrame.size.width*0.5f;
		confinementScreen.origin.y -= menuViewFrame.size.height*0.5f;
		confinementScreen.origin.y -= (viewHolderFrame.size.height*1.5f);
		confinementScreen.size = self.outletPopoverMenuView.frame.size;
		if ([screen respondsToSelector:@selector(backingScaleFactor)])
			{
			confinementScreen.size.width *= [screen backingScaleFactor];
			confinementScreen.size.height *= [screen backingScaleFactor];
			}
		}
	NSLog(@"confinementScreen=%@\n", NSStringFromRect(confinementScreen));
	return confinementScreen;
}
#endif

- (void)menuWillOpen:(NSMenu *)menu {
	NSLOG_METHOD(menu);
	[self performSelector:@selector(captureSetup:) withObject:self afterDelay:0.1];
}

- (void)menuDidClose:(NSMenu *)menu {
	NSLOG_METHOD(menu);
	[self captureTeardown];
}

- (void)nibLoadAwakeFromNibOnce {
	[self performSelector:@selector(captureSetup:) withObject:self afterDelay:0.1];
}

@end

#endif /* TARGET_OS_IPHONE */
